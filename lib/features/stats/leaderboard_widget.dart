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

    // Get stats for the current week
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

    return StreamBuilder<List<TaskCompletionModel>>(
      stream: firebaseService.getCompletionsForTeam(
        userProfile.currentTeamId!,
        startOfWeek,
      ),
      builder: (context, completionSnapshot) {
        if (!completionSnapshot.hasData)
          return const Center(child: CircularProgressIndicator());

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
                color: AppTheme.secondaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Team Leaderboard 🏆',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  ...leaderboardData.asMap().entries.map((entry) {
                    final index = entry.key;
                    // Fix: Access the value property of the entry
                    final data = entry.value;
                    return _buildLeaderboardItem(index + 1, data);
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
        photoUrl: member.photoUrl,
        score: scores[member.uid] ?? 0,
      );
    }).toList();

    items.sort((a, b) => b.score.compareTo(a.score));
    return items.take(5).toList(); // Top 5
  }

  Widget _buildLeaderboardItem(int rank, _LeaderboardItem item) {
    Color rankColor;
    if (rank == 1)
      rankColor = Colors.amber;
    else if (rank == 2)
      rankColor = Colors.grey.shade400;
    else if (rank == 3)
      rankColor = Colors.orangeAccent;
    else
      rankColor = Colors.white;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 30,
            alignment: Alignment.center,
            child: Text(
              '#$rank',
              style: TextStyle(
                color: rankColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 16,
            backgroundImage: item.photoUrl.isNotEmpty
                ? NetworkImage(item.photoUrl)
                : null,
            backgroundColor: AppTheme.primaryColor,
            child: item.photoUrl.isEmpty
                ? Text(
                    item.name.isNotEmpty ? item.name[0] : '?',
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${item.score} tasks',
              style: const TextStyle(
                fontSize: 12,
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
  final String photoUrl;
  final int score;

  _LeaderboardItem({
    required this.name,
    required this.photoUrl,
    required this.score,
  });
}
