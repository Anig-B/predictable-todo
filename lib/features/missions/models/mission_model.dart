class MissionModel {
  final String id;
  final String name;
  final String? description;
  final String? createdBy;
  final bool isActive;
  final DateTime? joinedAt;
  final DateTime? createdAt;

  MissionModel({
    required this.id,
    required this.name,
    this.description,
    this.createdBy,
    this.isActive = true,
    this.joinedAt,
    this.createdAt,
  });

  factory MissionModel.fromJson(Map<String, dynamic> j) {
    return MissionModel(
      id: j['id'] as String,
      name: j['name'] as String,
      description: j['description'] as String?,
      createdBy: j['created_by'] as String?,
      isActive: j['is_active'] as bool? ?? true,
      joinedAt: j['joined_at'] != null ? DateTime.parse(j['joined_at'] as String) : null,
      createdAt: j['created_at'] != null ? DateTime.parse(j['created_at'] as String) : null,
    );
  }
}
