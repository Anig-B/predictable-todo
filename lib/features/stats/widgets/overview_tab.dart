import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/xp_calculator.dart';
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
    final totalXp = gState.totalXp;
    
    final categoryData = ref.watch(categoryBreakdownProvider);
    final weeklyXp = ref.watch(weeklyXpProvider);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 130),
      children: [
        const MomentumCard(),
        const SizedBox(height: 16),
        const SectionLabel('CATEGORY BREAKDOWN'),
        const SizedBox(height: 8),
        categoryData.isEmpty 
          ? Container(
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: AppTheme.surfaceBox(),
              child: Column(
                children: [
                   const Text('📊', style: TextStyle(fontSize: 32)),
                   const SizedBox(height: 12),
                   Text('No task patterns yet', style: AppTheme.sans(size: 14, weight: FontWeight.w700)),
                   const SizedBox(height: 4),
                   Text('Complete tasks to see your focus areas', style: AppTheme.sans(size: 11, color: AppColors.muted)),
                ],
              ),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final chartSize = constraints.maxWidth < 300 ? 90.0 : 126.0;
                return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                DonutChart(data: categoryData, size: chartSize),
                const SizedBox(width: 16),
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
            );
              },
            ),
        const SizedBox(height: 16),
        const SectionLabel('WEEKLY XP'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: AppTheme.surfaceBox(),
          child: weeklyXp.every((d) => d['xp'] == 0)
            ? Column(
                children: [
                  const SizedBox(height: 20),
                  Text('No activity recorded yet for this week', 
                      style: AppTheme.sans(size: 11, color: AppColors.subtle, style: FontStyle.italic)),
                  const SizedBox(height: 20),
                ],
              )
            : Column(
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
        LayoutBuilder(
          builder: (context, constraints) {
            final gaugeSize = ((constraints.maxWidth - 16) / 3).clamp(52.0, 90.0);
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GaugeChart(
                  value: tState.doneCount.toDouble(),
                  max: tState.totalCount > 0 ? tState.totalCount.toDouble() : 1,
                  label: 'DONE',
                  color: AppColors.accent,
                  size: gaugeSize,
                ),
                GaugeChart(
                  value: XpCalculator.xpInLevel(totalXp).toDouble(),
                  max: XpCalculator.xpPerLevel.toDouble(),
                  label: 'XP',
                  color: AppColors.purple,
                  size: gaugeSize,
                ),
                GaugeChart(
                  value: gState.comboPoints.toDouble(),
                  max: gState.comboPoints >= 500 ? 500.0 : (gState.comboPoints >= 250 ? 500.0 : (gState.comboPoints >= 100 ? 250.0 : 100.0)),
                  label: 'COMBO XP',
                  color: AppColors.gold,
                  size: gaugeSize,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
