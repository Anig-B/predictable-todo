class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String text;
  final DateTime createdAt;
  final bool read;
  final Map<String, dynamic> metadata;

  const NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.text,
    required this.createdAt,
    required this.read,
    this.metadata = const {},
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id']?.toString() ?? '',
      type: map['type']?.toString() ?? 'system',
      title: map['title']?.toString() ?? 'Notification',
      text: map['message']?.toString() ?? '',
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'].toString()) 
          : DateTime.now(),
      read: map['is_read'] as bool? ?? false,
      metadata: map['metadata'] != null 
          ? Map<String, dynamic>.from(map['metadata'] as Map) 
          : {},
    );
  }

  NotificationModel copyWith({
    String? id,
    String? type,
    String? title,
    String? text,
    DateTime? createdAt,
    bool? read,
    Map<String, dynamic>? metadata,
  }) =>
      NotificationModel(
        id: id ?? this.id,
        type: type ?? this.type,
        title: title ?? this.title,
        text: text ?? this.text,
        createdAt: createdAt ?? this.createdAt,
        read: read ?? this.read,
        metadata: metadata ?? this.metadata,
      );
}
