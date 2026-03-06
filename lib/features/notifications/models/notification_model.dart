class NotificationModel {
  final int id;
  final String text;
  final String time;
  final bool read;

  const NotificationModel({
    required this.id,
    required this.text,
    required this.time,
    required this.read,
  });

  NotificationModel copyWith({
    int? id,
    String? text,
    String? time,
    bool? read,
  }) =>
      NotificationModel(
        id: id ?? this.id,
        text: text ?? this.text,
        time: time ?? this.time,
        read: read ?? this.read,
      );
}
