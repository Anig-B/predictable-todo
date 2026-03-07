import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class ComboBanner extends StatelessWidget {
  final int comboPoints;
  final int comboMulti;

  const ComboBanner(
      {super.key, required this.comboPoints, required this.comboMulti});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [
          AppColors.red.withValues(alpha: 0.08),
          AppColors.orange.withValues(alpha: 0.05),
        ]),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('COMBO ACTIVE!',
                    style: AppTheme.mono(
                        size: 11,
                        weight: FontWeight.w800,
                        color: AppColors.red)),
                Text('Keep going!',
                    style: AppTheme.sans(size: 8, color: AppColors.subtle)),
              ],
            ),
          ),
          Text('$comboMulti×',
              style: AppTheme.mono(
                  size: 15, weight: FontWeight.w800, color: AppColors.gold)),
        ],
      ),
    );
  }
}

class MultiplierBanner extends StatelessWidget {
  final int multiplier;

  const MultiplierBanner({super.key, required this.multiplier});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.purple.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: AppColors.purple.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const Text('✨', style: TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
            child: Text('$multiplier× Multiplier Active',
                style: AppTheme.sans(
                    size: 10,
                    weight: FontWeight.w700,
                    color: AppColors.purple)),
          ),
          Text('Next task',
              style: AppTheme.sans(size: 8, color: AppColors.subtle)),
        ],
      ),
    );
  }
}
