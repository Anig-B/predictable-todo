import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../providers/notification_provider.dart';

class _Scale {
  _Scale(this.context);
  final BuildContext context;
  double get w => MediaQuery.of(context).size.width;
  double s(double v) => v * (w / 430).clamp(0.75, 1.4);
  double f(double v) => _clamp(v, 0.8, 1.3);
  double p(double v) => _clamp(v, 0.7, 1.5);

  double _clamp(double v, double lo, double hi) {
    final scaled = s(v);
    if (v >= 0) return scaled.clamp(v * lo, v * hi);
    return scaled.clamp(v * hi, v * lo);
  }
}

class NotificationPanel extends ConsumerWidget {
  const NotificationPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifs = ref.watch(notificationProvider);
    final sc = _Scale(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final contentWidth = sc.w >= 600 ? 600.0 : constraints.maxWidth;
          return Center(
            child: SizedBox(
              width: contentWidth,
              child: Column(
                children: [
                  SizedBox(height: sc.p(12)),
                  Container(
                    width: sc.s(36),
                    height: sc.s(4),
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(sc.s(4)),
                    ),
                  ),
                  SizedBox(height: sc.p(4)),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: sc.p(16), vertical: sc.p(12)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Notifications',
                            style: AppTheme.mono(
                                size: sc.f(14), weight: FontWeight.w700)),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () => ref
                                  .read(notificationProvider.notifier)
                                  .markAllRead(),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: sc.p(10), vertical: sc.p(5)),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: AppColors.accent
                                          .withValues(alpha: 0.3)),
                                  borderRadius: BorderRadius.circular(sc.s(7)),
                                ),
                                child: Text('Mark read',
                                    style: AppTheme.sans(
                                        size: sc.f(10),
                                        color: AppColors.accent,
                                        weight: FontWeight.w700)),
                              ),
                            ),
                            SizedBox(width: sc.p(8)),
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Text('✕',
                                  style: AppTheme.sans(
                                      size: sc.f(14),
                                      color: AppColors.muted)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: AppColors.border, height: 1),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(sc.p(16)),
                      itemCount: notifs.length,
                      itemBuilder: (_, i) {
                        final n = notifs[i];
                        return Container(
                          margin: EdgeInsets.only(bottom: sc.p(6)),
                          decoration: BoxDecoration(
                            color: n.read
                                ? AppColors.surface
                                : AppColors.surface2,
                            borderRadius: BorderRadius.circular(sc.s(11)),
                            border: Border.all(color: AppColors.border),
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
                                    width: sc.s(3.5),
                                    color: AppColors.accent,
                                  ),
                                ),
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                    sc.p(16), sc.p(13), sc.p(13), sc.p(13)),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(n.text,
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTheme.sans(
                                            size: sc.f(12))),
                                    SizedBox(height: sc.p(3)),
                                    Text(
                                        timeago.format(n.createdAt),
                                        style: AppTheme.mono(
                                            size: sc.f(9),
                                            color: AppColors.subtle)),
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
        },
      ),
    );
  }
}
