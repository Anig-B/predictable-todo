import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive_scale.dart';
import '../providers/challenge_provider.dart';
import '../providers/gamification_provider.dart';
import '../widgets/challenge_card.dart';
import '../widgets/loot_box_modal.dart';

class ChallengesPage extends ConsumerWidget {
  const ChallengesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rs = ResponsiveScale(context);
    final challenges = ref.watch(challengeProvider);
    final gState = ref.watch(gamificationProvider);

    final doneCount = challenges.where((c) => c.done).length;
    final rewardGoal = 3;
    final allDone = doneCount >= rewardGoal;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: rs.tabletCenter(600)(
          Column(
            children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: rs.p(16), vertical: rs.p(16)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          padding: rs.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(rs.p(10)),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Icon(Icons.arrow_back_ios_new,
                              size: rs.s(16), color: AppColors.text),
                        ),
                      ),
                      SizedBox(width: rs.p(16)),
                      Text('Daily Quest',
                          style:
                              AppTheme.mono(size: rs.f(20), weight: FontWeight.w800)),
                    ],
                  ),
                  Row(
                    children: [
                      Text('${doneCount.clamp(0, rewardGoal)}/$rewardGoal done',
                          style:
                              AppTheme.mono(size: rs.f(10), color: AppColors.accent)),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.border, height: 1),
            // Progress sections
            Expanded(
              child: ListView(
                padding: rs.fromLTRB(16, 8, 16, 100),
                children: [
                  const _SectionLabel('ACTIVE CHALLENGES'),
                  SizedBox(height: rs.p(12)),
                  Container(
                    padding: rs.all(16),
                    decoration: AppTheme.surfaceBox(),
                    child: Row(
                      children: [
                        SizedBox(
                          width: rs.s(52),
                          height: rs.s(52),
                          child: CustomPaint(
                            painter: _ChallengeRingPainter(
                                progress: challenges.isEmpty
                                    ? 0
                                    : doneCount.clamp(0, rewardGoal) / rewardGoal),
                            child: Center(
                              child: Text('${doneCount.clamp(0, rewardGoal)}/$rewardGoal',
                                  style: AppTheme.mono(
                                      size: rs.f(13), color: AppColors.purple)),
                            ),
                          ),
                        ),
                        SizedBox(width: rs.p(16)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Daily Challenges',
                                  style: AppTheme.sans(
                                      size: rs.f(13), weight: FontWeight.w800)),
                              SizedBox(height: rs.p(2)),
                              Text('Resets in 08:14:32',
                                  style: AppTheme.sans(
                                      size: rs.f(10), color: AppColors.subtle)),
                              SizedBox(height: rs.p(4)),
                              Text('Complete any 3 of 5 quests for a reward 🎁',
                                  style: AppTheme.sans(
                                      size: rs.f(9), color: AppColors.subtle)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: rs.p(10)),
                  ...challenges.map((ch) => ChallengeCard(challenge: ch)),
                  SizedBox(height: rs.p(16)),
                  // Loot banner
                  Opacity(
                    opacity: challenges.isEmpty ? 0.5 : 1.0,
                    child: Container(
                      padding: rs.all(18),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          AppColors.gold.withValues(alpha: 0.08),
                          AppColors.orange.withValues(alpha: 0.06),
                        ]),
                        borderRadius: BorderRadius.circular(rs.p(20)),
                        border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          Text('🎁', style: TextStyle(fontSize: rs.f(32))),
                          SizedBox(width: rs.p(16)),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              Text('Daily Bonus!',
                                  style: AppTheme.sans(
                                      size: rs.f(14), weight: FontWeight.w800)),
                              SizedBox(height: rs.p(2)),
                              Text(
                                  gState.dailyQuestRewardClaimed
                                      ? 'Collected! Come back tomorrow.'
                                      : 'Complete any 3 daily quests for a reward box',
                                  style: AppTheme.sans(
                                      size: rs.f(10), color: AppColors.subtle)),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: (allDone && !gState.dailyQuestRewardClaimed)
                                ? () {
                                    ref
                                        .read(gamificationProvider.notifier)
                                        .claimDailyQuestReward();
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      useRootNavigator: false,
                                      useSafeArea: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) => LootBoxModal(
                                        onCollect: (item) => ref
                                            .read(gamificationProvider.notifier)
                                            .applyLootItem(item.name),
                                      ),
                                    );
                                  }
                                : null,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.symmetric(
                                  horizontal: rs.p(12), vertical: rs.p(6)),
                              decoration: BoxDecoration(
                                color: gState.dailyQuestRewardClaimed
                                    ? AppColors.surface2
                                    : (allDone
                                        ? AppColors.accent.withValues(alpha: 0.1)
                                        : AppColors.gold.withValues(alpha: 0.1)),
                                borderRadius: BorderRadius.circular(rs.p(10)),
                                border: Border.all(
                                    color: gState.dailyQuestRewardClaimed
                                        ? AppColors.border
                                        : (allDone
                                            ? AppColors.accent.withValues(alpha: 0.3)
                                            : AppColors.gold.withValues(alpha: 0.3))),
                              ),
                              child: Text(
                                  gState.dailyQuestRewardClaimed
                                      ? 'CLAIMED'
                                      : (allDone ? 'RECLAIM' : 'LOCKED'),
                                  style: AppTheme.mono(
                                      size: rs.f(9),
                                      weight: FontWeight.w700,
                                      color: gState.dailyQuestRewardClaimed
                                          ? AppColors.muted
                                          : (allDone
                                              ? AppColors.accent
                                              : AppColors.gold))),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
