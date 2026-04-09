import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../models/leaderboard_entry_model.dart';
import '../../../shared/widgets/app_avatar.dart';

class Podium extends StatelessWidget {
  final List<LeaderboardEntry> top3;
  final void Function(LeaderboardEntry entry) onTap;

  const Podium({super.key, required this.top3, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (top3.isEmpty) return const SizedBox.shrink();

    final first = top3.isNotEmpty ? top3[0] : null;
    final second = top3.length > 1 ? top3[1] : null;
    final third = top3.length > 2 ? top3[2] : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24, top: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (second != null) _PodiumItem(entry: second, rank: 2, height: 100, onTap: () => onTap(second)),
          if (first != null) _PodiumItem(entry: first, rank: 1, height: 140, onTap: () => onTap(first)),
          if (third != null) _PodiumItem(entry: third, rank: 3, height: 80, onTap: () => onTap(third)),
        ],
      ),
    );
  }
}

class _PodiumItem extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;
  final double height;
  final VoidCallback onTap;

  const _PodiumItem({
    required this.entry,
    required this.rank,
    required this.height,
    required this.onTap,
  });

  Color get _color {
    if (rank == 1) return AppColors.gold;
    if (rank == 2) return const Color(0xFFAAAAAA);
    if (rank == 3) return const Color(0xFFCD7F32);
    return AppColors.surface2;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Avatar with floating animation
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 1500 + (rank * 200)),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                final offset = sin(value * 2 * pi) * 4;
                return Transform.translate(
                  offset: Offset(0, offset),
                  child: AppAvatar(
                      avatar: entry.avatar,
                      size: rank == 1 ? 60 : 50,
                      fontSize: rank == 1 ? 38 : 32),
                );
              },
              onEnd: () {}, 
            ),
            const SizedBox(height: 8),

            // Name
            Text(
              entry.name,
              style: AppTheme.sans(
                  size: 11,
                  weight: FontWeight.w700,
                  color: entry.isYou ? AppColors.accent : AppColors.text),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // XP
            Text(
              '${entry.xp} XP',
              style: AppTheme.mono(size: 9, color: AppColors.accent),
            ),
            const SizedBox(height: 8),

            // Pillar
            Container(
              height: height,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _color.withValues(alpha: 0.3),
                    _color.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(8)),
                border:
                    Border.all(color: _color.withValues(alpha: 0.45), width: 1.5),
                boxShadow: rank == 1
                    ? [
                        BoxShadow(
                          color: _color.withValues(alpha: 0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        )
                      ]
                    : null,
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        rank == 1 ? '👑' : '$rank',
                        style: rank == 1
                            ? const TextStyle(fontSize: 24)
                            : AppTheme.mono(
                                size: 24,
                                weight: FontWeight.w900,
                                color: _color.withValues(alpha: 0.5)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
