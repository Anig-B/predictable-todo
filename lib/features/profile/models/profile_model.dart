class ProfileModel {
  final String name;
  final String avatar;
  final String shortId;
  final String tagline;
  final String role;

  ProfileModel({
    required this.name,
    required this.avatar,
    this.shortId = '',
    required this.tagline,
    this.role = 'user',
  });

  ProfileModel copyWith({
    String? name,
    String? avatar,
    String? shortId,
    String? tagline,
    String? role,
  }) {
    return ProfileModel(
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      shortId: shortId ?? this.shortId,
      tagline: tagline ?? this.tagline,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'avatar': avatar,
        'shortId': shortId,
        'tagline': tagline,
        'role': role,
      };

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        name: json['name'] as String? ?? 'Quest Master',
        avatar: json['avatar'] as String? ?? '🧑‍💻',
        shortId: json['shortId'] as String? ?? '',
        tagline: json['tagline'] as String? ?? '#QUESTLOG',
        role: json['role'] as String? ?? 'user',
      );
}
