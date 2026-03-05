class ChallengeModel {
  final int id;
  final String title;
  final String desc;
  final int reward;
  final String icon;
  final bool done;

  const ChallengeModel({
    required this.id,
    required this.title,
    required this.desc,
    required this.reward,
    required this.icon,
    required this.done,
  });

  ChallengeModel copyWith({
    int? id,
    String? title,
    String? desc,
    int? reward,
    String? icon,
    bool? done,
  }) =>
      ChallengeModel(
        id: id ?? this.id,
        title: title ?? this.title,
        desc: desc ?? this.desc,
        reward: reward ?? this.reward,
        icon: icon ?? this.icon,
        done: done ?? this.done,
      );
}
