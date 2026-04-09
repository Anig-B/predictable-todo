import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/notification_provider.dart';
import '../models/notification_model.dart';
import '../../../shared/widgets/app_avatar.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifs = ref.watch(notificationProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new,
                              size: 16, color: AppColors.text),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text('Notifications',
                          style:
                              AppTheme.mono(size: 20, weight: FontWeight.w800)),
                    ],
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () =>
                            ref.read(notificationProvider.notifier).markAllRead(),
                        child: Text('Mark Read',
                            style: AppTheme.sans(
                                size: 10,
                                color: AppColors.muted,
                                weight: FontWeight.w700)),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => ref
                            .read(notificationProvider.notifier)
                            .clearAllSimpleNotifications(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: AppColors.dangerGradient,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                  color: AppColors.red.withValues(alpha: 0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4))
                            ],
                          ),
                          child: Text('Clear All',
                              style: AppTheme.sans(
                                  size: 11,
                                  color: AppColors.text,
                                  weight: FontWeight.w800)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: AppColors.border, height: 1),
            // List
            Expanded(
              child: notifs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('🔕', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 16),
                          Text('All caught up!',
                              style: AppTheme.sans(
                                  size: 14,
                                  color: AppColors.subtle,
                                  weight: FontWeight.w600)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      itemCount: notifs.length,
                      itemBuilder: (_, i) {
                        return _NotificationCard(notification: notifs[i], ref: ref);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final WidgetRef ref;

  const _NotificationCard({required this.notification, required this.ref});

  Widget _buildIcon() {
    switch (notification.type) {
      case 'challenge_received':
        return const AppAvatar(avatar: '⚔️', size: 40, fontSize: 24);
      case 'challenge_accepted':
        return const AppAvatar(avatar: '🏆', size: 40, fontSize: 24);
      case 'challenge_rejected':
        return const AppAvatar(avatar: '❌', size: 40, fontSize: 24);
      case 'boss_spawn':
      case 'boss_defeated':
        return const AppAvatar(avatar: '👺', size: 40, fontSize: 24);
      case 'surpassed_rank':
        return const AppAvatar(avatar: '📈', size: 40, fontSize: 24);
      case 'streak_warning':
        return const AppAvatar(avatar: '🔥', size: 40, fontSize: 24);
      case 'daily_reset':
      case 'loot_drop':
        return const AppAvatar(avatar: '🎰', size: 40, fontSize: 24);
      default:
        return const AppAvatar(avatar: '🔔', size: 40, fontSize: 24);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        ref.read(notificationProvider.notifier).deleteNotification(notification.id);
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppColors.red.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.red),
      ),
      child: GestureDetector(
        onTap: () {
          if (!notification.read) {
            ref.read(notificationProvider.notifier).markRead(notification.id);
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.read
                ? AppColors.surface.withValues(alpha: 0.5)
                : AppColors.surface2,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: notification.read
                    ? AppColors.border
                    : AppColors.accent.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIcon(),
              const SizedBox(width: 12),
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
                            style: AppTheme.sans(
                              size: 14,
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
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.accent,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.text,
                      style: AppTheme.sans(
                        size: 12,
                        weight: FontWeight.w500,
                        color: notification.read
                            ? AppColors.subtle
                            : AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Challenge Action Buttons
                    if (notification.type == 'challenge_received')
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accent,
                                  foregroundColor: AppColors.bg,
                                  minimumSize: const Size(0, 36),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () {
                                  final cid =
                                      notification.metadata['challenge_id'];
                                  if (cid != null) {
                                    ref
                                        .read(notificationProvider.notifier)
                                        .acceptChallenge(notification.id, cid);
                                  }
                                },
                                child: Text('ACCEPT',
                                    style: AppTheme.mono(
                                        size: 11, weight: FontWeight.w800)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.surface,
                                  foregroundColor: AppColors.text,
                                  minimumSize: const Size(0, 36),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  side:
                                      const BorderSide(color: AppColors.border),
                                ),
                                onPressed: () {
                                  final cid =
                                      notification.metadata['challenge_id'];
                                  if (cid != null) {
                                    ref
                                        .read(notificationProvider.notifier)
                                        .declineChallenge(notification.id, cid);
                                  }
                                },
                                child: Text('DECLINE',
                                    style: AppTheme.mono(
                                        size: 11, weight: FontWeight.w800)),
                              ),
                            ),
                          ],
                        ),
                      ),

                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 10, color: AppColors.subtle),
                        const SizedBox(width: 4),
                        Text(
                          timeago.format(notification.createdAt),
                          style: AppTheme.mono(size: 9, color: AppColors.subtle),
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
