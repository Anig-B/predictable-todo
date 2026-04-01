import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

enum TaskPriority { high, medium, low }

enum TaskCategory { work, health, learning, personal }

enum TaskRecurring { none, daily, weekly, monthly }

extension TaskRecurringExt on TaskRecurring {
  String get label {
    switch (this) {
      case TaskRecurring.none:
        return 'None';
      case TaskRecurring.daily:
        return 'Daily';
      case TaskRecurring.weekly:
        return 'Weekly';
      case TaskRecurring.monthly:
        return 'Monthly';
    }
  }

  /// Returns true if [lastCompleted] is far enough in the past to warrant a reset.
  /// [weeklyDay] = 1(Mon)…7(Sun), [monthlyDay] = 1-28 or 0 = last day of month.
  bool isDue(DateTime? lastCompleted, {int? weeklyDay, int? monthlyDay}) {
    if (this == TaskRecurring.none || lastCompleted == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDay =
        DateTime(lastCompleted.year, lastCompleted.month, lastCompleted.day);
    switch (this) {
      case TaskRecurring.daily:
        return today.isAfter(lastDay);
      case TaskRecurring.weekly:
        final targetWeekday = weeklyDay ?? 1;
        final daysBack = (today.weekday - targetWeekday + 7) % 7;
        final lastOccurrence = today.subtract(Duration(days: daysBack));
        return lastDay.isBefore(lastOccurrence);
      case TaskRecurring.monthly:
        final lastDayOfMonth = DateTime(now.year, now.month + 1, 0).day;
        final targetDay = (monthlyDay == 0 ? lastDayOfMonth : (monthlyDay ?? 1))
            .clamp(1, lastDayOfMonth);
        final thisOccurrence = DateTime(now.year, now.month, targetDay);
        return !today.isBefore(thisOccurrence) &&
            lastDay.isBefore(thisOccurrence);
      case TaskRecurring.none:
        return false;
    }
  }
}

extension TaskPriorityExt on TaskPriority {
  String get label => name;
  Color get color {
    switch (this) {
      case TaskPriority.high:
        return AppColors.red;
      case TaskPriority.medium:
        return AppColors.gold;
      case TaskPriority.low:
        return AppColors.accent;
    }
  }
}

extension TaskCategoryExt on TaskCategory {
  String get label {
    switch (this) {
      case TaskCategory.work:
        return 'Work';
      case TaskCategory.health:
        return 'Health';
      case TaskCategory.learning:
        return 'Learning';
      case TaskCategory.personal:
        return 'Personal';
    }
  }

  String get icon {
    switch (this) {
      case TaskCategory.work:
        return '💼';
      case TaskCategory.health:
        return '💪';
      case TaskCategory.learning:
        return '📚';
      case TaskCategory.personal:
        return '🏠';
    }
  }
}

class TaskModel {
  final String id;
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
  final String? proofNotes;
  final String? proofImage;

  /// 1=Mon…7=Sun, null = any day
  final int? weeklyDay;

  /// 1-28 = specific date, 0 = last day of month, null = any day
  final int? monthlyDay;

  int get durationMinutes {
    final t = time.toLowerCase().trim();
    if (t.contains('am') || t.contains('pm') || t.contains(':')) return 0;

    // Parse formats like "15m", "1h", "1.5h", "1h 30m"
    int total = 0;
    final parts = t.split(' ');
    for (final p in parts) {
      if (p.endsWith('m')) {
        total += int.tryParse(p.replaceAll('m', '')) ?? 0;
      } else if (p.endsWith('h')) {
        final val = double.tryParse(p.replaceAll('h', '')) ?? 0;
        total += (val * 60).round();
      }
    }
    return total;
  }

  String get recurringLabel {
    if (recurring == TaskRecurring.none) return '';
    if (recurring == TaskRecurring.daily) return 'Daily';

    if (recurring == TaskRecurring.weekly) {
      if (weeklyDay == null) return 'Weekly';
      const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[(weeklyDay! - 1).clamp(0, 6)];
    }

    if (recurring == TaskRecurring.monthly) {
      if (monthlyDay == null) return 'Monthly';
      if (monthlyDay == 0) return 'Last Day';
      final d = monthlyDay!;
      if (d >= 11 && d <= 13) return '${d}th';
      switch (d % 10) {
        case 1:
          return '${d}st';
        case 2:
          return '${d}nd';
        case 3:
          return '${d}rd';
        default:
          return '${d}th';
      }
    }
    return recurring.label;
  }

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
    this.weeklyDay,
    this.monthlyDay,
    this.proofNotes,
    this.proofImage,
  });

  TaskModel copyWith({
    String? id,
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
    int? weeklyDay,
    int? monthlyDay,
    String? proofNotes,
    String? proofImage,
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
        lastCompletedAt: clearLastCompleted
            ? null
            : (lastCompletedAt ?? this.lastCompletedAt),
        weeklyDay: weeklyDay ?? this.weeklyDay,
        monthlyDay: monthlyDay ?? this.monthlyDay,
        proofNotes: proofNotes ?? this.proofNotes,
        proofImage: proofImage ?? this.proofImage,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'desc': desc,
        'time': time,
        'points': points,
        'project': project,
        'streak': streak,
        'done': done,
        'priority': priority.index,
        'category': category.index,
        'bonusEarned': bonusEarned,
        'recurring': recurring.index,
        'lastCompletedAt': lastCompletedAt?.toIso8601String(),
        'weeklyDay': weeklyDay,
        'monthlyDay': monthlyDay,
        'proof_notes': proofNotes,
        'proof_image': proofImage,
      };

  factory TaskModel.fromJson(Map<String, dynamic> j) => TaskModel(
        id: j['id'] as String,
        title: j['title'] as String,
        desc: j['desc'] as String,
        time: j['time'] as String,
        points: j['points'] as int,
        project: j['project'] as String,
        streak: j['streak'] as int,
        done: j['done'] as bool,
        priority: TaskPriority.values[j['priority'] as int],
        category: TaskCategory.values[j['category'] as int],
        bonusEarned: j['bonusEarned'] as int? ?? 0,
        recurring: TaskRecurring.values[j['recurring'] as int? ?? 0],
        lastCompletedAt: j['lastCompletedAt'] != null
            ? DateTime.parse(j['lastCompletedAt'] as String)
            : null,
        weeklyDay: j['weeklyDay'] as int?,
        monthlyDay: j['monthlyDay'] as int?,
        proofNotes: j['proof_notes'] as String?,
        proofImage: j['proof_image'] as String?,
      );
}
