import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../models/activity_log_model.dart';
import '../../../core/data/seed_data.dart';
import '../../leaderboard/models/leaderboard_entry_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/task_repository.dart';
import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';

class TaskState {
  final List<TaskModel> tasks;
  final List<ActivityLogModel> activityLog;
  final List<Map<String, dynamic>> projectStats;
  final List<Map<String, dynamic>> hourlyData;
  final List<LeaderboardEntry> leaderboardOthers;

  const TaskState({
    required this.tasks,
    required this.activityLog,
    this.projectStats = const [],
    this.hourlyData = const [],
    this.leaderboardOthers = const [],
  });

  int get doneCount => tasks.where((t) => t.done).length;
  int get totalCount => tasks.length;
  int get doneXp => tasks.where((t) => t.done).fold(0, (s, t) => s + t.points);

  TaskState copyWith({
    List<TaskModel>? tasks,
    List<ActivityLogModel>? activityLog,
    List<Map<String, dynamic>>? projectStats,
    List<Map<String, dynamic>>? hourlyData,
    List<LeaderboardEntry>? leaderboardOthers,
  }) =>
      TaskState(
        tasks: tasks ?? this.tasks,
        activityLog: activityLog ?? this.activityLog,
        projectStats: projectStats ?? this.projectStats,
        hourlyData: hourlyData ?? this.hourlyData,
        leaderboardOthers: leaderboardOthers ?? this.leaderboardOthers,
      );
}

class TaskNotifier extends StateNotifier<TaskState> {
  final Ref ref;
  Timer? _recurTimer;
  StreamSubscription<List<TaskModel>>? _taskSub;
  final Set<String> _locallyDeletedTaskIds = {};
  final Map<String, String> _notifiedDate = {}; // taskId -> yyyy-MM-dd

  TaskNotifier(this.ref) : super(const TaskState(tasks: [], activityLog: [])) {
    ref.listen(currentUserProvider, (previous, next) {
      if (next != null) {
        _subscribeToTasks(next.id);
        _fetchRemoteActivity(next.id);
        _fetchRemoteTasks(next.id);
      } else {
        _taskSub?.cancel();
        state = state.copyWith(tasks: [], activityLog: []);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
      final initUser = ref.read(currentUserProvider);
      if (initUser != null) {
        _subscribeToTasks(initUser.id);
        _fetchRemoteActivity(initUser.id);
        _fetchRemoteTasks(initUser.id);
      }
    });
  }

  void refresh() {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      _fetchRemoteActivity(user.id);
      _fetchRemoteTasks(user.id);
    }
    _resetDueTasks();
  }

  Future<void> _fetchRemoteTasks(String userId) async {
    try {
      final data = await Supabase.instance.client
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .timeout(const Duration(seconds: 15));
      final tasks = data.map((json) => TaskModel.fromJson(json)).toList();
      final filtered =
          tasks.where((t) => !_locallyDeletedTaskIds.contains(t.id)).toList();
      state = state.copyWith(tasks: filtered);
    } catch (e) {
      debugPrint('[Tasks] Refresh REST error: $e');
    }
  }

  void _subscribeToTasks(String userId) {
    _taskSub?.cancel();
    _taskSub = ref.read(taskRepositoryProvider).watchTasks(userId).listen(
      (tasks) {
        debugPrint('[Tasks] Stream emitted ${tasks.length} tasks');
        if (tasks.isEmpty && state.tasks.isNotEmpty) {
          debugPrint('[Tasks] Ignoring empty stream emission to avoid data loss');
          return;
        }
        final filtered =
            tasks.where((t) => !_locallyDeletedTaskIds.contains(t.id)).toList();
        final streamIds = tasks.map((t) => t.id).toSet();
        _locallyDeletedTaskIds.removeWhere((id) => !streamIds.contains(id));
        state = state.copyWith(tasks: filtered);
      },
      onError: (e) => debugPrint('[Tasks] Stream error: $e'),
    );
  }

  Future<void> _fetchRemoteActivity(String userId) async {
    final remoteLog = await ref.read(taskRepositoryProvider).fetchActivityLogs(userId);
    if (remoteLog.isNotEmpty) {
      final logs = remoteLog.map((json) => ActivityLogModel.fromJson(json)).toList();
      state = state.copyWith(activityLog: logs);
    }
  }

  bool _initialized = false;

  Future<void> _init() async {
    if (_initialized) return;
    state = TaskState(
      tasks: [],
      activityLog: [],
      projectStats: SeedData.projectStats,
      hourlyData: SeedData.hourlyData,
      leaderboardOthers: List<LeaderboardEntry>.from(
          SeedData.leaderboard.where((e) => !e.isYou)),
    );
    _initialized = true;
    _resetDueTasks();
    _recurTimer =
        Timer.periodic(const Duration(minutes: 1), (_) => _resetDueTasks());
  }

  @override
  void dispose() {
    _recurTimer?.cancel();
    super.dispose();
  }

  void _resetDueTasks() {
    final oldTasks = state.tasks;
    final updated = oldTasks.map((t) {
      if (t.recurring == TaskRecurring.none || !t.done) return t;
      if (t.recurring.isDue(t.lastCompletedAt,
          weeklyDay: t.weeklyDay, monthlyDay: t.monthlyDay)) {
        return t.copyWith(
            done: false, bonusEarned: 0, clearLastCompleted: true);
      }
      return t;
    }).toList();

    final user = ref.read(currentUserProvider);
    if (user != null) {
      final repo = ref.read(taskRepositoryProvider);

      // Schedule next reminder for recurring tasks that just reset
      for (int i = 0; i < updated.length; i++) {
        if (i >= oldTasks.length) break;
        final old = oldTasks[i];
        final u = updated[i];
        if (old.done && !u.done) {
          repo.setTaskCompletion(u.id, false);
          _scheduleNextReminder(user.id, u);
        }
      }

      // Daily re-fire for uncompleted non-recurring tasks with a time
      final now = DateTime.now();
      final todayKey = '${now.year}-${now.month}-${now.day}';
      for (final t in updated) {
        if (t.recurring != TaskRecurring.none || t.done) continue;
        if (t.scheduledDateTime == null) continue;
        if (_notifiedDate[t.id] == todayKey) continue;
        final scheduled = t.scheduledDateTime!;
        final next = DateTime(
            now.year, now.month, now.day, scheduled.hour, scheduled.minute);
        if (next.isAfter(now)) {
          _insertReminder(user.id, t, next);
          _notifiedDate[t.id] = todayKey;
        }
      }
    }

    if (updated
        .any((t) => oldTasks.any((o) => o.id == t.id && o.done != t.done))) {
      state = state.copyWith(tasks: updated);
    }
  }

  TaskModel? completeTask(String id, int bonusEarned, {int rating = 0, String? notes, String? imageUrl}) {
    TaskModel? found;
    state = state.copyWith(
      tasks: state.tasks.map((t) {
        if (t.id != id || t.done) return t;
        found = t;
        return t.copyWith(
          done: true,
          bonusEarned: bonusEarned,
          lastCompletedAt: DateTime.now(),
          proofNotes: notes,
          proofImage: imageUrl,
        );
      }).toList(),
    );
    if (found != null) {
      final now = DateTime.now();
      final tod = TimeOfDay.fromDateTime(now);
      final timeStr =
          '${tod.hourOfPeriod}:${tod.minute.toString().padLeft(2, '0')} ${tod.period == DayPeriod.am ? 'AM' : 'PM'}';
      final log = ActivityLogModel(
        taskId: found!.id,
        task: found!.title,
        project: found!.project,
        points: found!.points + bonusEarned,
        time: 'Today, $timeStr',
        icon: found!.category.icon,
        rating: rating,
        notes: notes,
        imageUrl: imageUrl,
      );
      state = state.copyWith(activityLog: [log, ...state.activityLog]);
      _updateHourlyStats(now);
      
      final user = ref.read(currentUserProvider);
      if (user != null) {
        final repo = ref.read(taskRepositoryProvider);
        repo.setTaskCompletionFull(found!.id, true,
            bonusEarned: bonusEarned,
            notes: notes,
            imageUrl: imageUrl,
            rating: rating);
        repo.addActivityLog(user.id, log.toJson());
      }
    }
    return found;
  }

  void _updateHourlyStats(DateTime now) {
    final hour = now.hour;
    final suffix = hour >= 12 ? 'p' : 'a';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final label = '$displayHour$suffix';

    final updated = List<Map<String, dynamic>>.from(
      state.hourlyData.map((e) => Map<String, dynamic>.from(e)),
    );

    final idx = updated.indexWhere((e) => e['h'] == label);
    if (idx != -1) {
      updated[idx]['v'] = (updated[idx]['v'] as int) + 1;
    } else {
      updated.add({'h': label, 'v': 1});
    }
    state = state.copyWith(hourlyData: updated);
  }

  void uncompleteTask(String id) {
    TaskModel? found;
    state = state.copyWith(
      tasks: state.tasks.map((t) {
        if (t.id != id) return t;
        found = t;
        return t.copyWith(done: false, bonusEarned: 0);
      }).toList(),
    );
    if (found != null) {
      state = state.copyWith(
        activityLog:
            state.activityLog.where((a) => a.taskId != found!.id).toList(),
      );
      final user = ref.read(currentUserProvider);
      if (user != null) {
        ref.read(taskRepositoryProvider).setTaskCompletion(found!.id, false);
        if (found!.recurring == TaskRecurring.none &&
            found!.scheduledDateTime != null) {
          _scheduleNextReminder(user.id, found!);
        }
      }
    }
  }

  Future<void> addTask(TaskModel task) async {
    final user = ref.read(currentUserProvider);
    debugPrint('[Tasks] addTask: title="${task.title}" user=${user?.id}');
    // Optimistic UI update
    state = state.copyWith(tasks: [task, ...state.tasks]);
    debugPrint('[Tasks] Optimistic state now has ${state.tasks.length} tasks');

    if (user != null) {
      final scheduled = task.scheduledDateTime;
      if (scheduled != null) {
        await _insertReminder(user.id, task, scheduled);
      }

      debugPrint('[Tasks] Inserting task into Supabase...');
      try {
        await ref.read(taskRepositoryProvider).addTask(user.id, task);
        debugPrint('[Tasks] Task inserted into Supabase');
      } catch (e) {
        debugPrint('[Tasks] Failed to insert task: $e');
      }
    } else {
      debugPrint('[Tasks] No user, task only in local state');
    }
  }

  Future<void> loadDemo(
    List<TaskModel> tasks, {
    List<Map<String, dynamic>>? projectStats,
    List<Map<String, dynamic>>? hourlyData,
    List<LeaderboardEntry>? leaderboard,
  }) async {
    await _init();
    final user = ref.read(currentUserProvider);
    if (user != null) {
      await ref.read(taskRepositoryProvider).addTasks(user.id, tasks);
      // Our StreamSubscription handles the addition to state from the Supabase stream.
      // However, we still want to update non-synchronized fields like projectStats/hourlyData.
      state = state.copyWith(
        projectStats: projectStats,
        hourlyData: hourlyData,
        leaderboardOthers: leaderboard != null
            ? List<LeaderboardEntry>.from(leaderboard.where((e) => !e.isYou))
            : state.leaderboardOthers,
      );
    } else {
      state = state.copyWith(
        tasks: [...state.tasks, ...tasks],
        projectStats: projectStats,
        hourlyData: hourlyData,
        leaderboardOthers: leaderboard != null
            ? List<LeaderboardEntry>.from(leaderboard.where((e) => !e.isYou))
            : state.leaderboardOthers,
      );
    }
  }

  Future<void> updateTask(TaskModel task) async {
    state = state.copyWith(
      tasks: state.tasks.map((t) => t.id == task.id ? task : t).toList(),
    );

    final user = ref.read(currentUserProvider);
    if (user != null) {
      await ref.read(taskRepositoryProvider).updateTask(task);
    }
  }

  Future<void> deleteTask(String id) async {
    _locallyDeletedTaskIds.add(id);
    state = state.copyWith(
      tasks: state.tasks.where((t) => t.id != id).toList(),
      activityLog: state.activityLog.where((a) => a.taskId != id).toList(),
    );

    final user = ref.read(currentUserProvider);
    if (user != null) {
      await ref.read(taskRepositoryProvider).deleteTask(user.id, id);
    }
  }

  Future<void> deleteTasks(List<String> ids) async {
    _locallyDeletedTaskIds.addAll(ids);
    final idsSet = ids.toSet();
    state = state.copyWith(
      tasks: state.tasks.where((t) => !idsSet.contains(t.id)).toList(),
      activityLog: state.activityLog.where((a) => !idsSet.contains(a.taskId)).toList(),
    );

    final user = ref.read(currentUserProvider);
    if (user != null) {
      for (final id in ids) {
        await ref.read(taskRepositoryProvider).deleteTask(user.id, id);
      }
    }
  }

  Future<void> clearAll() async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      await ref.read(taskRepositoryProvider).deleteAllData(user.id);
    }
    _locallyDeletedTaskIds.clear();
    
    state = TaskState(
      tasks: [],
      activityLog: [],
      projectStats: SeedData.projectStats,
      hourlyData: SeedData.hourlyData,
      leaderboardOthers: List<LeaderboardEntry>.from(
          SeedData.leaderboard.where((e) => !e.isYou)),
    );
  }

  Future<void> _insertReminder(
      String userId, TaskModel task, DateTime scheduled) async {
    final _supabase = Supabase.instance.client;
    final r = Random();
    final notifId =
        '${_hex(r, 8)}-${_hex(r, 4)}-4${_hex(r, 3)}-${(8 + r.nextInt(4)).toRadixString(16)}${_hex(r, 3)}-${_hex(r, 12)}';
    try {
      await _supabase.from('notifications').insert({
        'id': notifId,
        'user_id': userId,
        'type': 'system',
        'title': 'Quest Reminder',
        'message': task.title,
        'created_at': scheduled.toUtc().toIso8601String(),
        'is_read': false,
        'metadata': {'task_id': task.id, 'time': task.time},
      });
    } catch (e) {
      debugPrint('[Tasks] Failed to insert reminder: $e');
    }
  }

  void _scheduleNextReminder(String userId, TaskModel task) {
    if (task.scheduledDateTime == null) return;
    final now = DateTime.now();
    final base = task.scheduledDateTime!;
    DateTime next;

    switch (task.recurring) {
      case TaskRecurring.daily:
        next = DateTime(now.year, now.month, now.day, base.hour, base.minute)
            .add(const Duration(days: 1));
        break;
      case TaskRecurring.weekly:
        final today = DateTime(now.year, now.month, now.day);
        int daysUntil = (DateTime.thursday - today.weekday + 7) % 7;
        if (daysUntil == 0) daysUntil = 7;
        next = today.add(
            Duration(days: daysUntil, hours: base.hour, minutes: base.minute));
        break;
      case TaskRecurring.monthly:
        final day = task.monthlyDay ?? 1;
        next = DateTime(now.year, now.month, day, base.hour, base.minute);
        if (next.isBefore(now)) {
          next =
              DateTime(now.year, now.month + 1, day, base.hour, base.minute);
        }
        break;
      case TaskRecurring.none:
        next = DateTime(now.year, now.month, now.day, base.hour, base.minute)
            .add(const Duration(days: 1));
        break;
    }

    if (next.isBefore(now) || next.isAtSameMomentAs(now)) return;

    final todayKey = '${now.year}-${now.month}-${now.day}';
    _notifiedDate[task.id] = todayKey;
    _insertReminder(userId, task, next);
  }
}

final taskProvider = StateNotifierProvider<TaskNotifier, TaskState>(
  (ref) => TaskNotifier(ref),
);

String _hex(Random r, int digits) {
  var result = '';
  while (digits > 0) {
    final chunk = digits > 8 ? 8 : digits;
    result += r.nextInt(1 << (chunk * 4)).toRadixString(16).padLeft(chunk, '0');
    digits -= chunk;
  }
  return result;
}
