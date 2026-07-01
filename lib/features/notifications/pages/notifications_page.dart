import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/notification_provider.dart';
import '../models/notification_model.dart';
import '../../../shared/widgets/app_avatar.dart';

class ResponsiveScale {
  ResponsiveScale(this.context);
  final BuildContext context;

  double get width => MediaQuery.of(context).size.width;
  double get height => MediaQuery.of(context).size.height;
  bool get isTablet => width >= 600;
  bool get isLandscape => width > height;

  double scale(double size) {
    const referenceWidth = 430;
    return size * (width / referenceWidth).clamp(0.75, 1.4);
  }

  double font(double size) => _clamp(size, 0.8, 1.3);
  double pad(double size) => _clamp(size, 0.7, 1.5);

  double _clamp(double v, double lo, double hi) {
    final scaled = scale(v);
    if (v >= 0) return scaled.clamp(v * lo, v * hi);
    return scaled.clamp(v * hi, v * lo);
  }
}

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifs = ref.watch(notificationProvider);
    final rs = ResponsiveScale(context);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth = rs.isTablet
                ? constraints.maxWidth > 600
                    ? 600.0
                    : constraints.maxWidth
                : constraints.maxWidth;

            return Center(
              child: SizedBox(
                width: contentWidth,
                child: Column(
                  children: [
                    _Header(rs: rs, ref: ref),
                    const Divider(color: AppColors.border, height: 1),
                    Expanded(
                      child: notifs.isEmpty
                          ? _EmptyState(rs: rs)
                          : ListView.builder(
                              padding: EdgeInsets.fromLTRB(
                                  rs.pad(16), rs.pad(16), rs.pad(16), rs.pad(100)),
                              itemCount: notifs.length,
                              itemBuilder: (_, i) =>
                                  _NotificationCard(notification: notifs[i], ref: ref, rs: rs),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final ResponsiveScale rs;
  final WidgetRef ref;

  const _Header({required this.rs, required this.ref});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: rs.pad(16), vertical: rs.pad(16)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  padding: EdgeInsets.all(rs.pad(8)),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(rs.pad(10)),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Icon(Icons.arrow_back_ios_new,
                      size: rs.font(16), color: AppColors.text),
                ),
              ),
              SizedBox(width: rs.pad(16)),
              Text('Notifications',
                  style: AppTheme.mono(
                      size: rs.font(20), weight: FontWeight.w800)),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () =>
                    ref.read(notificationProvider.notifier).markAllRead(),
                child: Text('Mark Read',
                    style: AppTheme.sans(
                        size: rs.font(10),
                        color: AppColors.muted,
                        weight: FontWeight.w700)),
              ),
              SizedBox(width: rs.pad(12)),
              GestureDetector(
                onTap: () => ref
                    .read(notificationProvider.notifier)
                    .clearAllSimpleNotifications(),
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: rs.pad(12), vertical: rs.pad(8)),
                  decoration: BoxDecoration(
                    gradient: AppColors.dangerGradient,
                    borderRadius: BorderRadius.circular(rs.pad(10)),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.red.withValues(alpha: 0.2),
                          blurRadius: rs.scale(10),
                          offset: Offset(0, rs.scale(4)))
                    ],
                  ),
                  child: Text('Clear All',
                      style: AppTheme.sans(
                          size: rs.font(11),
                          color: AppColors.text,
                          weight: FontWeight.w800)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final ResponsiveScale rs;
  const _EmptyState({required this.rs});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🔕', style: TextStyle(fontSize: rs.font(48))),
          SizedBox(height: rs.pad(16)),
          Text('All caught up!',
              style: AppTheme.sans(
                  size: rs.font(14),
                  color: AppColors.subtle,
                  weight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final WidgetRef ref;
  final ResponsiveScale rs;

  const _NotificationCard({
    required this.notification,
    required this.ref,
    required this.rs,
  });

  Widget _buildIcon() {
    final size = rs.scale(40);
    final fontSize = rs.font(24);
    switch (notification.type) {
      case 'challenge_received':
        return AppAvatar(avatar: '⚔️', size: size, fontSize: fontSize);
      case 'mission_invite':
        return AppAvatar(avatar: '📬', size: size, fontSize: fontSize);
      case 'challenge_accepted':
        return AppAvatar(avatar: '🏆', size: size, fontSize: fontSize);
      case 'challenge_rejected':
        return AppAvatar(avatar: '❌', size: size, fontSize: fontSize);
      case 'boss_spawn':
      case 'boss_defeated':
        return AppAvatar(avatar: '👺', size: size, fontSize: fontSize);
      case 'surpassed_rank':
        return AppAvatar(avatar: '📈', size: size, fontSize: fontSize);
      case 'streak_warning':
        return AppAvatar(avatar: '🔥', size: size, fontSize: fontSize);
      case 'daily_reset':
      case 'loot_drop':
        return AppAvatar(avatar: '🎰', size: size, fontSize: fontSize);
      default:
        return AppAvatar(avatar: '🔔', size: size, fontSize: fontSize);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        ref
            .read(notificationProvider.notifier)
            .deleteNotification(notification.id);
      },
      background: Container(
        margin: EdgeInsets.only(bottom: rs.pad(8)),
        padding: EdgeInsets.only(right: rs.pad(20)),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppColors.red.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(rs.pad(16)),
        ),
        child: Icon(Icons.delete_outline,
            size: rs.font(20), color: AppColors.red),
      ),
      child: GestureDetector(
        onTap: () {
          if (!notification.read) {
            ref
                .read(notificationProvider.notifier)
                .markRead(notification.id);
          }
        },
        child: Container(
          margin: EdgeInsets.only(bottom: rs.pad(8)),
          padding: EdgeInsets.all(rs.pad(16)),
          decoration: BoxDecoration(
            color: notification.read
                ? AppColors.surface.withValues(alpha: 0.5)
                : AppColors.surface2,
            borderRadius: BorderRadius.circular(rs.pad(16)),
            border: Border.all(
                color: notification.read
                    ? AppColors.border
                    : AppColors.accent.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIcon(),
              SizedBox(width: rs.pad(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.sans(
                              size: rs.font(14),
                              weight: notification.read
                                  ? FontWeight.w600
                                  : FontWeight.w800,
                              color: notification.read
                                  ? AppColors.muted
                                  : AppColors.text,
                            ),
                          ),
                        ),
                        if (!notification.read)
                          Container(
                            width: rs.scale(8),
                            height: rs.scale(8),
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: rs.pad(4)),
                    Text(
                      notification.text,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.sans(
                        size: rs.font(12),
                        weight: FontWeight.w500,
                        color: notification.read
                            ? AppColors.subtle
                            : AppColors.muted,
                      ),
                    ),
                    SizedBox(height: rs.pad(8)),
                    if (notification.type == 'challenge_received')
                      Padding(
                        padding: EdgeInsets.only(
                            top: rs.pad(8), bottom: rs.pad(4)),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  foregroundColor: AppColors.bg,
                                  minimumSize:
                                      Size(0, rs.scale(36)),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(rs.pad(8))),
                                ),
                                onPressed: () {
                                  final cid = notification
                                      .metadata['challenge_id'];
                                  if (cid != null) {
                                    ref
                                        .read(notificationProvider.notifier)
                                        .acceptChallenge(
                                            notification.id, cid);
                                  }
                                },
                                child: Text('ACCEPT',
                                    style: AppTheme.mono(
                                        size: rs.font(11),
                                        weight: FontWeight.w800)),
                              ),
                            ),
                            SizedBox(width: rs.pad(8)),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.surface,
                                  foregroundColor: AppColors.text,
                                  minimumSize:
                                      Size(0, rs.scale(36)),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(rs.pad(8))),
                                  side: const BorderSide(
                                      color: AppColors.border),
                                ),
                                onPressed: () {
                                  final cid = notification
                                      .metadata['challenge_id'];
                                  if (cid != null) {
                                    ref
                                        .read(notificationProvider.notifier)
                                        .declineChallenge(
                                            notification.id, cid);
                                  }
                                },
                                child: Text('DECLINE',
                                    style: AppTheme.mono(
                                        size: rs.font(11),
                                        weight: FontWeight.w800)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (notification.type == 'mission_invite')
                      Padding(
                        padding: EdgeInsets.only(
                            top: rs.pad(8), bottom: rs.pad(4)),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  foregroundColor: AppColors.bg,
                                  minimumSize:
                                      Size(0, rs.scale(36)),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(rs.pad(8))),
                                ),
                                onPressed: () {
                                  final mid = notification
                                      .metadata['mission_id'];
                                  if (mid != null) {
                                    ref
                                        .read(notificationProvider.notifier)
                                        .acceptMissionInvite(
                                            notification.id, mid.toString());
                                  }
                                },
                                child: Text('ACCEPT',
                                    style: AppTheme.mono(
                                        size: rs.font(11),
                                        weight: FontWeight.w800)),
                              ),
                            ),
                            SizedBox(width: rs.pad(8)),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.surface,
                                  foregroundColor: AppColors.text,
                                  minimumSize:
                                      Size(0, rs.scale(36)),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(rs.pad(8))),
                                  side: const BorderSide(
                                      color: AppColors.border),
                                ),
                                onPressed: () {
                                  final mid = notification
                                      .metadata['mission_id'];
                                  if (mid != null) {
                                    ref
                                        .read(notificationProvider.notifier)
                                        .declineMissionInvite(
                                            notification.id, mid.toString());
                                  }
                                },
                                child: Text('DECLINE',
                                    style: AppTheme.mono(
                                        size: rs.font(11),
                                        weight: FontWeight.w800)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: rs.font(10),
                            color: AppColors.subtle),
                        SizedBox(width: rs.pad(4)),
                        Text(
                          timeago.format(notification.createdAt),
                          style: AppTheme.mono(
                              size: rs.font(9),
                              color: AppColors.subtle),
                        ),
                      ],
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
