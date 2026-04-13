import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/stats_providers.dart';
import 'charts/bar_chart_widget.dart';
import 'section_label.dart';

class ProjectsTab extends ConsumerWidget {
  const ProjectsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectStats = ref.watch(projectProgressProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 130),
      children: [
        const SectionLabel('PROJECT PROGRESS'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: AppTheme.surfaceBox(),
          child: HorizontalBarChart(data: projectStats),
        ),
        const SizedBox(height: 16),
        const SectionLabel('PROJECT DETAILS'),
        const SizedBox(height: 8),
        ...projectStats.map((p) {
          final pct = (p['total'] as int) > 0 
              ? (p['completed'] as int) / (p['total'] as int)
              : 0.0;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: AppTheme.surfaceBox(),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: p['color'] as Color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p['name'] as String,
                          style:
                              AppTheme.sans(size: 12, weight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 4,
                          backgroundColor: AppColors.surface3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              p['color'] as Color),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text('${p['completed']}/${p['total']}',
                    style: AppTheme.mono(size: 10, color: AppColors.muted)),
              ],
            ),
          );
        }),
      ],
    );
  }
}
