import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../gamification/providers/effects_provider.dart';
import '../widgets/effects/confetti_burst.dart';
import '../widgets/effects/xp_float_overlay.dart';
import '../widgets/effects/achievement_toast.dart';
import '../../nav/widgets/bottom_nav.dart';

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effects = ref.watch(effectsProvider);
    final location = GoRouterState.of(context).uri.toString();

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // ── Page content ────────────────────────────
          child,

          // ── Confetti ─────────────────────────────────
          RepaintBoundary(
            child: IgnorePointer(
              child: ConfettiBurst(trigger: effects.showConfetti),
            ),
          ),

          // ── XP floats ────────────────────────────────
          RepaintBoundary(
            child: IgnorePointer(
              child: XpFloatOverlay(floats: effects.xpFloats),
            ),
          ),

          // ── Achievement toast ─────────────────────────
          if (effects.toast != null)
            AchievementToast(
              toast: effects.toast!,
              onDismiss: () => ref.read(effectsProvider.notifier).clearToast(),
            ),
        ],
      ),
      bottomNavigationBar: BottomNav(currentLocation: location),
      floatingActionButton: _AddFab(location: location),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
      onTap: () => context.push('/new-quest'),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.28),
                blurRadius: 20,
                offset: const Offset(0, 4))
          ],
        ),
        child: const Icon(Icons.add, color: AppColors.bg, size: 26),
      ),
    );
  }
}
