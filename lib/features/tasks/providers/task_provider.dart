import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../models/activity_log_model.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/data/seed_data.dart';

class TaskState {
  final List<TaskModel> tasks;
  final List<ActivityLogModel> activityLog;
  final List<Map<String, dynamic>> projectStats;
  final List<Map<String, dynamic>> hourlyData;

  const TaskState({
    required this.tasks,
    required this.activityLog,
    this.projectStats = const [],
    this.hourlyData = const [],
  });

  int get doneCount => tasks.where((t) => t.done).length;
  int get totalCount => tasks.length;
  int get doneXp => tasks.where((t) => t.done).fold(0, (s, t) => s + t.points);

  TaskState copyWith({
    List<TaskModel>? tasks,
    List<ActivityLogModel>? activityLog,
    List<Map<String, dynamic>>? projectStats,
    List<Map<String, dynamic>>? hourlyData,
  }) =>
      TaskState(
        tasks: tasks ?? this.tasks,
        activityLog: activityLog ?? this.activityLog,
        projectStats: projectStats ?? this.projectStats,
        hourlyData: hourlyData ?? this.hourlyData,
      );
}

class TaskNotifier extends StateNotifier<TaskState> {
  Timer? _recurTimer;

  TaskNotifier() : super(const TaskState(tasks: [], activityLog: [])) {
    _init();
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
    }
  }

  TaskModel? completeTask(int id, int bonusEarned, {int rating = 0}) {
    TaskModel? found;
    state = state.copyWith(
      tasks: state.tasks.map((t) {
        if (t.id != id || t.done) return t;
        found = t;
        return t.copyWith(
          done: true,
          bonusEarned: bonusEarned,
          lastCompletedAt: DateTime.now(),
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
      );
      state = state.copyWith(activityLog: [log, ...state.activityLog]);
    }
    _persist();
    return found;
  }

  void uncompleteTask(int id) {
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
    }
    _persist();
  }

  void addTask(TaskModel task) {
    state = state.copyWith(tasks: [...state.tasks, task]);
    _persist();
  }

  Future<void> loadDemo(List<TaskModel> tasks,
      {List<Map<String, dynamic>>? projectStats,
      List<Map<String, dynamic>>? hourlyData}) async {
    await _init();
    state = state.copyWith(
      tasks: [...state.tasks, ...tasks],
      projectStats: projectStats,
      hourlyData: hourlyData,
    );
    _persist();
  }

  void clearAll() {
    state = const TaskState(
      tasks: [],
      activityLog: [],
      projectStats: SeedData.projectStats,
      hourlyData: SeedData.hourlyData,
    );
    _persist();
  }
}

final taskProvider = StateNotifierProvider<TaskNotifier, TaskState>(
  (ref) => TaskNotifier(),
);
