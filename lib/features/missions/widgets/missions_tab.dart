import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive_scale.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/mission_provider.dart';
import '../models/mission_model.dart';

class MissionsTab extends ConsumerStatefulWidget {
  const MissionsTab({super.key});

  @override
  ConsumerState<MissionsTab> createState() => _MissionsTabState();
}

class _MissionsTabState extends ConsumerState<MissionsTab> {
  RealtimeChannel? _channel;

  @override
  void initState() {
    super.initState();
    _subscribeToInvites();
  }

  void _subscribeToInvites() {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    _channel = Supabase.instance.client.channel('mission-invites').onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'mission_members',
      filter: PostgresChangeFilter(
        column: 'user_id',
        type: PostgresChangeFilterType.eq,
        value: user.id,
      ),
      callback: (payload) {
        if (!mounted) return;
        ref.invalidate(missionsProvider);
      },
    ).subscribe();
  }

  @override
  void dispose() {
    _channel?.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final missionsAsync = ref.watch(missionsProvider);
    final rs = ResponsiveScale(context);

    return missionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Text('Failed to load missions',
            style: AppTheme.sans(size: rs.f(12), color: AppColors.subtle)),
      ),
      data: (missions) {
        if (missions.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(rs.p(24)),
              child: Text('No missions yet',
                  textAlign: TextAlign.center,
                  style: AppTheme.sans(size: rs.f(12), color: AppColors.muted)),
            ),
          );
        }

        return ListView.builder(
          itemCount: missions.length,
          itemBuilder: (_, i) => _MissionTile(mission: missions[i]),
        );
      },
    );
  }
}

class _MissionTile extends ConsumerWidget {
  final MissionModel mission;
  const _MissionTile({required this.mission});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rs = ResponsiveScale(context);
    final isPending = mission.joinedAt == null;

    return Container(
      margin: EdgeInsets.only(bottom: rs.p(6)),
      padding: rs.all(12),
      decoration: BoxDecoration(
        color: isPending ? AppColors.surface2 : AppColors.surface,
        borderRadius: BorderRadius.circular(rs.p(12)),
        border: Border.all(
          color: isPending
              ? AppColors.gold.withValues(alpha: 0.3)
              : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(mission.name,
                    style: AppTheme.sans(
                        size: rs.f(14), weight: FontWeight.w800)),
              ),
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: rs.p(8), vertical: rs.p(3)),
                decoration: BoxDecoration(
                  color: isPending
                      ? AppColors.gold.withValues(alpha: 0.15)
                      : AppColors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(rs.p(6)),
                ),
                child: Text(
                  isPending ? 'INVITE' : 'ACTIVE',
                  style: AppTheme.mono(
                    size: rs.f(9),
                    weight: FontWeight.w800,
                    color: isPending ? AppColors.gold : AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
          if (mission.description != null &&
              mission.description!.isNotEmpty) ...[
            SizedBox(height: rs.p(4)),
            Text(mission.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style:
                    AppTheme.sans(size: rs.f(11), color: AppColors.subtle)),
          ],
          if (isPending) ...[
            SizedBox(height: rs.p(10)),
            Text('Pending invite — check your notifications to respond',
                style: AppTheme.sans(
                    size: rs.f(11), color: AppColors.gold)),
            SizedBox(height: rs.p(8)),
            GestureDetector(
              onTap: () => context.push('/notifications'),
              child: Container(
                padding: rs.symV(8),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(rs.p(8)),
                ),
                alignment: Alignment.center,
                child: Text('View Notifications',
                    style: AppTheme.sans(
                        size: rs.f(12),
                        weight: FontWeight.w700,
                        color: AppColors.bg)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
