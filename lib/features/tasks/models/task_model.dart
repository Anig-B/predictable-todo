import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum TaskPriority { high, medium, low }

enum TaskCategory { work, health, learning, personal }

enum TaskRecurring { none, daily, weekly, monthly }

extension TaskRecurringExt on TaskRecurring {
  String get label {
    switch (this) {
      case TaskRecurring.none:    return 'None';
      case TaskRecurring.daily:   return 'Daily';
      case TaskRecurring.weekly:  return 'Weekly';
      case TaskRecurring.monthly: return 'Monthly';
    }
  }

  /// Returns true if [lastCompleted] is far enough in the past to warrant a reset.
  bool isDue(DateTime? lastCompleted) {
    if (this == TaskRecurring.none || lastCompleted == null) return false;
    final now = DateTime.now();
    switch (this) {
      case TaskRecurring.daily:
        return now.year != lastCompleted.year ||
            now.month != lastCompleted.month ||
            now.day != lastCompleted.day;
      case TaskRecurring.weekly:
        return now.difference(lastCompleted).inDays >= 7;
      case TaskRecurring.monthly:
        return now.year > lastCompleted.year ||
            now.month > lastCompleted.month;
      case TaskRecurring.none:
        return false;
    }
  }
}

extension TaskPriorityExt on TaskPriority {
  String get label => name;
  Color get color {
    switch (this) {
      case TaskPriority.high:   return AppColors.red;
      case TaskPriority.medium: return AppColors.gold;
      case TaskPriority.low:    return AppColors.accent;
    }
  }
}

extension TaskCategoryExt on TaskCategory {
  String get label {
    switch (this) {
      case TaskCategory.work:     return 'Work';
      case TaskCategory.health:   return 'Health';
      case TaskCategory.learning: return 'Learning';
      case TaskCategory.personal: return 'Personal';
    }
  }
  String get icon {
    switch (this) {
      case TaskCategory.work:     return '💼';
      case TaskCategory.health:   return '💪';
      case TaskCategory.learning: return '📚';
      case TaskCategory.personal: return '🏠';
    }
  }
}

class TaskModel {
  final int id;
  final String title;
  final String desc;
  final String time;
  final int points;
  final String project;
  final int streak;
  final bool done;
  final TaskPriority priority;
  final TaskCategory category;
  final int bonusEarned;
  final TaskRecurring recurring;
  final DateTime? lastCompletedAt;

  const TaskModel({
    required this.id,
    required this.title,
    required this.desc,
    required this.time,
    required this.points,
    required this.project,
    required this.streak,
    required this.done,
    required this.priority,
    required this.category,
    this.bonusEarned = 0,
    this.recurring = TaskRecurring.none,
    this.lastCompletedAt,
  });

  TaskModel copyWith({
    int? id,
    String? title,
    String? desc,
    String? time,
    int? points,
    String? project,
    int? streak,
    bool? done,
    TaskPriority? priority,
    TaskCategory? category,
    int? bonusEarned,
    TaskRecurring? recurring,
    DateTime? lastCompletedAt,
    bool clearLastCompleted = false,
  }) =>
      TaskModel(
        id: id ?? this.id,
        title: title ?? this.title,
        desc: desc ?? this.desc,
        time: time ?? this.time,
        points: points ?? this.points,
        project: project ?? this.project,
        streak: streak ?? this.streak,
        done: done ?? this.done,
        priority: priority ?? this.priority,
        category: category ?? this.category,
        bonusEarned: bonusEarned ?? this.bonusEarned,
        recurring: recurring ?? this.recurring,
        lastCompletedAt:
            clearLastCompleted ? null : (lastCompletedAt ?? this.lastCompletedAt),
      );
}
