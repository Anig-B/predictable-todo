import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/notification_provider.dart';

class NotificationPanel extends ConsumerWidget {
  const NotificationPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifs = ref.watch(notificationProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 4),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Notifications',
                    style: AppTheme.mono(size: 14, weight: FontWeight.w700)),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () =>
                          ref.read(notificationProvider.notifier).markAllRead(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: AppColors.accent.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text('Mark read',
                            style: AppTheme.sans(
                                size: 10,
                                color: AppColors.accent,
                                weight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Text('✕',
                          style: AppTheme.sans(
                              size: 14, color: AppColors.muted)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.border, height: 1),
          // List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifs.length,
              itemBuilder: (_, i) {
                final n = notifs[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: n.read ? AppColors.surface : AppColors.surface2,
                    borderRadius: BorderRadius.circular(11),
                    border: Border(
                      left: BorderSide(
                        color: n.read
                            ? Colors.transparent
                            : AppColors.accent,
                        width: 3,
                      ),
                      top: BorderSide(color: AppColors.border),
                      right: BorderSide(color: AppColors.border),
                      bottom: BorderSide(color: AppColors.border),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n.text,
                          style: AppTheme.sans(size: 12)),
                      const SizedBox(height: 3),
                      Text(n.time,
                          style: AppTheme.mono(
                              size: 9, color: AppColors.subtle)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
