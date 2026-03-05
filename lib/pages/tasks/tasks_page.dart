import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/task_provider.dart';
import '../../providers/gamification_provider.dart';
import '../../providers/effects_provider.dart';
import '../../providers/challenge_provider.dart';
import '../../providers/notification_provider.dart';
import '../../core/utils/xp_calculator.dart';
import '../../widgets/task_card.dart';
import '../../widgets/boss_card.dart';
import '../../widgets/combo_banner.dart';
import '../../widgets/overlays/proof_modal.dart';
import '../../widgets/overlays/notification_panel.dart';
import '../../widgets/overlays/challenges_panel.dart';
import '../../widgets/overlays/spin_wheel_modal.dart';
import '../../widgets/overlays/loot_box_modal.dart';
import '../../models/task_model.dart';

class TasksPage extends ConsumerWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tState = ref.watch(taskProvider);
    final gState = ref.watch(gamificationProvider);
    final unread = ref.watch(unreadCountProvider);
    final pendingChallenges =
        ref.watch(challengeProvider).where((c) => !c.done).length;

    final totalXp = tState.doneXp + gState.bonusXp;
    final level = XpCalculator.level(totalXp);
    final lvlProgress = XpCalculator.levelProgress(totalXp);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _Header(
              level: level,
              lvlProgress: lvlProgress,
              unread: unread,
              pendingChallenges: pendingChallenges,
              spinUsed: gState.spinUsed,
              onNotif: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const NotificationPanel(),
              ),
              onChallenges: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const ChallengesPanel(),
              ),
              onSpin: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => SpinWheelModal(
                  onResult: (seg) =>
                      ref.read(gamificationProvider.notifier).applySpinResult(seg),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 130),
                children: [
                  // Combo & multiplier banners
                  if (gState.combo >= 2) ...[
                    ComboBanner(
                        combo: gState.combo,
                        comboMulti: gState.comboMulti),
                    const SizedBox(height: 7),
                  ],
                  if (gState.multiplier > 1) ...[
                    MultiplierBanner(multiplier: gState.multiplier),
                    const SizedBox(height: 7),
                  ],

                  // Boss card
                  BossCard(boss: gState.boss),
                  const SizedBox(height: 10),

                  // Counter row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          '${tState.doneCount}/${tState.totalCount} DONE',
                          style: AppTheme.mono(
                              size: 10, color: AppColors.subtle)),
                      Text('+$totalXp XP',
                          style: AppTheme.mono(
                              size: 10, color: AppColors.accent)),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Task list
                  ...tState.tasks.map((task) => TaskCard(
                        task: task,
                        effectiveMulti: gState.effectiveMulti,
                        onToggle: () =>
                            _handleToggle(context, ref, task),
                      )),

                  if (tState.tasks.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: Column(
                        children: [
                          const Text('🎉',
                              style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 8),
                          Text('All quests cleared!',
                              style: AppTheme.sans(
                                  size: 14,
                                  weight: FontWeight.w800,
                                  color: AppColors.accent)),
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

  void _handleToggle(BuildContext context, WidgetRef ref, TaskModel task) {
    if (task.done) {
      // Uncomplete
      ref.read(taskProvider.notifier).uncompleteTask(task.id);
      ref
          .read(gamificationProvider.notifier)
          .onTaskUncompleted(task.points, task.bonusEarned);
    } else {
      // Show proof modal
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => ProofModal(
          task: task,
          onSubmit: (bonusXp) => _completeTask(context, ref, task, bonusXp),
        ),
      );
    }
  }

  void _completeTask(
      BuildContext context, WidgetRef ref, TaskModel task, int proofBonus) {
    final gNotifier = ref.read(gamificationProvider.notifier);
    final tNotifier = ref.read(taskProvider.notifier);
    final effects = ref.read(effectsProvider.notifier);
    final challenges = ref.read(challengeProvider.notifier);

    final multiBonus = gNotifier.onTaskCompleted(task.points);
    final totalBonus = multiBonus + proofBonus;
    tNotifier.completeTask(task.id, totalBonus);
    challenges.onTaskCompleted(
        task, ref.read(gamificationProvider).combo);

    // Effects
    effects.triggerConfetti();
    final size = MediaQuery.of(context).size;
    effects.spawnXpFloat(
      x: size.width * 0.2 + (size.width * 0.5),
      y: size.height * 0.4,
      value: task.points + totalBonus,
      multiplier: ref.read(gamificationProvider).effectiveMulti,
    );

    // Toast for combos
    final combo = ref.read(gamificationProvider).combo;
    if (combo == 3) {
      effects.showToast(icon: '🔥', title: '3× Combo!', desc: "You're on fire!");
    } else if (combo == 5) {
      effects.showToast(
          icon: '⚡', title: 'ULTRA COMBO!', desc: '4× XP multiplier!');
    }

    // Boss defeated toast
    final boss = ref.read(gamificationProvider).boss;
    if (boss.isDefeated && !ref.read(gamificationProvider).boss.isDefeated) {
      effects.showToast(
          icon: '🐉',
          title: 'Boss Defeated!',
          desc: '+${boss.reward} XP earned!');
    }

    // Loot box
    if (ref.read(gamificationProvider.notifier).shouldShowLoot) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (context.mounted) {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => LootBoxModal(
              onCollect: (item) =>
                  ref.read(gamificationProvider.notifier).applyLootItem(item.name),
            ),
          );
        }
      });
    }
  }
}

// ── Header ───────────────────────────────────────────────

class _Header extends StatelessWidget {
  final int level;
  final double lvlProgress;
  final int unread;
  final int pendingChallenges;
  final bool spinUsed;
  final VoidCallback onNotif;
  final VoidCallback onChallenges;
  final VoidCallback onSpin;

  const _Header({
    required this.level,
    required this.lvlProgress,
    required this.unread,
    required this.pendingChallenges,
    required this.spinUsed,
    required this.onNotif,
    required this.onChallenges,
    required this.onSpin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.bg, AppColors.bg.withValues(alpha: 0)],
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) =>
                      AppColors.primaryGradient.createShader(bounds),
                  child: Text('QUESTLOG',
                      style: AppTheme.mono(
                          size: 20, weight: FontWeight.w800, color: Colors.white)),
                ),
                Text(
                  _todayLabel(),
                  style: AppTheme.mono(size: 10, color: AppColors.subtle),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    SizedBox(
                      width: 96, height: 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: lvlProgress,
                          backgroundColor: AppColors.surface3,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.accent),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text('LVL $level',
                        style: AppTheme.mono(
                            size: 9, color: AppColors.accent)),
                  ],
                ),
              ],
            ),
          ),
          // Action buttons
          Row(
            children: [
              if (!spinUsed) _IconBtn(
                onTap: onSpin,
                child: const Text('🎰', style: TextStyle(fontSize: 15)),
                borderColor: AppColors.gold.withValues(alpha: 0.35),
              ),
              const SizedBox(width: 7),
              _IconBtn(
                onTap: onChallenges,
                borderColor: AppColors.purple.withValues(alpha: 0.35),
                badge: pendingChallenges > 0 ? pendingChallenges : null,
                badgeColor: AppColors.purple,
                child: const Text('📜', style: TextStyle(fontSize: 15)),
              ),
              const SizedBox(width: 7),
              _IconBtn(
                onTap: onNotif,
                badge: unread > 0 ? unread : null,
                child: const Icon(Icons.notifications_none,
                    size: 16, color: AppColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _todayLabel() {
    final now = DateTime.now();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }
}

class _IconBtn extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color borderColor;
  final int? badge;
  final Color badgeColor;

  const _IconBtn({
    required this.child,
    required this.onTap,
    this.borderColor = AppColors.border,
    this.badge,
    this.badgeColor = AppColors.red,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: borderColor),
            ),
            alignment: Alignment.center,
            child: child,
          ),
          if (badge != null)
            Positioned(
              top: -3, right: -3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text('$badge',
                    style: AppTheme.mono(
                        size: 8, color: Colors.white, weight: FontWeight.w800)),
              ),
            ),
        ],
      ),
    );
  }
}
