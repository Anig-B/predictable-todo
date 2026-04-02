import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../models/activity_log_model.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/data/seed_data.dart';
import '../../leaderboard/models/leaderboard_entry_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/task_repository.dart';

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

  TaskNotifier(this.ref) : super(const TaskState(tasks: [], activityLog: [])) {
    _init();
    
    ref.listen(currentUserProvider, (previous, next) {
      if (next != null) {
        _subscribeToTasks(next.id);
        _fetchRemoteActivity(next.id);
      } else {
        _taskSub?.cancel();
        state = state.copyWith(tasks: [], activityLog: []);
      }
    });

    final initUser = ref.read(currentUserProvider);
    if (initUser != null) {
      _subscribeToTasks(initUser.id);
      _fetchRemoteActivity(initUser.id);
    }
  }

  void _subscribeToTasks(String userId) {
    _taskSub?.cancel();
    _taskSub = ref.read(taskRepositoryProvider).watchTasks(userId).listen((tasks) {
      state = state.copyWith(tasks: tasks);
    });
  }

  Future<void> _fetchRemoteActivity(String userId) async {
    final remoteLog = await ref.read(taskRepositoryProvider).fetchActivityLogs(userId);
    if (remoteLog.isNotEmpty) {
      final logs = remoteLog.map((json) => ActivityLogModel.fromJson(json)).toList();
      state = state.copyWith(activityLog: logs);
      StorageService.saveLog(logs);
    }
  }

  bool _initialized = false;

  Future<void> _init() async {
    if (_initialized) return;
    final tasks = await StorageService.loadTasks();
    final log = await StorageService.loadLog();
    final savedStats = await StorageService.loadProjectStats();
    final savedHourly = await StorageService.loadHourlyData();

    state = TaskState(
      tasks: tasks ?? [],
      activityLog: log ?? [],
      projectStats: savedStats ?? SeedData.projectStats,
      hourlyData: savedHourly ?? SeedData.hourlyData,
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

  void _persist() {
    StorageService.saveTasks(state.tasks);
    StorageService.saveLog(state.activityLog);
    StorageService.saveProjectStats(state.projectStats);
    StorageService.saveHourlyData(state.hourlyData);
  }

  void _resetDueTasks() {
    final updated = state.tasks.map((t) {
      if (t.recurring == TaskRecurring.none || !t.done) return t;
      if (t.recurring.isDue(t.lastCompletedAt,
          weeklyDay: t.weeklyDay, monthlyDay: t.monthlyDay)) {
        return t.copyWith(
            done: false, bonusEarned: 0, clearLastCompleted: true);
      }
      return t;
    }).toList();
    if (updated
        .any((t) => state.tasks.any((o) => o.id == t.id && o.done != t.done))) {
      state = state.copyWith(tasks: updated);
      _persist();

      final user = ref.read(currentUserProvider);
      if (user != null) {
        final repo = ref.read(taskRepositoryProvider);
        for (final u in updated) {
          final old = state.tasks.firstWhere((o) => o.id == u.id);
          if (old.done && !u.done) {
            repo.setTaskCompletion(u.id, false);
          }
        }
      }
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
        ref.read(taskRepositoryProvider).setTaskCompletion(found!.id, true,
            bonusEarned: bonusEarned, notes: notes, imageUrl: imageUrl);
      }
    }
    _persist();
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
      }
    }
    _persist();
  }

  Future<void> addTask(TaskModel task) async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      await ref.read(taskRepositoryProvider).addTask(user.id, task);
    } else {
      state = state.copyWith(tasks: [...state.tasks, task]);
      _persist();
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
    _persist();
  }

  Future<void> clearAll() async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      await ref.read(taskRepositoryProvider).deleteAllData(user.id);
    }
    
    state = TaskState(
      tasks: [],
      activityLog: [],
      projectStats: SeedData.projectStats,
      hourlyData: SeedData.hourlyData,
      leaderboardOthers: List<LeaderboardEntry>.from(
          SeedData.leaderboard.where((e) => !e.isYou)),
    );
    _persist();
  }
}

final taskProvider = StateNotifierProvider<TaskNotifier, TaskState>(
  (ref) => TaskNotifier(ref),
);
