import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/firebase_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';

class LeaderboardWidget extends StatelessWidget {
  const LeaderboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = context.read<FirebaseService>();
    final userProfile = context.watch<UserModel?>();

    if (userProfile == null || userProfile.currentTeamId == null) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    return StreamBuilder<List<TaskCompletionModel>>(
      stream: firebaseService.getCompletionsForTeam(
        userProfile.currentTeamId!,
        startOfWeek,
      ),
      builder: (context, completionSnapshot) {
        if (!completionSnapshot.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        final completions = completionSnapshot.data!;

        return StreamBuilder<List<UserModel>>(
          stream: firebaseService.getTeamMembers(userProfile.currentTeamId!),
          builder: (context, memberSnapshot) {
            if (!memberSnapshot.hasData) return const SizedBox.shrink();

            final members = memberSnapshot.data!;
            final leaderboardData = _calculateLeaderboard(members, completions);

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.emoji_events_rounded,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Team Standings',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Weekly',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...leaderboardData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final data = entry.value;
                    return _buildLeaderboardRow(index + 1, data);
                  }).toList(),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<_LeaderboardItem> _calculateLeaderboard(
    List<UserModel> members,
    List<TaskCompletionModel> completions,
  ) {
    final Map<String, int> scores = {};
    for (var completion in completions) {
      if (completion.status == 'completed') {
        scores[completion.userId] = (scores[completion.userId] ?? 0) + 1;
      }
    }

    final List<_LeaderboardItem> items = members.map((member) {
      return _LeaderboardItem(
        name: member.displayName,
        score: scores[member.uid] ?? 0,
      );
    }).toList();

    items.sort((a, b) => b.score.compareTo(a.score));
    return items.take(5).toList();
  }

  Widget _buildLeaderboardRow(int rank, _LeaderboardItem item) {
    Color medalColor;
    switch (rank) {
      case 1:
        medalColor = Colors.amber;
        break;
      case 2:
        medalColor = const Color(0xFF94A3B8);
        break;
      case 3:
        medalColor = const Color(0xFFB45309);
        break;
      default:
        medalColor = Colors.transparent;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: medalColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  color: rank <= 3 ? medalColor : AppTheme.greyColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                item.name[0],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.textColor,
                fontSize: 14,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
            ),
            child: Text(
              '${item.score} tasks',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardItem {
  final String name;
  final int score;
  _LeaderboardItem({required this.name, required this.score});
}
