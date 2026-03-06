import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../tasks/providers/task_provider.dart';
import '../../gamification/providers/gamification_provider.dart';
import '../../../core/utils/xp_calculator.dart';
import '../../../core/data/seed_data.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tState = ref.watch(taskProvider);
    final gState = ref.watch(gamificationProvider);
    final totalXp = tState.doneXp + gState.bonusXp;
    final level = XpCalculator.level(totalXp);
    final lvlProgress = XpCalculator.levelProgress(totalXp);
    final rank = XpCalculator.currentRank(totalXp);

    final hasTasks = tState.totalCount > 0;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 130),
          children: [
            // ── Avatar & Name ───────────────────────────
            Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text('🧑‍💻', style: TextStyle(fontSize: 30)),
                  ),
                ),
                const SizedBox(height: 10),
                Text('Quest Master',
                    style: AppTheme.sans(size: 17, weight: FontWeight.w800)),
                Text('#QUESTLOG',
                    style: AppTheme.mono(size: 9, color: AppColors.accent)),
              ],
            ),
            const SizedBox(height: 16),

            // ── XP Bar Card ─────────────────────────────
            Container(
              padding: const EdgeInsets.all(12),
              decoration: AppTheme.surfaceBox(),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text('LVL $level',
                          style: AppTheme.mono(
                              size: 15,
                              weight: FontWeight.w800,
                              color: AppColors.accent)),
                      Text('$totalXp / ${level * XpCalculator.xpPerLevel} XP',
                          style:
                              AppTheme.mono(size: 10, color: AppColors.subtle)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: lvlProgress,
                      minHeight: 6,
                      backgroundColor: AppColors.surface3,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppColors.accent),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // ── Stat Grid ───────────────────────────────
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2,
              children: [
                _StatBox(value: '${tState.doneCount}', label: 'Tasks Done'),
                _StatBox(value: '30', label: 'Day Streak'),
                _StatBox(value: rank.name, label: 'Rank'),
                _StatBox(
                    value:
                        '${SeedData.badges.where((b) => b['unlocked'] == true).length}',
                    label: 'Badges'),
              ],
            ),
            const SizedBox(height: 10),

            // ── Rank Tiers ──────────────────────────────
            Row(
              children: XpCalculator.rankTiers.map((tier) {
                final earned = totalXp >= tier.minXp;
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: earned ? AppColors.surface2 : AppColors.surface,
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: earned
                            ? tier.color.withValues(alpha: 0.3)
                            : AppColors.border,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(tier.icon, style: const TextStyle(fontSize: 16)),
                        const SizedBox(height: 3),
                        Text(tier.name,
                            style: AppTheme.sans(
                                size: 7,
                                weight: FontWeight.w700,
                                color: earned ? tier.color : AppColors.subtle)),
                        Text('${tier.minXp}',
                            style: AppTheme.mono(
                                size: 6, color: AppColors.subtle)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // ── Tabs ────────────────────────────────────
            Container(
              decoration: AppTheme.surfaceBox(radius: 10),
              padding: const EdgeInsets.all(3),
              child: TabBar(
                controller: _tabCtrl,
                indicator: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelStyle: AppTheme.sans(size: 10, weight: FontWeight.w700),
                unselectedLabelStyle:
                    AppTheme.sans(size: 10, color: AppColors.muted),
                labelColor: AppColors.bg,
                unselectedLabelColor: AppColors.muted,
                tabs: const [
                  Tab(text: 'Activity'),
                  Tab(text: 'Badges'),
                  Tab(text: 'Skills'),
                  Tab(text: 'Milestones'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 380,
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _ActivityTab(log: ref.watch(taskProvider).activityLog),
                  const _BadgesTab(),
                  _SkillsTab(
                    skillTree: gState.skillTree,
                    skillPoints: gState.skillPoints,
                    onUnlock: (id) {
                      final ok = ref
                          .read(gamificationProvider.notifier)
                          .unlockSkill(id);
                      if (!ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Not enough skill points!',
                                style: AppTheme.sans(size: 12)),
                            backgroundColor: AppColors.surface2,
                          ),
                        );
                      }
                    },
                  ),
                  const _MilestonesTab(),
                ],
              ),
            ),

            // ── Danger Zone ─────────────────────────────
            Container(
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.red.withValues(alpha: 0.04),
                borderRadius: BorderRadius.circular(13),
                border:
                    Border.all(color: AppColors.red.withValues(alpha: 0.18)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          size: 14, color: AppColors.red),
                      const SizedBox(width: 5),
                      Text('DANGER ZONE',
                          style: AppTheme.mono(
                                  size: 9,
                                  color: AppColors.red,
                                  weight: FontWeight.w700)
                              .copyWith(letterSpacing: 1.8)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Clear All Data',
                                style: TextStyle(
                                    fontWeight: FontWeight.w800, fontSize: 12)),
                            SizedBox(height: 2),
                            Text('Reset all tasks and progress',
                                style: TextStyle(
                                    fontSize: 10, color: AppColors.muted)),
                          ],
                        ),
                      ),
                      // use TextButton so it can be disabled when there are no tasks
                      TextButton(
                        onPressed: hasTasks
                            ? () async {
                                final messenger = ScaffoldMessenger.of(context);
                                final confirmed = await _confirmClear(
                                    context, tState.totalCount);
                                if (!confirmed || !mounted) return;
                                ref.read(taskProvider.notifier).clearAll();
                                ref.read(gamificationProvider.notifier).reset();
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text('All data cleared',
                                        style: AppTheme.sans(size: 12)),
                                    backgroundColor:
                                        AppColors.red.withValues(alpha: 0.2),
                                  ),
                                );
                              }
                            : null,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          backgroundColor: hasTasks
                              ? AppColors.red.withValues(alpha: 0.1)
                              : AppColors.surface3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                            side: BorderSide(
                              color: hasTasks
                                  ? AppColors.red.withValues(alpha: 0.3)
                                  : AppColors.border,
                            ),
                          ),
                        ),
                        child: Text('Clear All',
                            style: AppTheme.sans(
                                size: 11,
                                weight: FontWeight.w800,
                                color: hasTasks
                                    ? AppColors.red
                                    : AppColors.muted)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Shows a blocking confirmation dialog and returns true if the user
  /// agreed to wipe the tasks.
  Future<bool> _confirmClear(BuildContext context, int taskCount) async {
    if (taskCount == 0) return false;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => Dialog(
        backgroundColor: AppColors.surface2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: AppColors.red.withValues(alpha: 0.25)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🗑️', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Text('Clear Everything?',
                  style: AppTheme.mono(size: 16, weight: FontWeight.w800)),
              const SizedBox(height: 8),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTheme.sans(size: 12, color: AppColors.muted),
                  children: [
                    const TextSpan(text: 'This will permanently delete '),
                    TextSpan(
                      text: '$taskCount tasks',
                      style: AppTheme.mono(size: 12, color: AppColors.red),
                    ),
                    const TextSpan(
                        text: ' and all your progress. This cannot be undone.'),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              GestureDetector(
                onTap: () => Navigator.of(dialogCtx).pop(true),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    gradient: AppColors.dangerGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.red.withValues(alpha: 0.3),
                          blurRadius: 18)
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text('Yes, Clear Everything',
                      style: AppTheme.sans(
                          size: 13,
                          weight: FontWeight.w800,
                          color: Colors.white)),
                ),
              ),
              const SizedBox(height: 9),
              GestureDetector(
                onTap: () => Navigator.of(dialogCtx).pop(false),
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text('Cancel',
                      style: AppTheme.sans(
                          size: 11,
                          color: AppColors.subtle,
                          weight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }
}

// ── Activity Tab ─────────────────────────────────────────

class _ActivityTab extends StatelessWidget {
  final List<dynamic> log;
  const _ActivityTab({required this.log});

  @override
  Widget build(BuildContext context) {
    if (log.isEmpty) {
      return Center(
        child: Text('No activity yet',
            style: AppTheme.sans(size: 12, color: AppColors.subtle)),
      );
    }
    return ListView.builder(
      itemCount: log.length,
      itemBuilder: (_, i) {
        final item = log[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 5),
          padding: const EdgeInsets.all(9),
          decoration: AppTheme.surfaceBox(radius: 10),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(item.icon, style: const TextStyle(fontSize: 13)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.task,
                        style: AppTheme.sans(size: 11, weight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis),
                    Text(item.time,
                        style: AppTheme.mono(size: 8, color: AppColors.subtle)),
                  ],
                ),
              ),
              Text('+${item.points}',
                  style: AppTheme.mono(size: 10, color: AppColors.accent)),
            ],
          ),
        );
      },
    );
  }
}

// ── Badges Tab ───────────────────────────────────────────

class _BadgesTab extends StatelessWidget {
  const _BadgesTab();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: SeedData.badges.length,
      itemBuilder: (_, i) {
        final badge = SeedData.badges[i];
        final unlocked = badge['unlocked'] as bool;
        return AnimatedOpacity(
          opacity: unlocked ? 1.0 : 0.22,
          duration: const Duration(milliseconds: 300),
          child: ColorFiltered(
            colorFilter: unlocked
                ? const ColorFilter.mode(Colors.transparent, BlendMode.color)
                : AppColors.grayscaleFilter,
            child: Container(
              decoration: AppTheme.surfaceBox(radius: 11),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(badge['icon'] as String,
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 2),
                  Text(badge['name'] as String,
                      style: AppTheme.sans(
                          size: 7,
                          color: AppColors.subtle,
                          weight: FontWeight.w700),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Skills Tab ───────────────────────────────────────────

class _SkillsTab extends StatelessWidget {
  final List<dynamic> skillTree;
  final int skillPoints;
  final void Function(String id) onUnlock;

  const _SkillsTab({
    required this.skillTree,
    required this.skillPoints,
    required this.onUnlock,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Text('Skill Points: ',
                  style: AppTheme.sans(size: 11, color: AppColors.muted)),
              Text('$skillPoints SP',
                  style: AppTheme.mono(size: 11, color: AppColors.accent)),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 7,
              mainAxisSpacing: 7,
            ),
            itemCount: skillTree.length,
            itemBuilder: (_, i) {
              final node = skillTree[i];
              return GestureDetector(
                onTap: () {
                  if (!node.unlocked) onUnlock(node.id);
                },
                child: AnimatedOpacity(
                  opacity: node.unlocked ? 1.0 : 0.34,
                  duration: const Duration(milliseconds: 250),
                  child: Container(
                    decoration: BoxDecoration(
                      color: node.unlocked
                          ? AppColors.accent.withValues(alpha: 0.04)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                        color: node.unlocked
                            ? AppColors.accent.withValues(alpha: 0.28)
                            : AppColors.border,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(node.icon, style: const TextStyle(fontSize: 20)),
                        const SizedBox(height: 3),
                        Text(node.name,
                            style:
                                AppTheme.sans(size: 8, weight: FontWeight.w700),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 2),
                        Text(
                          node.unlocked ? node.desc : '${node.cost} SP',
                          style: AppTheme.mono(
                            size: 7,
                            color: node.unlocked
                                ? AppColors.accent
                                : AppColors.subtle,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ── Milestones Tab ───────────────────────────────────────

class _MilestonesTab extends StatelessWidget {
  const _MilestonesTab();

  static const _milestones = [
    {'icon': '🎯', 'title': 'First Quest', 'date': 'Jan 1'},
    {'icon': '🔥', 'title': '7-Day Streak', 'date': 'Jan 7'},
    {'icon': '⚡', 'title': '100 XP Earned', 'date': 'Jan 10'},
    {'icon': '🏆', 'title': 'First Boss Defeated', 'date': 'Jan 15'},
    {'icon': '💎', 'title': 'Diamond Rank', 'date': 'Feb 2'},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _milestones.length,
      itemBuilder: (_, i) {
        final m = _milestones[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 5),
          padding: const EdgeInsets.all(11),
          decoration: AppTheme.surfaceBox(radius: 10),
          child: Row(
            children: [
              Text(m['icon']!, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(m['title']!,
                    style: AppTheme.sans(size: 11, weight: FontWeight.w700)),
              ),
              Text(m['date']!,
                  style: AppTheme.mono(size: 9, color: AppColors.accent)),
            ],
          ),
        );
      },
    );
  }
}

// ── Shared ───────────────────────────────────────────────

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppTheme.surfaceBox(radius: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value,
              style: AppTheme.mono(
                  size: 20, weight: FontWeight.w800, color: AppColors.text)),
          const SizedBox(height: 2),
          Text(label,
              style: AppTheme.sans(
                  size: 9, color: AppColors.subtle, weight: FontWeight.w600)),
        ],
      ),
    );
  }
}
