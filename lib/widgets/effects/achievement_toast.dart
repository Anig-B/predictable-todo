import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/effects_provider.dart';

class AchievementToast extends StatelessWidget {
  final ToastData toast;
  final VoidCallback onDismiss;

  const AchievementToast({super.key, required this.toast, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 72,
      left: 16,
      right: 16,
      child: GestureDetector(
        onTap: onDismiss,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
          builder: (_, value, child) => Transform.scale(scale: value, child: Opacity(opacity: value.clamp(0.0, 1.0), child: child)),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.surface, AppColors.surface2],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.55), blurRadius: 32),
                BoxShadow(color: AppColors.gold.withValues(alpha: 0.12), blurRadius: 18),
              ],
            ),
            child: Row(
              children: [
                Text(toast.icon, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ACHIEVEMENT UNLOCKED!',
                          style: AppTheme.mono(size: 8, color: AppColors.gold)),
                      const SizedBox(height: 1),
                      Text(toast.title,
                          style: AppTheme.sans(size: 13, weight: FontWeight.w800)),
                      Text(toast.desc,
                          style: AppTheme.sans(size: 10, color: AppColors.muted)),
                    ],
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
