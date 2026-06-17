enum ChallengeType {
  earlyBird, 
  tripleThreat, 
  healthHero,
  bossDamage,
  socialScout,
  proofProvider,
  consistency,
  projectFocus,
  workFocus,
  learningFocus
}

class ChallengeModel {
  final int id;
  final ChallengeType type;
  final String title;
  final String desc;
  final int reward;
  final String icon;
  final bool done;
  final int progress;
  final int target;

  const ChallengeModel({
    required this.id,
    required this.type,
    required this.title,
    required this.desc,
    required this.reward,
    required this.icon,
    required this.done,
    this.progress = 0,
    this.target = 1,
  });

  ChallengeModel copyWith({
    int? id,
    ChallengeType? type,
    String? title,
    String? desc,
    int? reward,
    String? icon,
    bool? done,
    int? progress,
    int? target,
  }) =>
      ChallengeModel(
        id: id ?? this.id,
        type: type ?? this.type,
        title: title ?? this.title,
        desc: desc ?? this.desc,
        reward: reward ?? this.reward,
        icon: icon ?? this.icon,
        done: done ?? this.done,
        progress: progress ?? this.progress,
        target: target ?? this.target,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.index,
        'title': title,
        'desc': desc,
        'reward': reward,
        'icon': icon,
        'done': done,
        'progress': progress,
        'target': target,
      };

  factory ChallengeModel.fromJson(Map<String, dynamic> j) => ChallengeModel(
        id: j['id'] as int,
        type: ChallengeType.values[j['type'] as int? ?? 0],
        title: j['title'] as String,
        desc: j['desc'] as String,
        reward: j['reward'] as int,
        icon: j['icon'] as String,
        done: j['done'] as bool,
        progress: j['progress'] as int? ?? 0,
        target: j['target'] as int? ?? 1,
      );
}
