class LeaderboardEntry {
  final String name;
  final int xp;
  final String avatar;
  final int level;
  final int streak;
  final int tasksWeek;
  final bool isYou;

  const LeaderboardEntry({
    required this.name,
    required this.xp,
    required this.avatar,
    required this.level,
    required this.streak,
    required this.tasksWeek,
    this.isYou = false,
  });
}
