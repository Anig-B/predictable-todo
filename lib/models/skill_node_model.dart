class SkillNodeModel {
  final String id;
  final String name;
  final String desc;
  final String icon;
  final int cost;
  final bool unlocked;

  const SkillNodeModel({
    required this.id,
    required this.name,
    required this.desc,
    required this.icon,
    required this.cost,
    required this.unlocked,
  });

  SkillNodeModel copyWith({
    String? id,
    String? name,
    String? desc,
    String? icon,
    int? cost,
    bool? unlocked,
  }) =>
      SkillNodeModel(
        id: id ?? this.id,
        name: name ?? this.name,
        desc: desc ?? this.desc,
        icon: icon ?? this.icon,
        cost: cost ?? this.cost,
        unlocked: unlocked ?? this.unlocked,
      );
}
