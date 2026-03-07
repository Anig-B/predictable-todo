import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/notification_provider.dart';

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
                  GestureDetector(
                    onTap: () =>
                        ref.read(notificationProvider.notifier).markAllRead(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4))
                        ],
                      ),
                      child: Text('Mark all read',
                          style: AppTheme.sans(
                              size: 11,
                              color: AppColors.bg,
                              weight: FontWeight.w700)),
                    ),
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
                        final n = notifs[i];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: n.read
                                ? AppColors.surface.withValues(alpha: 0.5)
                                : AppColors.surface2,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: n.read
                                    ? AppColors.border
                                    : AppColors.accent.withValues(alpha: 0.3)),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              if (!n.read)
                                Positioned(
                                  left: 0,
                                  top: 0,
                                  bottom: 0,
                                  child: Container(
                                    width: 4,
                                    color: AppColors.accent,
                                  ),
                                ),
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 16, 16, 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(n.text,
                                        style: AppTheme.sans(
                                            size: 13,
                                            weight: n.read
                                                ? FontWeight.w500
                                                : FontWeight.w700,
                                            color: n.read
                                                ? AppColors.muted
                                                : AppColors.text)),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time,
                                            size: 10, color: AppColors.subtle),
                                        const SizedBox(width: 4),
                                        Text(n.time,
                                            style: AppTheme.mono(
                                                size: 9,
                                                color: AppColors.subtle)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
