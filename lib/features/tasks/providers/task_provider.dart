import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../models/activity_log_model.dart';
import '../../../core/services/storage_service.dart';

class TaskState {
  final List<TaskModel> tasks;
  final List<ActivityLogModel> activityLog;

  const TaskState({
    required this.tasks,
    required this.activityLog,
  });

  int get doneCount => tasks.where((t) => t.done).length;
  int get totalCount => tasks.length;
  int get doneXp => tasks.where((t) => t.done).fold(0, (s, t) => s + t.points);

  TaskState copyWith({
    List<TaskModel>? tasks,
    List<ActivityLogModel>? activityLog,
  }) =>
      TaskState(
        tasks: tasks ?? this.tasks,
        activityLog: activityLog ?? this.activityLog,
      );
}

class TaskNotifier extends StateNotifier<TaskState> {
  Timer? _recurTimer;

  TaskNotifier() : super(const TaskState(tasks: [], activityLog: [])) {
    _init();
  }

  Future<void> _init() async {
    // Starting with a truly fresh state as requested
    state = const TaskState(
      tasks: [],
      activityLog: [],
    );
    _persist();
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

  void loadDemo(List<TaskModel> tasks) {
    state = state.copyWith(tasks: [...state.tasks, ...tasks]);
    _persist();
  }

  void clearAll() {
    state = const TaskState(tasks: [], activityLog: []);
    _persist();
  }
}

final taskProvider = StateNotifierProvider<TaskNotifier, TaskState>(
  (ref) => TaskNotifier(),
);
