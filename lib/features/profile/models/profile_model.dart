class ProfileModel {
  final String name;
  final String avatar;
  final String shortId;
  final String tagline;

  ProfileModel({
    required this.name,
    required this.avatar,
    this.shortId = '',
    required this.tagline,
  });

  ProfileModel copyWith({
    String? name,
    String? avatar,
    String? shortId,
    String? tagline,
  }) {
    return ProfileModel(
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      shortId: shortId ?? this.shortId,
      tagline: tagline ?? this.tagline,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'avatar': avatar,
        'shortId': shortId,
        'tagline': tagline,
      };

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        name: json['name'] as String? ?? 'Quest Master',
        avatar: json['avatar'] as String? ?? '🧑‍💻',
        shortId: json['shortId'] as String? ?? '',
        tagline: json['tagline'] as String? ?? '#QUESTLOG',
      );
}
