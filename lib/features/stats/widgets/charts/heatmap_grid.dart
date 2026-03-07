import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../tasks/models/activity_log_model.dart';

class HeatmapGrid extends StatelessWidget {
  final List<List<int>> data; // 12 weeks × 7 days
  const HeatmapGrid({super.key, required this.data});

  static List<List<int>> fromLogs(List<ActivityLogModel> logs) {
    // 12 weeks: 84 days
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final grid = List.generate(12, (_) => List.filled(7, 0));

    for (final log in logs) {
      final diff = today.difference(log.createdAt).inDays;
      if (diff >= 0 && diff < 84) {
        final weekIdx = 11 - (diff ~/ 7);
        final dayIdx = log.createdAt.weekday - 1; // 0=Mon, 6=Sun
        if (dayIdx >= 0 && dayIdx < 7) {
          grid[weekIdx][dayIdx]++;
        }
      }
    }
    return grid;
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
          children: days
              .map((d) => SizedBox(
                    width: 12,
                    height: 17,
                    child: Center(
                      child: Text(d,
                          style:
                              AppTheme.mono(size: 8, color: AppColors.subtle)),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(width: 3),
        // Grid
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data
                  .map((week) => Padding(
                        padding: const EdgeInsets.only(right: 3),
                        child: Column(
                          children: week
                              .map((val) => Padding(
                                    padding: const EdgeInsets.only(bottom: 3),
                                    child: Container(
                                      width: 14,
                                      height: 14,
                                      decoration: BoxDecoration(
                                        color: _cellColor(val),
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ))
                              .toList(),
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}
