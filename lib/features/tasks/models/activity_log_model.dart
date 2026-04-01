class ActivityLogModel {
  final String taskId;
  final String task;
  final int points;
  final String time;
  final String icon;

  /// 0 = no rating, 1–5 = mood rating from proof modal
  final int rating;
  final String? notes;
  final String? imageUrl;
  final DateTime createdAt;

  ActivityLogModel({
    required this.taskId,
    required this.task,
    required this.points,
    required this.time,
    required this.icon,
    this.rating = 0,
    this.notes,
    this.imageUrl,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'taskId': taskId,
        'task': task,
        'points': points,
        'time': time,
        'icon': icon,
        'rating': rating,
        'notes': notes,
        'imageUrl': imageUrl,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ActivityLogModel.fromJson(Map<String, dynamic> j) => ActivityLogModel(
        taskId: j['taskId'] as String,
        task: j['task'] as String,
        points: j['points'] as int,
        time: j['time'] as String,
        icon: j['icon'] as String,
        rating: j['rating'] as int? ?? 0,
        notes: j['notes'] as String?,
        imageUrl: j['imageUrl'] as String?,
        createdAt: j['createdAt'] != null
            ? DateTime.parse(j['createdAt'] as String)
            : null,
      );
}
