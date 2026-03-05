import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

enum TaskPriority { high, medium, low }

enum TaskCategory { work, health, learning, personal }

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
      );
}
