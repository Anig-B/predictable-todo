import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive_scale.dart';
import '../../leaderboard/models/leaderboard_entry_model.dart';
import '../../leaderboard/pages/leaderboard_page.dart'; // To reuse providers
import '../../tasks/models/activity_log_model.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../social/providers/social_provider.dart';
import '../../../core/data/seed_data.dart';

class SocialProfilePage extends ConsumerWidget {
  final LeaderboardEntry entry;

  const SocialProfilePage({super.key, required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rs = ResponsiveScale(context);
    final badgesAsync = ref.watch(otherUserBadgesProvider(entry.id));
    final activityAsync = ref.watch(otherUserActivityProvider(entry.id));
    final social = ref.watch(socialProvider);
    final isSent = social.sentChallenges.contains(entry.id);
    final isFriend = social.friends.contains(entry.id);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: rs.tabletCenter(600)(CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: rs.s(220),
            pinned: true,
            backgroundColor: AppColors.bg,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.purple.withValues(alpha: 0.1),
                      AppColors.bg,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: rs.p(40)),
                    Hero(
                      tag: 'avatar_${entry.id}',
                      child: AppAvatar(
                        avatar: entry.avatar,
                        size: rs.s(80),
                        fontSize: rs.f(40),
                      ),
                    ),
                    SizedBox(height: rs.p(12)),
                    Text(
                      entry.name,
                      style: AppTheme.mono(size: rs.f(20), weight: FontWeight.w800),
                    ),
                    Text(
                      'Level ${entry.level} Adventurer',
                      style: AppTheme.sans(size: rs.f(13), color: AppColors.subtle),
                    ),
                  ],
                ),
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new, size: rs.f(18)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: rs.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Row
                  Row(
                    children: [
                      _StatItem(label: 'TOTAL XP', value: entry.xp.toString()),
                      _StatItem(label: 'STREAK', value: '🔥 ${entry.streak}d'),
                      _StatItem(label: 'WEEKLY', value: entry.tasksWeek.toString()),
                    ],
                  ),
                  SizedBox(height: rs.p(32)),

                  // Badges
                  Text('BADGES', style: AppTheme.mono(size: rs.f(11), weight: FontWeight.w700, color: AppColors.subtle)),
                  SizedBox(height: rs.p(16)),
                  badgesAsync.when(
                    data: (badges) {
                      if (badges.isEmpty) {
                        return Text('No badges earned yet.', style: AppTheme.sans(size: rs.f(13), color: AppColors.muted));
                      }
                      return Wrap(
                        spacing: rs.p(12),
                        runSpacing: rs.p(12),
                        children: badges.map((b) => Container(
                          padding: EdgeInsets.symmetric(horizontal: rs.p(16), vertical: rs.p(10)),
                          decoration: BoxDecoration(
                            color: AppColors.purple.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(rs.p(16)),
                            border: Border.all(color: AppColors.purple.withValues(alpha: 0.2)),
                          ),
                          child: Text('${SeedData.getBadgeIcon(b)} $b', style: AppTheme.sans(size: rs.f(13), weight: FontWeight.w600, color: AppColors.purple)),
                        )).toList(),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.purple)),
                    error: (_, __) => const SizedBox(),
                  ),

                  SizedBox(height: rs.p(40)),

                  // Recent Activity
                  Text('RECENT ACTIVITY', style: AppTheme.mono(size: rs.f(11), weight: FontWeight.w700, color: AppColors.subtle)),
                  SizedBox(height: rs.p(16)),
                  activityAsync.when(
                    data: (activities) {
                      if (activities.isEmpty) {
                        return Text('No recent adventures recorded.', style: AppTheme.sans(size: rs.f(13), color: AppColors.muted));
                      }
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: activities.length,
                        itemBuilder: (_, idx) {
                          final log = activities[idx];
                          final hasProof = (log.notes?.isNotEmpty ?? false) || (log.imageUrl?.isNotEmpty ?? false);
                          return _ActivityTile(log: log, hasProof: hasProof);
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.purple)),
                    error: (_, __) => const SizedBox(),
                  ),
                  
                  SizedBox(height: rs.p(40)),
                  
                  // Action Button
                  if (!entry.isYou && !isFriend)
                    SizedBox(
                      width: double.infinity,
                      height: rs.s(56),
                      child: ElevatedButton(
                        onPressed: isSent ? null : () {
                          ref.read(socialProvider.notifier).sendChallenge(entry.id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.purple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs.p(16))),
                          elevation: 0,
                        ),
                        child: Text(
                          isSent ? 'CHALLENGE SENT' : 'SEND DUEL CHALLENGE',
                          style: AppTheme.mono(size: rs.f(14), weight: FontWeight.w800),
                        ),
                      ),
                    ),
                  SizedBox(height: rs.p(40)),
                ],
              ),
            ),
          ),
        ],
      )),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final rs = ResponsiveScale(context);
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTheme.mono(size: rs.f(18), weight: FontWeight.w800)),
          SizedBox(height: rs.p(4)),
          Text(label, style: AppTheme.mono(size: rs.f(9), color: AppColors.subtle, weight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final ActivityLogModel log;
  final bool hasProof;

  const _ActivityTile({required this.log, required this.hasProof});

  @override
  Widget build(BuildContext context) {
    final rs = ResponsiveScale(context);
    return GestureDetector(
      onTap: hasProof ? () => _showProof(context) : null,
      child: Container(
        margin: EdgeInsets.only(bottom: rs.p(10)),
        padding: rs.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(rs.p(16)),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Text(log.icon, style: const TextStyle(fontSize: 24)),
            SizedBox(width: rs.p(16)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(log.task, style: AppTheme.sans(size: rs.f(14), weight: FontWeight.w700)),
                  SizedBox(height: rs.p(2)),
                  Text(log.time, style: AppTheme.sans(size: rs.f(11), color: AppColors.subtle)),
                ],
              ),
            ),
            if (hasProof) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: rs.p(8), vertical: rs.p(4)),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(rs.p(8)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.verified, size: rs.f(12), color: AppColors.accent),
                    SizedBox(width: rs.p(4)),
                    Text('PROOF', style: AppTheme.mono(size: rs.f(9), weight: FontWeight.w800, color: AppColors.accent)),
                  ],
                ),
              ),
              SizedBox(width: rs.p(12)),
            ],
            Text('+${log.points} XP', style: AppTheme.mono(size: rs.f(13), weight: FontWeight.w800, color: AppColors.gold)),
          ],
        ),
      ),
    );
  }

  void _showProof(BuildContext context) {
    final rs = ResponsiveScale(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (_) => Container(
        decoration: AppTheme.sheetBox,
        padding: rs.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: AppTheme.handleBar),
            SizedBox(height: rs.p(24)),
            Row(
              children: [
                Text(log.icon, style: const TextStyle(fontSize: 24)),
                SizedBox(width: rs.p(12)),
                Expanded(
                  child: Text(log.task, style: AppTheme.sans(size: rs.f(18), weight: FontWeight.w800)),
                ),
              ],
            ),
            SizedBox(height: rs.p(24)),
            if (log.notes != null && log.notes!.isNotEmpty) ...[
              Text('USER NOTES', style: AppTheme.mono(size: rs.f(10), weight: FontWeight.w700, color: AppColors.subtle)),
              SizedBox(height: rs.p(8)),
              Container(
                width: double.infinity,
                padding: rs.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(rs.p(12)),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(log.notes!, style: AppTheme.sans(size: rs.f(14), color: AppColors.text)),
              ),
              SizedBox(height: rs.p(24)),
            ],
            if (log.imageUrl != null && log.imageUrl!.isNotEmpty) ...[
              Text('EVIDENCE', style: AppTheme.mono(size: rs.f(10), weight: FontWeight.w700, color: AppColors.subtle)),
              SizedBox(height: rs.p(8)),
              ClipRRect(
                borderRadius: BorderRadius.circular(rs.p(16)),
                child: Image.network(
                  log.imageUrl!,
                  width: double.infinity,
                  height: rs.s(240),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: rs.s(200),
                    color: AppColors.surface,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image, color: AppColors.muted),
                  ),
                ),
              ),
              SizedBox(height: rs.p(24)),
            ],
            SizedBox(
              width: double.infinity,
              height: rs.s(56),
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(rs.p(16))),
                  elevation: 0,
                ),
                child: Text('Close Proof', style: AppTheme.mono(size: rs.f(14), weight: FontWeight.w800, color: AppColors.bg)),
              ),
            ),
            SizedBox(height: rs.p(24)),
          ],
        ),
      ),
    );
  }
}
