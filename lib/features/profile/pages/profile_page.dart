import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive_scale.dart';
import '../../tasks/providers/task_provider.dart';
import '../../tasks/models/activity_log_model.dart';
import '../../gamification/providers/gamification_provider.dart';
import '../../gamification/providers/challenge_provider.dart';
import '../../gamification/models/challenge_model.dart';
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
    with TickerProviderStateMixin {
  late final TabController _tabCtrl;
  late final AnimationController _petBobbleCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..repeat(reverse: true);
  late final Animation<double> _petBobble = Tween(begin: 0.0, end: -4.0)
      .animate(
          CurvedAnimation(parent: _petBobbleCtrl, curve: Curves.easeInOut));

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _petBobbleCtrl.dispose();
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tState = ref.watch(taskProvider);
    final gState = ref.watch(gamificationProvider);
    final cState = ref.watch(challengeProvider);
    final totalXp = gState.totalXp;
    final level = XpCalculator.level(totalXp);
    final lvlProgress = XpCalculator.levelProgress(totalXp);

    final xpInLevel = XpCalculator.xpInLevel(totalXp);
    final profile = ref.watch(profileProvider);
    final hasData = tState.totalCount > 0 ||
        totalXp > 0 ||
        gState.totalLifetimeTasks > 0 ||
        gState.currentStreak > 0 ||
        gState.spinUsed ||
        gState.shields > 1 ||
        cState.any((c) => c.done || c.progress > 0);
    final rs = ResponsiveScale(context);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: rs.tabletCenter(600)(SafeArea(
        bottom: false,
        child: ListView(
          padding: rs.fromLTRB(16, 6, 16, 24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () => ref.read(authRepositoryProvider).signOut(),
                  icon: Icon(Icons.logout_rounded,
                      size: rs.f(20), color: AppColors.muted),
                  tooltip: 'Sign Out',
                ),
                SizedBox(width: rs.p(4)),
                IconButton(
                  onPressed: hasData
                      ? () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final confirmed = await _confirmClear(context,
                              tState.totalCount, totalXp, gState, cState);
                          if (!confirmed || !mounted) return;
                          await ref.read(taskProvider.notifier).clearAll();
                          await ref.read(challengeProvider.notifier).reset();
                          await ref.read(gamificationProvider.notifier).reset();
                          await ref.read(profileProvider.notifier).reset();
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text('All data cleared from server',
                                  style: AppTheme.sans(size: rs.f(12))),
                              backgroundColor:
                                  AppColors.red.withValues(alpha: 0.2),
                            ),
                          );
                        }
                      : null,
                  icon: Icon(
                    Icons.delete_sweep_rounded,
                    size: rs.f(20),
                    color: hasData ? AppColors.red : AppColors.muted,
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
                SizedBox(height: rs.p(10)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: rs.p(32)), // Spacer for balance
                    Text(profile.name,
                        style:
                            AppTheme.sans(size: rs.f(17), weight: FontWeight.w800)),
                    SizedBox(width: rs.p(4)),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const EditProfilePage()),
                      ),
                      icon: Icon(Icons.edit_note_rounded,
                          size: rs.f(18), color: AppColors.muted),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('USER ID: ${profile.shortId}',
                        style: AppTheme.mono(
                            size: rs.f(10),
                            color: AppColors.muted,
                            weight: FontWeight.w700)),
                    SizedBox(width: rs.p(6)),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: profile.shortId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('ID Copied!',
                                style: AppTheme.sans(size: rs.f(11))),
                            backgroundColor: AppColors.surface2,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Icon(Icons.copy_rounded,
                          size: rs.f(12), color: AppColors.muted),
                    ),
                  ],
                ),
                SizedBox(height: rs.p(4)),
                Text(profile.tagline,
                    style: AppTheme.mono(size: rs.f(9), color: AppColors.accent)),
              ],
            ),
            SizedBox(height: rs.p(16)),

            // ── XP Bar Card ─────────────────────────────
            Container(
              padding: rs.all(12),
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
                              size: rs.f(15),
                              weight: FontWeight.w800,
                              color: AppColors.accent)),
                      // Show XP within current level, not cumulative total
                      Text('$xpInLevel / ${XpCalculator.xpPerLevel} XP',
                          style:
                              AppTheme.mono(size: rs.f(10), color: AppColors.subtle)),
                    ],
                  ),
                  SizedBox(height: rs.p(6)),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(rs.p(4)),
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
            SizedBox(height: rs.p(18)),

            // ── Stat Row ───────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _StatBox(
                      value: '${tState.doneCount}', label: 'Tasks Done'),
                ),
                SizedBox(width: rs.p(8)),
                Expanded(
                  child: _StatBox(
                      value: '${gState.currentStreak}d', label: 'Day Streak'),
                ),
              ],
            ),
            SizedBox(height: rs.p(16)),

            // ── Companion ──────────────────────────────
            _buildCompanionCard(gState.totalLifetimeTasks),
            SizedBox(height: rs.p(18)),

            // ── Rank Tiers ──────────────────────────────
            _buildRankCard(totalXp),
            SizedBox(height: rs.p(16)),

            // ── Tabs ────────────────────────────────────
            Container(
              decoration: AppTheme.surfaceBox(radius: 10),
              padding: rs.all(3),
              child: TabBar(
                controller: _tabCtrl,
                indicator: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(rs.p(8)),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelStyle: AppTheme.sans(size: rs.f(10), weight: FontWeight.w700),
                unselectedLabelStyle:
                    AppTheme.sans(size: rs.f(10), color: AppColors.muted),
                labelColor: AppColors.bg,
                unselectedLabelColor: AppColors.muted,
                tabs: const [
                  Tab(text: 'Activity'),
                  Tab(text: 'Badges'),
                ],
              ),
            ),
            SizedBox(height: rs.p(12)),
            SizedBox(
              height: rs.s(380),
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
                ],
              ),
            ),
            SizedBox(height: rs.p(16)),
          ],
        ),
      )),
    );
  }

  Future<bool> _confirmClear(BuildContext context, int taskCount, int totalXp,
      GamificationState gState, List<ChallengeModel> quests) async {
    if (taskCount == 0 &&
        totalXp == 0 &&
        gState.totalLifetimeTasks == 0 &&
        gState.currentStreak == 0 &&
        !gState.spinUsed &&
        gState.shields <= 1 &&
        !quests.any((c) => c.done || c.progress > 0)) {
      return false;
    }
    final rs = ResponsiveScale(context);
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => Dialog(
        backgroundColor: AppColors.surface2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(rs.p(18)),
          side: BorderSide(color: AppColors.red.withValues(alpha: 0.25)),
        ),
        child: Padding(
          padding: rs.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🗑️', style: TextStyle(fontSize: 48)),
              SizedBox(height: rs.p(12)),
              Text('Clear Everything?',
                  style: AppTheme.mono(size: rs.f(16), weight: FontWeight.w800)),
              SizedBox(height: rs.p(8)),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTheme.sans(size: rs.f(12), color: AppColors.muted),
                  children: [
                    const TextSpan(text: 'This will permanently delete '),
                    if (taskCount > 0)
                      TextSpan(
                        text: '$taskCount tasks ',
                        style: AppTheme.mono(size: rs.f(12), color: AppColors.red),
                      ),
                    if (taskCount > 0 && totalXp > 0)
                      const TextSpan(text: 'and '),
                    if (totalXp > 0)
                      TextSpan(
                        text: 'all progress ',
                        style: AppTheme.mono(size: rs.f(12), color: AppColors.red),
                      ),
                    const TextSpan(text: '. This cannot be undone.'),
                  ],
                ),
              ),
              SizedBox(height: rs.p(22)),
              GestureDetector(
                onTap: () => Navigator.of(dialogCtx).pop(true),
                child: Container(
                  width: double.infinity,
                  padding: rs.symV(13),
                  decoration: BoxDecoration(
                    gradient: AppColors.dangerGradient,
                    borderRadius: BorderRadius.circular(rs.p(12)),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.red.withValues(alpha: 0.3),
                          blurRadius: 18)
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text('Yes, Clear Everything',
                      style: AppTheme.sans(
                          size: rs.f(13),
                          weight: FontWeight.w800,
                          color: Colors.white)),
                ),
              ),
              SizedBox(height: rs.p(9)),
              GestureDetector(
                onTap: () => Navigator.of(dialogCtx).pop(false),
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: rs.symV(10),
                  child: Text('Cancel',
                      style: AppTheme.sans(
                          size: rs.f(11),
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

  Widget _buildCompanionCard(int totalLifetimeTasks) {
    final pet = XpCalculator.currentPet(totalLifetimeTasks);
    final next = XpCalculator.nextPet(totalLifetimeTasks);
    final progress = XpCalculator.petProgress(totalLifetimeTasks);
    final bonusLabel = (pet.xpBonus > 0 || pet.bossDmgBonus > 0)
        ? '${pet.xpBonus > 0 ? '+${pet.xpBonus} XP ' : ''}${pet.bossDmgBonus > 0 ? '+${pet.bossDmgBonus} boss dmg' : ''}per task'
        : '';
    final rs = ResponsiveScale(context);

    return Container(
      padding: rs.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            pet.color.withValues(alpha: 0.15),
            AppColors.surface,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(rs.p(14)),
        border: Border.all(color: pet.color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RepaintBoundary(
                child: AnimatedBuilder(
                  animation: _petBobble,
                  builder: (_, __) => Transform.translate(
                    offset: Offset(0, _petBobble.value),
                    child:
                        Text(pet.emoji, style: const TextStyle(fontSize: 28)),
                  ),
                ),
              ),
              SizedBox(width: rs.p(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('YOUR COMPANION',
                        style: AppTheme.mono(
                            size: rs.f(8),
                            color: AppColors.subtle,
                            weight: FontWeight.w800)),
                    SizedBox(height: rs.p(1)),
                    Text(pet.name,
                        style: AppTheme.sans(
                            size: rs.f(17),
                            weight: FontWeight.w900,
                            color: pet.color)),
                    if (bonusLabel.isNotEmpty) ...[
                      SizedBox(height: rs.p(1)),
                      Text(bonusLabel,
                          style: AppTheme.mono(size: rs.f(8), color: pet.color)),
                    ],
                  ],
                ),
              ),
              if (next != null && next.minTasks > pet.minTasks)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('NEXT',
                        style: AppTheme.mono(
                            size: rs.f(7),
                            color: AppColors.subtle,
                            weight: FontWeight.w800)),
                    Text(next.emoji, style: const TextStyle(fontSize: 18)),
                    Text(next.name,
                        style: AppTheme.sans(
                            size: rs.f(9),
                            color: AppColors.subtle,
                            weight: FontWeight.w600)),
                  ],
                ),
            ],
          ),
          SizedBox(height: rs.p(12)),
          if (next != null && next.minTasks > pet.minTasks) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(rs.p(3)),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: AppColors.surface3,
                valueColor: AlwaysStoppedAnimation<Color>(pet.color),
              ),
            ),
            SizedBox(height: rs.p(4)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${pet.minTasks} tasks',
                    style: AppTheme.mono(size: rs.f(8), color: AppColors.subtle)),
                Text(
                    '${totalLifetimeTasks - pet.minTasks} / ${next.minTasks - pet.minTasks} tasks to ${next.emoji}',
                    style: AppTheme.mono(size: rs.f(8), color: pet.color)),
              ],
            ),
          ],
          SizedBox(height: rs.p(8)),
          GestureDetector(
            onTap: () => _showEvolutionSheet(context, totalLifetimeTasks),
            child: Container(
              padding: rs.symV(6),
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(rs.p(8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.list_rounded,
                      size: rs.f(10), color: AppColors.muted),
                  SizedBox(width: rs.p(4)),
                  Text('See all stages',
                      style: AppTheme.sans(
                          size: rs.f(10),
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

  void _showEvolutionSheet(BuildContext context, int totalLifetimeTasks) {
    final rs = ResponsiveScale(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => Container(
        padding: rs.all(20),
        decoration: const BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: rs.s(36),
              height: rs.s(4),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(rs.p(4)),
              ),
            ),
            SizedBox(height: rs.p(20)),
            Text('EVOLUTION STAGES',
                style: AppTheme.mono(
                    size: rs.f(14), weight: FontWeight.w900, color: AppColors.text)),
            SizedBox(height: rs.p(20)),
            ...XpCalculator.petStages.map((stage) {
              final earned = totalLifetimeTasks >= stage.minTasks;
              final taskLabel =
                  stage.minTasks == 0 ? 'Start' : '${stage.minTasks} tasks';
              return Container(
                margin: EdgeInsets.only(bottom: rs.p(8)),
                padding: rs.all(14),
                decoration: BoxDecoration(
                  color: earned
                      ? stage.color.withValues(alpha: 0.08)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(rs.p(12)),
                  border: Border.all(
                    color: earned
                        ? stage.color.withValues(alpha: 0.3)
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Text(stage.emoji, style: const TextStyle(fontSize: 28)),
                    SizedBox(width: rs.p(14)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(stage.name,
                              style: AppTheme.sans(
                                  size: rs.f(15),
                                  weight: FontWeight.w800,
                                  color: earned
                                      ? AppColors.text
                                      : AppColors.subtle)),
                          Text(taskLabel,
                              style: AppTheme.mono(
                                  size: rs.f(10), color: AppColors.muted)),
                          if (stage.xpBonus > 0 || stage.bossDmgBonus > 0)
                            Text(
                              '${stage.xpBonus > 0 ? '+${stage.xpBonus} XP per task ' : ''}${stage.bossDmgBonus > 0 ? '+${stage.bossDmgBonus} boss dmg per task' : ''}',
                              style: AppTheme.mono(size: rs.f(8), color: stage.color),
                            ),
                        ],
                      ),
                    ),
                    if (earned)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: rs.p(8), vertical: rs.p(4)),
                        decoration: BoxDecoration(
                          color: stage.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(rs.p(6)),
                        ),
                        child: Text('EARNED',
                            style: AppTheme.mono(
                                size: rs.f(8),
                                color: stage.color,
                                weight: FontWeight.w900)),
                      ),
                  ],
                ),
              );
            }),
            SizedBox(height: rs.p(12)),
          ],
        ),
      ),
    );
  }

  Widget _buildRankCard(int totalXp) {
    final current = XpCalculator.currentRank(totalXp);
    final next = XpCalculator.nextRank(totalXp);
    final progress = XpCalculator.rankProgress(totalXp);
    final rs = ResponsiveScale(context);

    return Container(
      padding: rs.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            current.color.withValues(alpha: 0.15),
            AppColors.surface,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(rs.p(14)),
        border: Border.all(color: current.color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(current.icon, style: const TextStyle(fontSize: 28)),
              SizedBox(width: rs.p(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CURRENT RANK',
                        style: AppTheme.mono(
                            size: rs.f(8),
                            color: AppColors.subtle,
                            weight: FontWeight.w800)),
                    SizedBox(height: rs.p(1)),
                    Text(current.name,
                        style: AppTheme.sans(
                            size: rs.f(17),
                            weight: FontWeight.w900,
                            color: current.color)),
                  ],
                ),
              ),
              SizedBox(width: rs.p(8)),
              if (next != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('NEXT',
                        style: AppTheme.mono(
                            size: rs.f(7),
                            color: AppColors.subtle,
                            weight: FontWeight.w800)),
                    Text(next.icon, style: const TextStyle(fontSize: 18)),
                    Text(next.name,
                        style: AppTheme.sans(
                            size: rs.f(9),
                            color: AppColors.subtle,
                            weight: FontWeight.w600)),
                  ],
                ),
            ],
          ),
          SizedBox(height: rs.p(12)),
          if (next != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(rs.p(3)),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: AppColors.surface3,
                valueColor: AlwaysStoppedAnimation<Color>(current.color),
              ),
            ),
            SizedBox(height: rs.p(4)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${current.minXp} XP',
                    style: AppTheme.mono(size: rs.f(8), color: AppColors.subtle)),
                Text(
                    '${totalXp - current.minXp} / ${next.minXp - current.minXp} XP to ${next.name}',
                    style: AppTheme.mono(size: rs.f(8), color: current.color)),
              ],
            ),
          ],
          SizedBox(height: rs.p(8)),
          GestureDetector(
            onTap: () => _showRankSheet(context, totalXp),
            child: Container(
              padding: rs.symV(6),
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(rs.p(8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.list_rounded,
                      size: rs.f(10), color: AppColors.muted),
                  SizedBox(width: rs.p(4)),
                  Text('See all ranks',
                      style: AppTheme.sans(
                          size: rs.f(10),
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
    final rs = ResponsiveScale(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => Container(
        padding: rs.all(20),
        decoration: const BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: rs.s(36),
              height: rs.s(4),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(rs.p(4)),
              ),
            ),
            SizedBox(height: rs.p(20)),
            Text('RANK TIERS',
                style: AppTheme.mono(
                    size: rs.f(14), weight: FontWeight.w900, color: AppColors.text)),
            SizedBox(height: rs.p(20)),
            ...XpCalculator.rankTiers.map((tier) {
              final earned = totalXp >= tier.minXp;
              return Container(
                margin: EdgeInsets.only(bottom: rs.p(8)),
                padding: rs.all(14),
                decoration: BoxDecoration(
                  color: earned
                      ? tier.color.withValues(alpha: 0.08)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(rs.p(12)),
                  border: Border.all(
                    color: earned
                        ? tier.color.withValues(alpha: 0.3)
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Text(tier.icon, style: const TextStyle(fontSize: 28)),
                    SizedBox(width: rs.p(14)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(tier.name,
                              style: AppTheme.sans(
                                  size: rs.f(15),
                                  weight: FontWeight.w800,
                                  color:
                                      earned ? tier.color : AppColors.subtle)),
                          Text('${tier.minXp}+ XP',
                              style: AppTheme.mono(
                                  size: rs.f(10), color: AppColors.muted)),
                        ],
                      ),
                    ),
                    if (earned)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: rs.p(8), vertical: rs.p(4)),
                        decoration: BoxDecoration(
                          color: tier.color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(rs.p(6)),
                        ),
                        child: Text('EARNED',
                            style: AppTheme.mono(
                                size: rs.f(8),
                                color: tier.color,
                                weight: FontWeight.w900)),
                      ),
                  ],
                ),
              );
            }),
            SizedBox(height: rs.p(12)),
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
    return ListView.builder(
      itemCount: SeedData.badges.length,
      itemBuilder: (_, i) {
        final badge = SeedData.badges[i];
        final badgeName = badge['name'] as String;
        final badgeDesc = badge['desc'] as String;
        final unlocked = unlockedBadges.contains(badgeName);
        final selected = selectedBadges.contains(badgeName);

        return GestureDetector(
          onTap: unlocked ? () => onToggle(badgeName) : null,
          child: AnimatedOpacity(
            opacity: unlocked ? 1.0 : 0.35,
            duration: const Duration(milliseconds: 300),
            child: ColorFiltered(
              colorFilter: unlocked
                  ? const ColorFilter.mode(Colors.transparent, BlendMode.color)
                  : AppColors.grayscaleFilter,
              child: Container(
                margin: const EdgeInsets.only(bottom: 5),
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.accent.withValues(alpha: 0.08)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected ? AppColors.accent : AppColors.border,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(badge['icon'] as String,
                        style: const TextStyle(fontSize: 22)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(badgeName,
                              style: AppTheme.sans(
                                  size: 11, weight: FontWeight.w700)),
                          Text(badgeDesc,
                              style: AppTheme.sans(
                                  size: 9, color: AppColors.subtle)),
                        ],
                      ),
                    ),
                    Text(
                      unlocked ? (selected ? 'Selected' : 'Owned') : 'Locked',
                      style: AppTheme.mono(
                        size: 9,
                        color: unlocked
                            ? (selected ? AppColors.accent : AppColors.subtle)
                            : AppColors.muted,
                      ),
                    ),
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
