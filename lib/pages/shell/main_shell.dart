import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/effects_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/effects/confetti_burst.dart';
import '../../widgets/effects/xp_float_overlay.dart';
import '../../widgets/effects/achievement_toast.dart';
import '../../widgets/overlays/add_task_sheet.dart';

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effects = ref.watch(effectsProvider);
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // ── Page content ────────────────────────────
          child,

          // ── Confetti ─────────────────────────────────
          IgnorePointer(
            child: ConfettiBurst(trigger: effects.showConfetti),
          ),

          // ── XP floats ────────────────────────────────
          IgnorePointer(
            child: XpFloatOverlay(floats: effects.xpFloats),
          ),

          // ── Achievement toast ─────────────────────────
          if (effects.toast != null)
            AchievementToast(
              toast: effects.toast!,
              onDismiss: () => ref.read(effectsProvider.notifier).clearToast(),
            ),
        ],
      ),
      bottomNavigationBar: _BottomNav(currentLocation: location),
      floatingActionButton: _AddFab(location: location),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

// ── Bottom Nav ──────────────────────────────────────────

class _BottomNav extends ConsumerWidget {
  final String currentLocation;
  const _BottomNav({required this.currentLocation});

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
              _NavItem(icon: Icons.check_box_outlined, label: 'Tasks',  route: '/tasks',       current: currentLocation),
              _NavItem(icon: Icons.bar_chart_rounded,  label: 'Stats',  route: '/stats',       current: currentLocation),
              const SizedBox(width: 56), // space for FAB
              _NavItem(icon: Icons.leaderboard_outlined, label: 'Board', route: '/leaderboard', current: currentLocation, badge: unread > 0 ? unread : null),
              _NavItem(icon: Icons.person_outline,      label: 'Profile', route: '/profile',   current: currentLocation),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final active = current.startsWith(route);
    final color = active ? AppColors.accent : AppColors.subtle;

    return Expanded(
      child: GestureDetector(
        onTap: () => context.go(route),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(icon, color: color, size: 20),
                if (badge != null)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle),
                      child: Text('$badge', style: AppTheme.mono(size: 7, color: Colors.white)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(label, style: AppTheme.sans(size: 9, weight: FontWeight.w700, color: color)),
          ],
        ),
      ),
    );
  }
}

// ── Add FAB ─────────────────────────────────────────────

class _AddFab extends StatelessWidget {
  final String location;
  const _AddFab({required this.location});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const AddTaskSheet(),
      ),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.28), blurRadius: 20, offset: const Offset(0, 4))],
        ),
        child: const Icon(Icons.add, color: AppColors.bg, size: 26),
      ),
    );
  }
}
