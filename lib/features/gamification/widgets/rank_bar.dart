import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/xp_calculator.dart';

class RankBar extends StatelessWidget {
  final int totalXp;
  const RankBar({super.key, required this.totalXp});

  @override
  Widget build(BuildContext context) {
    final rank = XpCalculator.currentRank(totalXp);
    final next = XpCalculator.nextRank(totalXp);
    final progress = XpCalculator.rankProgress(totalXp);
    final toNext = next != null
        ? '${next.minXp - totalXp} XP to ${next.name}'
        : 'Max rank!';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: AppTheme.surfaceBox(),
      child: Row(
        children: [
          Text(rank.icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(rank.name,
                    style: AppTheme.mono(
                        size: 10, weight: FontWeight.w800, color: rank.color)),
                Text(toNext,
                    style: AppTheme.sans(size: 8, color: AppColors.subtle)),
                if (next != null) ...[
                  const SizedBox(height: 3),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 3,
                      backgroundColor: AppColors.surface3,
                      valueColor: AlwaysStoppedAnimation<Color>(rank.color),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}