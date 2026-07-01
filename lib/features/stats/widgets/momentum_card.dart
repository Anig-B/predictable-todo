import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/stats_providers.dart';

class MomentumCard extends ConsumerWidget {
  const MomentumCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final momentumData = ref.watch(momentumProvider);

    final isUp = momentumData.isUp;
    final momentum = momentumData.momentum;
    final todayXp = momentumData.todayXp;
    final avgDailyXp = momentumData.avgDailyXp;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surface,
            AppColors.surface.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: (isUp ? AppColors.accent : AppColors.red)
                .withValues(alpha: 0.05),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isUp ? AppColors.accent : AppColors.red)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isUp ? Icons.bolt : Icons.trending_flat,
                  color: isUp ? AppColors.accent : AppColors.red,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Productivity Pulse',
                          style: AppTheme.sans(size: 13, weight: FontWeight.w800)),
                      const SizedBox(width: 6),
                      const Tooltip(
                        triggerMode: TooltipTriggerMode.tap,
                        message: 'Your XP today vs your 7-day daily average. Above 1.0x means you\'re outpacing your usual rhythm.',
                        child: Icon(Icons.info_outline, size: 12, color: AppColors.muted),
                      ),
                    ],
                  ),
                  Text(isUp ? 'Generating momentum' : 'Gaining traction',
                      style: AppTheme.sans(size: 10, color: AppColors.subtle)),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${momentum.toStringAsFixed(1)}x',
                      style: AppTheme.mono(
                          size: 18,
                          weight: FontWeight.w900,
                          color: isUp ? AppColors.accent : AppColors.red)),
                  Text('Velocity',
                      style: AppTheme.mono(size: 9, color: AppColors.subtle)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MomentumStat(
                  label: 'Today',
                  value: '$todayXp XP',
                  color: AppColors.accent),
              MomentumStat(
                  label: '7D Avg',
                  value: '${avgDailyXp.round()} XP',
                  color: AppColors.purple),
              MomentumStat(
                  label: 'Status',
                  value: isUp ? 'CRUSHING' : 'CHILLING',
                  color: isUp ? AppColors.gold : AppColors.blue),
            ],
          ),
        ],
      ),
    );
  }
}

class MomentumStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const MomentumStat(
      {super.key, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.mono(size: 9, color: AppColors.subtle)),
        const SizedBox(height: 2),
        Text(value,
            style:
                AppTheme.sans(size: 11, weight: FontWeight.w700, color: color)),
      ],
    );
  }
}
