import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/data/seed_data.dart';
import '../../models/leaderboard_entry_model.dart';

class LeaderboardPage extends ConsumerStatefulWidget {
  const LeaderboardPage({super.key});

  @override
  ConsumerState<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends ConsumerState<LeaderboardPage> {
  String _filter = 'weekly';
  bool _inviteSent = false;
  final Set<int> _challengeSent = {};

  @override
  Widget build(BuildContext context) {
    final entries = SeedData.leaderboard;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Leaderboard',
                      style: AppTheme.mono(size: 20, weight: FontWeight.w800)),
                  // Filter pills
                  Row(
                    children: ['weekly', 'all-time'].map((f) {
                      final active = _filter == f;
                      return GestureDetector(
                        onTap: () => setState(() => _filter = f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          margin: const EdgeInsets.only(left: 6),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.accent.withValues(alpha: 0.1)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: active
                                  ? AppColors.accent
                                  : AppColors.border,
                            ),
                          ),
                          child: Text(
                            f == 'weekly' ? 'Weekly' : 'All-Time',
                            style: AppTheme.sans(
                              size: 10,
                              weight: FontWeight.w700,
                              color: active ? AppColors.accent : AppColors.muted,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 130),
                itemCount: entries.length + 1,
                itemBuilder: (_, i) {
                  if (i == entries.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: _InviteButton(
                        sent: _inviteSent,
                        onTap: () => setState(() => _inviteSent = !_inviteSent),
                      ),
                    );
                  }
                  final entry = entries[i];
                  final rank = i + 1;
                  return _LeaderboardCard(
                    entry: entry,
                    rank: rank,
                    challengeSent: _challengeSent.contains(i),
                    onChallenge: () => setState(() {
                      if (_challengeSent.contains(i)) {
                        _challengeSent.remove(i);
                      } else {
                        _challengeSent.add(i);
                      }
                    }),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardCard extends StatelessWidget {
  final LeaderboardEntry entry;
  final int rank;
  final bool challengeSent;
  final VoidCallback onChallenge;

  const _LeaderboardCard({
    required this.entry,
    required this.rank,
    required this.challengeSent,
    required this.onChallenge,
  });

  Color get _rankColor {
    if (rank == 1) return AppColors.gold;
    if (rank == 2) return const Color(0xFFAAAAAA);
    if (rank == 3) return const Color(0xFFCD7F32);
    return AppColors.subtle;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: entry.isYou
            ? AppColors.accent.withValues(alpha: 0.04)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: entry.isYou
              ? AppColors.accent.withValues(alpha: 0.28)
              : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Text('$rank',
                textAlign: TextAlign.center,
                style: AppTheme.mono(
                    size: 12, weight: FontWeight.w800, color: _rankColor)),
          ),
          const SizedBox(width: 8),
          Text(entry.avatar, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.name,
                    style: AppTheme.sans(
                        size: 11,
                        weight: FontWeight.w700,
                        color: entry.isYou
                            ? AppColors.accent
                            : AppColors.text)),
                const SizedBox(height: 2),
                Text('${entry.xp} XP',
                    style: AppTheme.mono(
                        size: 9, color: AppColors.accent)),
                Row(
                  children: [
                    Text('LVL ${entry.level}',
                        style: AppTheme.mono(
                            size: 8, color: AppColors.purple)),
                    const SizedBox(width: 6),
                    Text('🔥 ${entry.streak}d',
                        style: AppTheme.sans(
                            size: 8, color: AppColors.subtle)),
                    const SizedBox(width: 6),
                    Text('${entry.tasksWeek} tasks/wk',
                        style: AppTheme.sans(
                            size: 8, color: AppColors.subtle)),
                  ],
                ),
              ],
            ),
          ),
          if (!entry.isYou)
            GestureDetector(
              onTap: onChallenge,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: challengeSent
                      ? AppColors.accent.withValues(alpha: 0.1)
                      : AppColors.purple.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: challengeSent
                        ? AppColors.accent.withValues(alpha: 0.28)
                        : AppColors.purple.withValues(alpha: 0.28),
                  ),
                ),
                child: Text(
                  challengeSent ? 'Sent ✓' : 'Challenge',
                  style: AppTheme.sans(
                    size: 9,
                    weight: FontWeight.w700,
                    color: challengeSent ? AppColors.accent : AppColors.purple,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _InviteButton extends StatelessWidget {
  final bool sent;
  final VoidCallback onTap;

  const _InviteButton({required this.sent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          gradient: sent ? null : AppColors.primaryGradient,
          color: sent ? AppColors.surface2 : null,
          borderRadius: BorderRadius.circular(12),
          border: sent
              ? Border.all(color: AppColors.accent.withValues(alpha: 0.28))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              sent ? Icons.check : Icons.person_add_outlined,
              size: 16,
              color: sent ? AppColors.accent : AppColors.bg,
            ),
            const SizedBox(width: 8),
            Text(
              sent ? 'Invite Sent!' : 'Invite a Friend',
              style: AppTheme.sans(
                size: 12,
                weight: FontWeight.w800,
                color: sent ? AppColors.accent : AppColors.bg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
