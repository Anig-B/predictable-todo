import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/task_model.dart';
import '../models/activity_log_model.dart';
import '../core/data/seed_data.dart';

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
  TaskNotifier()
      : super(TaskState(tasks: SeedData.tasks, activityLog: SeedData.activityLog));

  /// Marks a task done and logs it. Returns the task (for XP calculation upstream).
  TaskModel? completeTask(int id, int bonusEarned) {
    TaskModel? found;
    state = state.copyWith(
      tasks: state.tasks.map((t) {
        if (t.id != id || t.done) return t;
        found = t;
        return t.copyWith(done: true, bonusEarned: bonusEarned);
      }).toList(),
    );
    if (found != null) {
      final now = DateTime.now();
      final timeStr = _formatTime(now);
      final log = ActivityLogModel(
        task: found!.title,
        points: found!.points + bonusEarned,
        time: 'Today, $timeStr',
        icon: found!.category.icon,
      );
      state = state.copyWith(activityLog: [log, ...state.activityLog]);
    }
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
        activityLog: state.activityLog
            .where((a) => !(a.task == found!.title && a.time.startsWith('Today')))
            .toList(),
      );
    }
  }

  void addTask(TaskModel task) {
    state = state.copyWith(tasks: [...state.tasks, task]);
  }

  void loadDemo(List<TaskModel> tasks) {
    state = state.copyWith(tasks: [...state.tasks, ...tasks]);
  }

  void clearAll() {
    state = const TaskState(tasks: [], activityLog: []);
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }
}

final taskProvider = StateNotifierProvider<TaskNotifier, TaskState>(
  (ref) => TaskNotifier(),
);

final totalXpProvider = Provider<int>((ref) {
  final taskXp = ref.watch(taskProvider).doneXp;
  // gamificationProvider imported via late to avoid circular — accessed directly in consumers
  return taskXp;
});
