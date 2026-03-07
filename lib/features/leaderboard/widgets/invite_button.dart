import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class InviteButton extends StatelessWidget {
  final bool sent;
  final VoidCallback onTap;

  const InviteButton({super.key, required this.sent, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          gradient: sent ? null : AppColors.primaryGradient,
          color: sent ? AppColors.surface2 : null,
          borderRadius: BorderRadius.circular(12),
          border: sent
              ? Border.all(color: AppColors.accent.withValues(alpha: 0.28))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              sent ? Icons.check : Icons.person_add_outlined,
              size: 16,
              color: sent ? AppColors.accent : AppColors.bg,
            ),
            const SizedBox(width: 8),
            Text(
              sent ? 'Invite Sent!' : 'Invite a Friend',
              style: AppTheme.sans(
                size: 12,
                weight: FontWeight.w800,
                color: sent ? AppColors.accent : AppColors.bg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
