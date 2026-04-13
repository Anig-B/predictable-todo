import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../tasks/providers/task_provider.dart';
import '../../gamification/providers/gamification_provider.dart';
import '../providers/stats_providers.dart';
import 'charts/donut_chart.dart';
import 'charts/sparkline_chart.dart';
import 'charts/gauge_chart.dart';
import 'momentum_card.dart';
import 'section_label.dart';

class OverviewTab extends ConsumerWidget {
  const OverviewTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tState = ref.watch(taskProvider);
    final gState = ref.watch(gamificationProvider);
    final totalXp = tState.doneXp + gState.bonusXp;
    
    final categoryData = ref.watch(categoryBreakdownProvider);
    final weeklyXp = ref.watch(weeklyXpProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 130),
      children: [
        const MomentumCard(),
        const SizedBox(height: 16),
        const SectionLabel('CATEGORY BREAKDOWN'),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DonutChart(data: categoryData),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: categoryData
                    .map((d) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: d['color'] as Color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(d['name'] as String,
                                    style: AppTheme.sans(
                                        size: 11, weight: FontWeight.w600)),
                              ),
                              Text('${d['value']}%',
                                  style: AppTheme.mono(
                                      size: 9, color: AppColors.muted)),
                            ],
                          ),
                        ))
                    .toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const SectionLabel('WEEKLY XP'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: AppTheme.surfaceBox(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SparklineChart(data: weeklyXp),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: weeklyXp
                    .map((d) => Text(
                          d['day'] as String,
                          style:
                              AppTheme.mono(size: 8, color: AppColors.subtle),
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectionLabel('KEY STATS'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GaugeChart(
                value: tState.doneCount.toDouble(),
                max: tState.totalCount > 0 ? tState.totalCount.toDouble() : 1,
                label: 'DONE',
                color: AppColors.accent,
              ),
            ),
            Expanded(
              child: GaugeChart(
                value: totalXp.toDouble(),
                max: 3000,
                label: 'XP',
                color: AppColors.purple,
              ),
            ),
            Expanded(
              child: GaugeChart(
                value: gState.comboPoints.toDouble(),
                max: 500,
                label: 'COMBO XP',
                color: AppColors.gold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
