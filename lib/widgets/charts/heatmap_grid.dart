import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class HeatmapGrid extends StatelessWidget {
  final List<List<int>> data; // 12 weeks × 7 days
  const HeatmapGrid({super.key, required this.data});

  static List<List<int>> generate() {
    final rng = Random();
    return List.generate(12, (w) =>
        List.generate(7, (d) => min((rng.nextInt(7) + (w > 8 ? 3 : 1)), 8)));
  }

  Color _cellColor(int v) {
    if (v == 0) return Colors.white.withValues(alpha: 0.03);
    if (v <= 2) return AppColors.accent.withValues(alpha: 0.15);
    if (v <= 4) return AppColors.accent.withValues(alpha: 0.35);
    if (v <= 6) return AppColors.accent.withValues(alpha: 0.6);
    return AppColors.accent.withValues(alpha: 0.9);
  }

  @override
  Widget build(BuildContext context) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day labels
        Column(
          children: days.map((d) => SizedBox(
            width: 12, height: 17,
            child: Center(
              child: Text(d, style: AppTheme.mono(size: 8, color: AppColors.subtle)),
            ),
          )).toList(),
        ),
        const SizedBox(width: 3),
        // Grid
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.map((week) => Padding(
                padding: const EdgeInsets.only(right: 3),
                child: Column(
                  children: week.map((val) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Container(
                      width: 14, height: 14,
                      decoration: BoxDecoration(
                        color: _cellColor(val),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  )).toList(),
                ),
              )).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
