import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../tasks/models/activity_log_model.dart';

class DayStats {
  final int xp;
  final String topProject;

  const DayStats({this.xp = 0, this.topProject = ''});
}

class HeatmapGrid extends StatelessWidget {
  final List<List<DayStats>> data; // 12 weeks × 7 days
  final int? selectedWeek;
  final int? selectedDay;
  final Function(int week, int day)? onSelect;

  const HeatmapGrid({
    super.key,
    required this.data,
    this.selectedWeek,
    this.selectedDay,
    this.onSelect,
  });

  static List<List<DayStats>> fromLogs(List<ActivityLogModel> logs) {
    // 12 weeks: 84 days
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // grid: [week][day] -> map of {project: xp}
    final raw = List.generate(12, (_) => List.generate(7, (_) => <String, int>{}));

    for (final log in logs) {
      final diff = today.difference(log.createdAt).inDays;
      if (diff >= 0 && diff < 84) {
        final daysSinceMonday = (log.createdAt.weekday - 1);
        final mondayOfLog = DateTime(log.createdAt.year, log.createdAt.month, log.createdAt.day).subtract(Duration(days: daysSinceMonday));
        final todayMonday = today.subtract(Duration(days: today.weekday - 1));
        final weekDiff = todayMonday.difference(mondayOfLog).inDays ~/ 7;
        
        if (weekDiff >= 0 && weekDiff < 12) {
          final weekIdx = 11 - weekDiff;
          final dayIdx = log.createdAt.weekday - 1;
          final proj = log.project;
          raw[weekIdx][dayIdx][proj] = (raw[weekIdx][dayIdx][proj] ?? 0) + log.points;
        }
      }
    }

    return raw.map((week) => week.map((dayMap) {
      if (dayMap.isEmpty) return const DayStats();
      final topProj = dayMap.entries.reduce((a, b) => a.value > b.value ? a : b);
      final totalXp = dayMap.values.fold(0, (s, v) => s + v);
      return DayStats(xp: totalXp, topProject: topProj.key);
    }).toList()).toList();
  }

  Color _cellColor(int v) {
    if (v == 0) return Colors.white.withValues(alpha: 0.03);
    if (v <= 100) return AppColors.accent.withValues(alpha: 0.15);
    if (v <= 300) return AppColors.accent.withValues(alpha: 0.35);
    if (v <= 500) return AppColors.accent.withValues(alpha: 0.6);
    if (v <= 1000) return AppColors.accent.withValues(alpha: 0.8);
    return AppColors.accent.withValues(alpha: 1.0);
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
              children: data.asMap().entries.map((weekEntry) {
                final weekIdx = weekEntry.key;
                final week = weekEntry.value;
                return Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: Column(
                    children: week.asMap().entries.map((dayEntry) {
                      final dayIdx = dayEntry.key;
                      final val = dayEntry.value;
                      final isSelected =
                          selectedWeek == weekIdx && selectedDay == dayIdx;

                      return GestureDetector(
                        onTap: () => onSelect?.call(weekIdx, dayIdx),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: _cellColor(val.xp),
                              borderRadius: BorderRadius.circular(3),
                              border: isSelected
                                  ? Border.all(color: Colors.white, width: 1.5)
                                  : null,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
