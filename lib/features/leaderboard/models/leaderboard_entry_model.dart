class LeaderboardEntry {
  final String id;
  final String name;
  final String shortId;
  final int xp;
  final int weeklyXp;
  final String avatar;
  final int level;
  final int streak;
  final int tasksWeek;
  final bool isYou;

  const LeaderboardEntry({
    required this.id,
    required this.name,
    required this.shortId,
    required this.xp,
    required this.weeklyXp,
    required this.avatar,
    required this.level,
    required this.streak,
    required this.tasksWeek,
    this.isYou = false,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json, {String? currentUserId}) {
    // Determine the ID from either a direct 'id' or 'user_id'
    final entryId = json['id'] as String? ?? json['user_id'] as String? ?? '';
    
    // We expect joined data, e.g. from a view or join query
    return LeaderboardEntry(
      id: entryId,
      name: json['username'] as String? ?? 'Unknown',
      shortId: json['short_id'] as String? ?? '',
      xp: json['xp'] as int? ?? 0,
      weeklyXp: json['weekly_xp'] as int? ?? 0,
      avatar: json['avatar_url'] as String? ?? '🧑‍💻',
      level: json['level'] as int? ?? 1,
      streak: json['streak'] as int? ?? json['current_streak'] as int? ?? 0,
      tasksWeek: json['tasksweek'] as int? ?? json['tasksWeek'] as int? ?? 0,
      isYou: currentUserId != null && entryId == currentUserId,
    );
  }
}
