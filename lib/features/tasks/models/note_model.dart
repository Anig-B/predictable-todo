class NoteModel {
  final String id;
  final String content;
  final DateTime createdAt;

  NoteModel({
    required this.id,
    required this.content,
    required this.createdAt,
  });

  NoteModel copyWith({
    String? id,
    String? content,
    DateTime? createdAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'content': content,
        'created_at': createdAt.toIso8601String(),
      };

  factory NoteModel.fromJson(Map<String, dynamic> json) => NoteModel(
        id: json['id'] as String,
        content: json['content'] as String,
        createdAt: DateTime.parse(
          (json['created_at'] ?? json['createdAt']) as String,
        ),
      );
}
