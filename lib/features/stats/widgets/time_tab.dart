import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/data/seed_data.dart';
import '../../tasks/providers/task_provider.dart';
import '../providers/stats_providers.dart';
import 'charts/heatmap_grid.dart';
import 'section_label.dart';

class TimeTab extends ConsumerWidget {
  const TimeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tState = ref.watch(taskProvider);
    final heatmap = ref.watch(heatmapProvider);

    final activityData =
        tState.hourlyData.isNotEmpty ? tState.hourlyData : SeedData.hourlyData;

    final values = activityData
        .map((d) => (d['v'] ?? d['tasks'] ?? 0) as num)
        .map((n) => n.toInt())
        .toList();

    final maxV = values.isEmpty
        ? 1
        : values.reduce((a, b) => a > b ? a : b).clamp(1, 999999);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 130),
      children: [
        const SectionLabel('HOURLY ACTIVITY'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: AppTheme.surfaceBox(),
          child: Column(
            children: activityData.asMap().entries.map((entry) {
              final d = entry.value;
              final val = values[entry.key];
              final pct = val / maxV;
              final label = (d['h'] ?? d['hour'] ?? '--') as String;

              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(label,
                          textAlign: TextAlign.right,
                          style:
                              AppTheme.mono(size: 9, color: AppColors.muted)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 14,
                          backgroundColor: AppColors.surface2,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.accent),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
        const SectionLabel('12-WEEK HEATMAP'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: AppTheme.surfaceBox(),
          child: HeatmapGrid(data: heatmap),
        ),
      ],
    );
  }
}
