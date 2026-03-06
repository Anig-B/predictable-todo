class BossModel {
  final String name;
  final String emoji;
  final int hp;
  final int maxHp;
  final int reward;
  final int tasksDone;
  final int tasksNeeded;

  const BossModel({
    required this.name,
    required this.emoji,
    required this.hp,
    required this.maxHp,
    required this.reward,
    required this.tasksDone,
    required this.tasksNeeded,
  });

  bool get isDefeated => hp <= 0;
  double get hpPercent => (hp / maxHp).clamp(0.0, 1.0);
  int get damagePerTask => (maxHp / tasksNeeded).round();

  BossModel copyWith({
    String? name,
    String? emoji,
    int? hp,
    int? maxHp,
    int? reward,
    int? tasksDone,
    int? tasksNeeded,
  }) =>
      BossModel(
        name: name ?? this.name,
        emoji: emoji ?? this.emoji,
        hp: hp ?? this.hp,
        maxHp: maxHp ?? this.maxHp,
        reward: reward ?? this.reward,
        tasksDone: tasksDone ?? this.tasksDone,
        tasksNeeded: tasksNeeded ?? this.tasksNeeded,
      );
}
