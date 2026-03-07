import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/challenge_provider.dart';
import '../providers/gamification_provider.dart';
import '../../tasks/providers/task_provider.dart';
import '../widgets/challenge_card.dart';
import '../widgets/daily_goal_ring.dart';
import '../widgets/rank_bar.dart';
import '../widgets/pet_widget.dart';

class ChallengesPage extends ConsumerWidget {
  const ChallengesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenges = ref.watch(challengeProvider);
    final gState = ref.watch(gamificationProvider);
    final tState = ref.watch(taskProvider);

    final doneCount = challenges.where((c) => c.done).length;
    final allDone = challenges.every((c) => c.done);

    // Calculate values for widgets
    final totalXp = tState.doneXp + gState.bonusXp;
    final dailyDone = tState.doneCount;
    final dailyGoal = tState.totalCount > 0 ? tState.totalCount : 5;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new,
                              size: 16, color: AppColors.text),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text('Daily Quest',
                          style:
                              AppTheme.mono(size: 20, weight: FontWeight.w800)),
                    ],
                  ),
                  Row(
                    children: [
                      Text('$doneCount/${challenges.length} done',
                          style:
                              AppTheme.mono(size: 10, color: AppColors.accent)),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.border, height: 1),
            // Progress sections
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                children: [
                  const _SectionLabel('DAILY PROGRESS'),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      DailyGoalRing(done: dailyDone, goal: dailyGoal),
                      const SizedBox(width: 12),
                      StreakCard(
                          streak: gState.currentStreak,
                          shields: gState.shields),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const _SectionLabel('RANK PROGRESS'),
                  const SizedBox(height: 12),
                  RankBar(totalXp: totalXp),
                  const SizedBox(height: 16),
                  const _SectionLabel('YOUR COMPANION'),
                  const SizedBox(height: 12),
                  PetWidget(totalLifetimeTasks: gState.totalLifetimeTasks),
                  const SizedBox(height: 24),
                  const _SectionLabel('ACTIVE CHALLENGES'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: AppTheme.surfaceBox(),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 52,
                          height: 52,
                          child: CustomPaint(
                            painter: _ChallengeRingPainter(
                                progress: challenges.isEmpty
                                    ? 0
                                    : doneCount / challenges.length),
                            child: Center(
                              child: Text('$doneCount/${challenges.length}',
                                  style: AppTheme.mono(
                                      size: 13, color: AppColors.purple)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
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
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...challenges.map((ch) => ChallengeCard(challenge: ch)),
                  const SizedBox(height: 16),
                  // Loot banner
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        AppColors.gold.withValues(alpha: 0.08),
                        AppColors.orange.withValues(alpha: 0.06),
                      ]),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.gold.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        const Text('🎁', style: TextStyle(fontSize: 32)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Bonus Reward!',
                                  style: AppTheme.sans(
                                      size: 14, weight: FontWeight.w800)),
                              const SizedBox(height: 2),
                              Text('Complete all challenges for a mystery box',
                                  style: AppTheme.sans(
                                      size: 10, color: AppColors.subtle)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: allDone
                                ? AppColors.accent.withValues(alpha: 0.1)
                                : AppColors.gold.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: allDone
                                    ? AppColors.accent.withValues(alpha: 0.3)
                                    : AppColors.gold.withValues(alpha: 0.3)),
                          ),
                          child: Text(allDone ? 'RECLAIM' : 'LOCKED',
                              style: AppTheme.mono(
                                  size: 9,
                                  weight: FontWeight.w700,
                                  color: allDone
                                      ? AppColors.accent
                                      : AppColors.gold)),
                        ),
                      ],
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

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: AppTheme.mono(
                size: 9, color: AppColors.subtle, weight: FontWeight.w700)
            .copyWith(letterSpacing: 2));
  }
}

class _ChallengeRingPainter extends CustomPainter {
  final double progress;
  _ChallengeRingPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width / 2, size.height / 2);
    const strokeWidth = 5.5;

    final bgPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final fgPaint = Paint()
      ..color = AppColors.purple
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -pi / 2,
      2 * pi * progress,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(_ChallengeRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
