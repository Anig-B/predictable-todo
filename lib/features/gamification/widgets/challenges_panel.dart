import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/challenge_provider.dart';
import '../providers/gamification_provider.dart';
import '../../tasks/providers/task_provider.dart';
import 'challenge_card.dart';
import 'pet_widget.dart';
import 'rank_bar.dart';
import 'daily_goal_ring.dart';

class ChallengesPanel extends ConsumerWidget {
  const ChallengesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenges = ref.watch(challengeProvider);
    final gState = ref.watch(gamificationProvider);
    final tState = ref.watch(taskProvider);
    final totalXp = tState.doneXp + gState.bonusXp;
    final doneCount = challenges.where((c) => c.done).length;
    final allDone = challenges.every((c) => c.done);

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: AppTheme.sheetBox,
      child: Column(
        children: [
          const SizedBox(height: 12),
          AppTheme.handleBar,
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('📜 Daily Offers',
                    style: AppTheme.mono(size: 14, weight: FontWeight.w700)),
                Row(
                  children: [
                    Text('$doneCount/${challenges.length} done',
                        style: AppTheme.mono(
                            size: 10, color: AppColors.accent)),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text('✕',
                          style: AppTheme.sans(
                              size: 14, color: AppColors.muted)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.border, height: 1),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                RankBar(totalXp: totalXp),
                const SizedBox(height: 8),
                Row(
                  children: [
                    DailyGoalRing(done: tState.doneCount, goal: 5),
                    const SizedBox(width: 8),
                    StreakCard(streak: 30, shields: gState.shields),
                  ],
                ),
                const SizedBox(height: 8),
                PetWidget(totalLifetimeTasks: gState.totalLifetimeTasks),
                const SizedBox(height: 12),
                // Challenge progress ring
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.purple.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                        color: AppColors.purple.withValues(alpha: 0.18)),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 52, height: 52,
                        child: CustomPaint(
                          painter: _ChallengeRingPainter(
                              progress: doneCount / challenges.length),
                          child: Center(
                            child: Text('$doneCount/${challenges.length}',
                                style: AppTheme.mono(
                                    size: 13, color: AppColors.purple)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Daily Challenges',
                              style: AppTheme.sans(
                                  size: 13, weight: FontWeight.w800)),
                          const SizedBox(height: 2),
                          Text('Resets in 08:14:32',
                              style: AppTheme.sans(
                                  size: 10, color: AppColors.subtle)),
                          const SizedBox(height: 4),
                          Text('Complete all 3 for a bonus 🎁',
                              style: AppTheme.sans(
                                  size: 9, color: AppColors.subtle)),
                        ],
                      ),
                    ],
                  ),
                ),
                ...challenges.map((ch) => ChallengeCard(challenge: ch)),
                const SizedBox(height: 4),
                // Loot banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      AppColors.gold.withValues(alpha: 0.06),
                      AppColors.orange.withValues(alpha: 0.04),
                    ]),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.14)),
                  ),
                  child: Row(
                    children: [
                      const Text('🎁', style: TextStyle(fontSize: 26)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Complete All Challenges',
                                style: AppTheme.sans(size: 11, weight: FontWeight.w800)),
                            const SizedBox(height: 1),
                            Text('Earn a mystery loot box',
                                style: AppTheme.sans(size: 9, color: AppColors.subtle)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: allDone
                              ? AppColors.accent.withValues(alpha: 0.1)
                              : AppColors.gold.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          allDone ? '✓ Claim' : '🔒 Locked',
                          style: AppTheme.mono(
                              size: 10,
                              color: allDone
                                  ? AppColors.accent
                                  : AppColors.gold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeRingPainter extends CustomPainter {
  final double progress;
  const _ChallengeRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const r = 21.0;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    paint.color = AppColors.surface3;
    canvas.drawCircle(Offset(cx, cy), r, paint);

    paint.color = AppColors.purple;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -pi / 2,
      2 * pi * progress,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_ChallengeRingPainter old) => old.progress != progress;
}
