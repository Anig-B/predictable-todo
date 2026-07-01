class ActivityLogModel {
  final String taskId;
  final String task;
  final String project;
  final int points;
  final String time;
  final String icon;

  /// 0 = no rating, 1–5 = mood rating from proof modal
  final int rating;
  final String? notes;
  final String? imageUrl;
  final String? questId;
  final DateTime createdAt;

  ActivityLogModel({
    required this.taskId,
    required this.task,
    required this.project,
    required this.points,
    required this.time,
    required this.icon,
    this.rating = 0,
    this.notes,
    this.imageUrl,
    this.questId,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'taskId': taskId,
        'task': task,
        'project': project,
        'points': points,
        'time': time,
        'icon': icon,
        'rating': rating,
        'notes': notes,
        'imageUrl': imageUrl,
        'questId': questId,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ActivityLogModel.fromJson(Map<String, dynamic> j) => ActivityLogModel(
        taskId: j['taskId'] as String? ?? j['task_id'] as String? ?? 'unk',
        task: j['task'] as String? ?? 'Unknown Task',
        project: j['project'] as String? ?? 'General',
        points: j['points'] as int? ?? 0,
        time: j['time'] as String? ?? '',
        icon: j['icon'] as String? ?? '📝',
        rating: j['rating'] as int? ?? 0,
        notes: j['notes'] as String?,
        imageUrl: j['imageUrl'] as String? ?? j['image_url'] as String?,
        questId: j['questId'] as String? ?? j['quest_id'] as String?,
        createdAt: j['createdAt'] != null
            ? DateTime.parse(j['createdAt'] as String)
            : (j['created_at'] != null ? DateTime.parse(j['created_at'] as String) : DateTime.now()),
      );
}
