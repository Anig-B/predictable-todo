import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
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
    final badgesAsync = ref.watch(otherUserBadgesProvider(entry.id));
    final activityAsync = ref.watch(otherUserActivityProvider(entry.id));
    final social = ref.watch(socialProvider);
    final isSent = social.sentChallenges.contains(entry.id);
    final isFriend = social.friends.contains(entry.id);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
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
                    const SizedBox(height: 40),
                    Hero(
                      tag: 'avatar_${entry.id}',
                      child: AppAvatar(
                        avatar: entry.avatar,
                        size: 80,
                        fontSize: 40,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      entry.name,
                      style: AppTheme.mono(size: 20, weight: FontWeight.w800),
                    ),
                    Text(
                      'Level ${entry.level} Adventurer',
                      style: AppTheme.sans(size: 13, color: AppColors.subtle),
                    ),
                  ],
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
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
                  const SizedBox(height: 32),

                  // Badges
                  Text('BADGES', style: AppTheme.mono(size: 11, weight: FontWeight.w700, color: AppColors.subtle)),
                  const SizedBox(height: 16),
                  badgesAsync.when(
                    data: (badges) {
                      if (badges.isEmpty) {
                        return Text('No badges earned yet.', style: AppTheme.sans(size: 13, color: AppColors.muted));
                      }
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: badges.map((b) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.purple.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.purple.withValues(alpha: 0.2)),
                          ),
                          child: Text('${SeedData.getBadgeIcon(b)} $b', style: AppTheme.sans(size: 13, weight: FontWeight.w600, color: AppColors.purple)),
                        )).toList(),
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(color: AppColors.purple)),
                    error: (_, __) => const SizedBox(),
                  ),

                  const SizedBox(height: 40),

                  // Recent Activity
                  Text('RECENT ACTIVITY', style: AppTheme.mono(size: 11, weight: FontWeight.w700, color: AppColors.subtle)),
                  const SizedBox(height: 16),
                  activityAsync.when(
                    data: (activities) {
                      if (activities.isEmpty) {
                        return Text('No recent adventures recorded.', style: AppTheme.sans(size: 13, color: AppColors.muted));
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
                  
                  const SizedBox(height: 40),
                  
                  // Action Button
                  if (!entry.isYou && !isFriend)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isSent ? null : () {
                          ref.read(socialProvider.notifier).sendChallenge(entry.id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.purple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Text(
                          isSent ? 'CHALLENGE SENT' : 'SEND DUEL CHALLENGE',
                          style: AppTheme.mono(size: 14, weight: FontWeight.w800),
                        ),
                      ),
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTheme.mono(size: 18, weight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text(label, style: AppTheme.mono(size: 9, color: AppColors.subtle, weight: FontWeight.w700)),
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
    return GestureDetector(
      onTap: hasProof ? () => _showProof(context) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Text(log.icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(log.task, style: AppTheme.sans(size: 14, weight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(log.time, style: AppTheme.sans(size: 11, color: AppColors.subtle)),
                ],
              ),
            ),
            if (hasProof) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified, size: 12, color: AppColors.accent),
                    const SizedBox(width: 4),
                    Text('PROOF', style: AppTheme.mono(size: 9, weight: FontWeight.w800, color: AppColors.accent)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
            ],
            Text('+${log.points} XP', style: AppTheme.mono(size: 13, weight: FontWeight.w800, color: AppColors.gold)),
          ],
        ),
      ),
    );
  }

  void _showProof(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (_) => Container(
        decoration: AppTheme.sheetBox,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: AppTheme.handleBar),
            const SizedBox(height: 24),
            Row(
              children: [
                Text(log.icon, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(log.task, style: AppTheme.sans(size: 18, weight: FontWeight.w800)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (log.notes != null && log.notes!.isNotEmpty) ...[
              Text('USER NOTES', style: AppTheme.mono(size: 10, weight: FontWeight.w700, color: AppColors.subtle)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(log.notes!, style: AppTheme.sans(size: 14, color: AppColors.text)),
              ),
              const SizedBox(height: 24),
            ],
            if (log.imageUrl != null && log.imageUrl!.isNotEmpty) ...[
              Text('EVIDENCE', style: AppTheme.mono(size: 10, weight: FontWeight.w700, color: AppColors.subtle)),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  log.imageUrl!,
                  width: double.infinity,
                  height: 240,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    color: AppColors.surface,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image, color: AppColors.muted),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text('Close Proof', style: AppTheme.mono(size: 14, weight: FontWeight.w800, color: AppColors.bg)),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
