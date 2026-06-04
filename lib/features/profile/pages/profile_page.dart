import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../tasks/providers/task_provider.dart';
import '../../tasks/models/activity_log_model.dart';
import '../../gamification/providers/gamification_provider.dart';
import '../../gamification/models/skill_node_model.dart';
import '../../../core/utils/xp_calculator.dart';
import '../../../core/data/seed_data.dart';
import '../providers/profile_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../widgets/user_avatar.dart';
import 'edit_profile_page.dart';

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
    final totalXp = gState.totalXp;
    final level = XpCalculator.level(totalXp);
    final lvlProgress = XpCalculator.levelProgress(totalXp);
    final rank = XpCalculator.currentRank(totalXp);

    final xpInLevel = XpCalculator.xpInLevel(totalXp);
    final profile = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 130),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => ref.read(authRepositoryProvider).signOut(),
                  icon: const Icon(Icons.logout_rounded,
                      size: 20, color: AppColors.muted),
                  tooltip: 'Sign Out',
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: tState.totalCount == 0 && totalXp == 0
                      ? null
                      : () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final confirmed = await _confirmClear(
                              context, tState.totalCount, totalXp);
                          if (!confirmed || !mounted) return;
                          await ref.read(taskProvider.notifier).clearAll();
                          await ref.read(gamificationProvider.notifier).reset();
                          await ref.read(profileProvider.notifier).reset();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('All data cleared from server',
                                  style: AppTheme.sans(size: 12)),
                              backgroundColor:
                                  AppColors.red.withValues(alpha: 0.2),
                            ),
                          );
                        },
                  icon: Icon(
                    Icons.delete_sweep_rounded,
                    size: 20,
                    color: tState.totalCount == 0 && totalXp == 0
                        ? AppColors.muted
                        : AppColors.red,
                  ),
                  tooltip: 'Clear All Data',
                ),
              ],
            ),
            // ── Avatar & Name ───────────────────────────
            Column(
              children: [
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfilePage()),
                  ),
                  child: UserAvatar(avatar: profile.avatar),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(width: 32), // Spacer for balance
                    Text(profile.name,
                        style:
                            AppTheme.sans(size: 17, weight: FontWeight.w800)),
                    const SizedBox(width: 4),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const EditProfilePage()),
                      ),
                      icon: const Icon(Icons.edit_note_rounded,
                          size: 18, color: AppColors.muted),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('USER ID: ${profile.shortId}',
                        style: AppTheme.mono(
                            size: 10,
                            color: AppColors.muted,
                            weight: FontWeight.w700)),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: profile.shortId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('ID Copied!',
                                style: AppTheme.sans(size: 11)),
                            backgroundColor: AppColors.surface2,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: const Icon(Icons.copy_rounded,
                          size: 12, color: AppColors.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(profile.tagline,
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
                      // Show XP within current level, not cumulative total
                      Text('$xpInLevel / ${XpCalculator.xpPerLevel} XP',
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
                _StatBox(
                    value: '${gState.currentStreak}d', label: 'Day Streak'),
                _StatBox(value: rank.name, label: 'Rank'),
                _StatBox(
                    value: '${gState.unlockedBadges.length}', label: 'Badges'),
              ],
            ),
            const SizedBox(height: 10),

            // ── Rank Tiers ──────────────────────────────
            _buildRankCard(totalXp),
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
                  _BadgesTab(
                    unlockedBadges: gState.unlockedBadges,
                    selectedBadges: gState.selectedBadges,
                    onToggle: (badge) => ref
                        .read(gamificationProvider.notifier)
                        .toggleBadgeSelection(badge),
                  ),
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
                  _MilestonesTab(
                    tasksCompleted: tState.doneCount,
                    totalXp: totalXp,
                    streak: gState.currentStreak,
                    bossDefeated: gState.boss.isDefeated,
                    rank: rank.name,
                    unlockedSkillsCount:
                        gState.skillTree.where((s) => s.unlocked).length,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmClear(
      BuildContext context, int taskCount, int totalXp) async {
    if (taskCount == 0 && totalXp == 0) return false;
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
                    if (taskCount > 0)
                      TextSpan(
                        text: '$taskCount tasks ',
                        style: AppTheme.mono(size: 12, color: AppColors.red),
                      ),
                    if (taskCount > 0 && totalXp > 0)
                      const TextSpan(text: 'and '),
                    if (totalXp > 0)
                      TextSpan(
                        text: 'all progress ',
                        style: AppTheme.mono(size: 12, color: AppColors.red),
                      ),
                    const TextSpan(text: '. This cannot be undone.'),
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

  Widget _buildRankCard(int totalXp) {
    final current = XpCalculator.currentRank(totalXp);
    final next = XpCalculator.nextRank(totalXp);
    final progress = XpCalculator.rankProgress(totalXp);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            current.color.withValues(alpha: 0.15),
            AppColors.surface,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: current.color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(current.icon, style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CURRENT RANK',
                        style: AppTheme.mono(
                            size: 9,
                            color: AppColors.subtle,
                            weight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(current.name,
                        style: AppTheme.sans(
                            size: 22,
                            weight: FontWeight.w900,
                            color: current.color)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (next != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('NEXT',
                        style: AppTheme.mono(
                            size: 8,
                            color: AppColors.subtle,
                            weight: FontWeight.w800)),
                    Text(next.icon, style: const TextStyle(fontSize: 24)),
                    Text(next.name,
                        style: AppTheme.sans(
                            size: 10,
                            color: AppColors.subtle,
                            weight: FontWeight.w600)),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (next != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: AppColors.surface3,
                valueColor: AlwaysStoppedAnimation<Color>(current.color),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${current.minXp} XP',
                    style: AppTheme.mono(size: 9, color: AppColors.subtle)),
                Text(
                    '${totalXp - current.minXp} / ${next.minXp - current.minXp} XP to ${next.name}',
                    style: AppTheme.mono(size: 9, color: current.color)),
              ],
            ),
          ],
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => _showRankSheet(context, totalXp),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.list_rounded,
                      size: 12, color: AppColors.muted),
                  const SizedBox(width: 6),
                  Text('See all ranks',
                      style: AppTheme.sans(
                          size: 11,
                          color: AppColors.muted,
                          weight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRankSheet(BuildContext context, int totalXp) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 20),
            Text('RANK TIERS',
                style: AppTheme.mono(
                    size: 14, weight: FontWeight.w900, color: AppColors.text)),
            const SizedBox(height: 20),
            ...XpCalculator.rankTiers.map((tier) {
              final earned = totalXp >= tier.minXp;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: earned
                      ? tier.color.withValues(alpha: 0.08)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: earned
                        ? tier.color.withValues(alpha: 0.3)
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Text(tier.icon, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tier.name,
                              style: AppTheme.sans(
                                  size: 15,
                                  weight: FontWeight.w800,
                                  color:
                                      earned ? tier.color : AppColors.subtle)),
                          Text('${tier.minXp}+ XP',
                              style: AppTheme.mono(
                                  size: 10, color: AppColors.muted)),
                        ],
                      ),
                    ),
                    if (earned)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: tier.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text('EARNED',
                            style: AppTheme.mono(
                                size: 8,
                                color: tier.color,
                                weight: FontWeight.w900)),
                      ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

// ── Activity Tab ─────────────────────────────────────────

class _ActivityTab extends StatelessWidget {
  final List<ActivityLogModel> log;
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
  final List<String> unlockedBadges;
  final List<String> selectedBadges;
  final void Function(String) onToggle;

  const _BadgesTab({
    required this.unlockedBadges,
    required this.selectedBadges,
    required this.onToggle,
  });

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
        final badgeName = badge['name'] as String;
        final unlocked = unlockedBadges.contains(badgeName);
        final selected = selectedBadges.contains(badgeName);

        return GestureDetector(
          onTap: unlocked ? () => onToggle(badgeName) : null,
          child: AnimatedOpacity(
            opacity: unlocked ? 1.0 : 0.22,
            duration: const Duration(milliseconds: 300),
            child: ColorFiltered(
              colorFilter: unlocked
                  ? const ColorFilter.mode(Colors.transparent, BlendMode.color)
                  : AppColors.grayscaleFilter,
              child: Container(
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.accent.withValues(alpha: 0.1)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: selected ? AppColors.accent : AppColors.border,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(badge['icon'] as String,
                        style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 2),
                    Text(badgeName,
                        style: AppTheme.sans(
                            size: 7,
                            color:
                                selected ? AppColors.accent : AppColors.subtle,
                            weight: FontWeight.w700),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
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
  final List<SkillNodeModel> skillTree;
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
  final int tasksCompleted;
  final int totalXp;
  final int streak;
  final bool bossDefeated;
  final String rank;
  final int unlockedSkillsCount;

  const _MilestonesTab({
    required this.tasksCompleted,
    required this.totalXp,
    required this.streak,
    required this.bossDefeated,
    required this.rank,
    required this.unlockedSkillsCount,
  });

  @override
  Widget build(BuildContext context) {
    final milestones = [
      _Milestone(
        icon: '🎯',
        title: 'First Quest',
        unlocked: tasksCompleted >= 1,
        desc: 'Complete your first task',
      ),
      _Milestone(
        icon: '⚡',
        title: '100 XP Earned',
        unlocked: totalXp >= 100,
        desc: '$totalXp / 100 XP',
      ),
      _Milestone(
        icon: '🔥',
        title: '3-Day Streak',
        unlocked: streak >= 3,
        desc: '$streak day streak',
      ),
      _Milestone(
        icon: '💼',
        title: '10 Tasks Done',
        unlocked: tasksCompleted >= 10,
        desc: '$tasksCompleted / 10 tasks',
      ),
      _Milestone(
        icon: '🐉',
        title: 'Boss Slayer',
        unlocked: bossDefeated,
        desc: bossDefeated ? 'Dragon defeated!' : 'Defeat the boss',
      ),
      _Milestone(
        icon: '🥇',
        title: 'Gold Rank',
        unlocked: totalXp >= 1500,
        desc: '$totalXp / 1500 XP',
      ),
      _Milestone(
        icon: '💎',
        title: 'Diamond Rank',
        unlocked: totalXp >= 3000,
        desc: '$totalXp / 3000 XP',
      ),
      _Milestone(
        icon: '🔥',
        title: '7-Day Streak',
        unlocked: streak >= 7,
        desc: '$streak / 7 days',
      ),
      _Milestone(
        icon: '👑',
        title: 'Quest Lord',
        unlocked: tasksCompleted >= 50,
        desc: '$tasksCompleted / 50 tasks',
      ),
      _Milestone(
        icon: '🌊',
        title: 'XP Titan',
        unlocked: totalXp >= 10000,
        desc: '$totalXp / 10000 XP',
      ),
      _Milestone(
        icon: '🌌',
        title: 'Legendary',
        unlocked: totalXp >= 5000,
        desc: '$totalXp / 5000 XP',
      ),
      _Milestone(
        icon: '🗓️',
        title: 'Fortnite Streak',
        unlocked: streak >= 14,
        desc: '$streak / 14 days',
      ),
      _Milestone(
        icon: '🎓',
        title: 'Skill Collector',
        unlocked: unlockedSkillsCount >= 5,
        desc: '$unlockedSkillsCount / 5 skills',
      ),
      _Milestone(
        icon: '🌙',
        title: 'Consistency',
        unlocked: streak >= 30,
        desc: '$streak / 30 days',
      ),
    ];

    return ListView.builder(
      itemCount: milestones.length,
      itemBuilder: (_, i) {
        final m = milestones[i];
        return AnimatedOpacity(
          opacity: m.unlocked ? 1.0 : 0.35,
          duration: const Duration(milliseconds: 300),
          child: Container(
            margin: const EdgeInsets.only(bottom: 5),
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: m.unlocked
                  ? AppColors.accent.withValues(alpha: 0.03)
                  : AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: m.unlocked
                    ? AppColors.accent.withValues(alpha: 0.22)
                    : AppColors.border,
              ),
            ),
            child: Row(
              children: [
                Text(m.icon, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(m.title,
                      style: AppTheme.sans(size: 11, weight: FontWeight.w700)),
                ),
                Text(
                  m.unlocked ? 'Unlocked' : m.desc,
                  style: AppTheme.mono(
                    size: 9,
                    color: m.unlocked ? AppColors.accent : AppColors.subtle,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Milestone {
  final String icon;
  final String title;
  final bool unlocked;
  final String desc;
  const _Milestone({
    required this.icon,
    required this.title,
    required this.unlocked,
    required this.desc,
  });
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
