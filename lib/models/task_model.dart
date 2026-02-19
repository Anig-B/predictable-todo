import 'package:cloud_firestore/cloud_firestore.dart';

enum RecurrenceType { daily, weekly, monthly }

enum TaskPriority { high, medium, low }

enum TaskCategory { spear, seed, net, other }

class TaskDefinitionModel {
  final String id;
  final String teamId;
  final String creatorId;
  final List<String> assigneeIds;
  final String title;
  final String description;
  final RecurrenceType recurrenceType;
  final List<int> daysOfWeek; // 1-7 (Mon-Sun)
  final int? dayOfMonth;
  final TaskCategory category;
  final TaskPriority priority;
  final List<SubTask> subTasks;
  final bool isActive;
  final DateTime createdAt;

  TaskDefinitionModel({
    required this.id,
    required this.teamId,
    required this.creatorId,
    required this.assigneeIds,
    required this.title,
    required this.description,
    required this.recurrenceType,
    required this.daysOfWeek,
    this.dayOfMonth,
    required this.category,
    required this.priority,
    required this.subTasks,
    required this.isActive,
    required this.createdAt,
  });

  factory TaskDefinitionModel.fromMap(String id, Map<String, dynamic> data) {
    return TaskDefinitionModel(
      id: id,
      teamId: data['teamId'] ?? '',
      creatorId: data['creatorId'] ?? '',
      assigneeIds: List<String>.from(data['assigneeIds'] ?? []),
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      recurrenceType: RecurrenceType.values.firstWhere(
        (e) => e.name == (data['recurrenceType'] ?? 'daily'),
        orElse: () => RecurrenceType.daily,
      ),
      daysOfWeek: List<int>.from(data['daysOfWeek'] ?? []),
      dayOfMonth: data['dayOfMonth'],
      category: TaskCategory.values.firstWhere(
        (e) => e.name == (data['category'] ?? 'other'),
        orElse: () => TaskCategory.other,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == (data['priority'] ?? 'medium'),
        orElse: () => TaskPriority.medium,
      ),
      subTasks: (data['subTasks'] as List? ?? [])
          .map((s) => SubTask.fromMap(s))
          .toList(),
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'teamId': teamId,
      'creatorId': creatorId,
      'assigneeIds': assigneeIds,
      'title': title,
      'description': description,
      'recurrenceType': recurrenceType.name,
      'daysOfWeek': daysOfWeek,
      'dayOfMonth': dayOfMonth,
      'category': category.name,
      'priority': priority.name,
      'subTasks': subTasks.map((s) => s.toMap()).toList(),
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class SubTask {
  final String title;
  final bool isDone;

  SubTask({required this.title, required this.isDone});

  factory SubTask.fromMap(Map<String, dynamic> data) {
    return SubTask(title: data['title'] ?? '', isDone: data['isDone'] ?? false);
  }

  Map<String, dynamic> toMap() {
    return {'title': title, 'isDone': isDone};
  }
}

class TaskCompletionModel {
  final String id; // taskId_userId_YYYY-MM-DD
  final String taskId;
  final String userId;
  final String teamId;
  final String date; // YYYY-MM-DD
  final String status; // completed, skipped, partial
  final String notes;
  final String result;
  final DateTime timestamp;

  TaskCompletionModel({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.teamId,
    required this.date,
    required this.status,
    required this.notes,
    required this.result,
    required this.timestamp,
  });

  factory TaskCompletionModel.fromMap(String id, Map<String, dynamic> data) {
    return TaskCompletionModel(
      id: id,
      taskId: data['taskId'] ?? '',
      userId: data['userId'] ?? '',
      teamId: data['teamId'] ?? '',
      date: data['date'] ?? '',
      status: data['status'] ?? 'completed',
      notes: data['notes'] ?? '',
      result: data['result'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'userId': userId,
      'teamId': teamId,
      'date': date,
      'status': status,
      'notes': notes,
      'result': result,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
