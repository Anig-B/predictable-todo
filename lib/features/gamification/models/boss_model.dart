class BossModel {
  final String id;
  final String name;
  final String emoji;
  final int hp;
  final int maxHp;
  final int reward;
  final int tasksDone;
  final int tasksNeeded;
  final String? color; // Hex string or element descriptor

  const BossModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.hp,
    required this.maxHp,
    required this.reward,
    required this.tasksDone,
    required this.tasksNeeded,
    this.color,
  });

  bool get isDefeated => hp <= 0;
  double get hpPercent => (hp / maxHp).clamp(0.0, 1.0);
  int get damagePerTask => (maxHp / tasksNeeded).floor();

  BossModel copyWith({
    String? id,
    String? name,
    String? emoji,
    int? hp,
    int? maxHp,
    int? reward,
    int? tasksDone,
    int? tasksNeeded,
    String? color,
  }) {
    return BossModel(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      hp: hp ?? this.hp,
      maxHp: maxHp ?? this.maxHp,
      reward: reward ?? this.reward,
      tasksDone: tasksDone ?? this.tasksDone,
      tasksNeeded: tasksNeeded ?? this.tasksNeeded,
      color: color ?? this.color,
    );
  }
}
