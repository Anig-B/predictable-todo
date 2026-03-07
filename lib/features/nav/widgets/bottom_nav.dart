import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../notifications/providers/notification_provider.dart';

class BottomNav extends ConsumerWidget {
  final String currentLocation;
  const BottomNav({super.key, required this.currentLocation});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadCountProvider);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.94),
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavItem(
                  icon: Icons.check_box_outlined,
                  label: 'Tasks',
                  route: '/tasks',
                  current: currentLocation),
              _NavItem(
                  icon: Icons.bar_chart_rounded,
                  label: 'Stats',
                  route: '/stats',
                  current: currentLocation),
              const SizedBox(width: 56), // space for FAB
              _NavItem(
                  icon: Icons.leaderboard_outlined,
                  label: 'Board',
                  route: '/leaderboard',
                  current: currentLocation,
                  badge: unread > 0 ? unread : null),
              _NavItem(
                  icon: Icons.person_outline,
                  label: 'Profile',
                  route: '/profile',
                  current: currentLocation),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String route;
  final String current;
  final int? badge;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.current,
    this.badge,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.current.startsWith(widget.route);
    final color = active
        ? AppColors.accent
        : _hovered
            ? AppColors.text
            : AppColors.subtle;

    return Expanded(
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: () {
            // If there's a modal open (like Challenges), pop it before navigating away
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
            context.go(widget.route);
          },
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: double.infinity,
            height: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            decoration: BoxDecoration(
              color: _hovered && !active
                  ? AppColors.surface2.withValues(alpha: 0.6)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedScale(
                      scale: active ? 1.15 : 1.0,
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      child: Icon(widget.icon, color: color, size: 20),
                    ),
                    if (widget.badge != null)
                      Positioned(
                        top: -4,
                        right: -6,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                              color: AppColors.red, shape: BoxShape.circle),
                          child: Text('${widget.badge}',
                              style:
                                  AppTheme.mono(size: 7, color: Colors.white)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 150),
                  style: AppTheme.sans(
                      size: 9, weight: FontWeight.w700, color: color),
                  child: Text(widget.label),
                ),
                const SizedBox(height: 2),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  width: active ? 16 : 0,
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
