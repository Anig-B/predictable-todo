import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/stats_providers.dart';
import '../../gamification/providers/gamification_provider.dart';
import 'charts/heatmap_grid.dart';
import 'section_label.dart';

class TimeTab extends ConsumerStatefulWidget {
  const TimeTab({super.key});

  @override
  ConsumerState<TimeTab> createState() => _TimeTabState();
}

class _TimeTabState extends ConsumerState<TimeTab> {
  int? _selWeek;
  int? _selDay;

  String _getDateLabel(int weekIdx, int dayIdx) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final mondayOfThisWeek = today.subtract(Duration(days: today.weekday - 1));
    final mondayOfTargetWeek =
        mondayOfThisWeek.subtract(Duration(days: (11 - weekIdx) * 7));
    final targetDate = mondayOfTargetWeek.add(Duration(days: dayIdx));

    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final daySuffix = (int day) {
      if (day >= 11 && day <= 13) return 'th';
      switch (day % 10) {
        case 1: return 'st';
        case 2: return 'nd';
        case 3: return 'rd';
        default: return 'th';
      }
    }(targetDate.day);

    return '${months[targetDate.month - 1]} ${targetDate.day}$daySuffix';
  }

  Widget _momentumSection(MomentumData m) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.surfaceBox(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Today XP', style: AppTheme.sans(size: 11, color: AppColors.muted)),
                  const SizedBox(height: 2),
                  Text('${m.todayXp} XP', style: AppTheme.mono(size: 18, weight: FontWeight.w800, color: AppColors.gold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: m.isUp ? AppColors.accent.withValues(alpha: 0.1) : AppColors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(m.isUp ? Icons.trending_up : Icons.trending_down, size: 14, color: m.isUp ? AppColors.accent : AppColors.red),
                    const SizedBox(width: 4),
                    Text(
                      '${(m.momentum * 100).toInt()}%',
                      style: AppTheme.mono(size: 11, weight: FontWeight.w700, color: m.isUp ? AppColors.accent : AppColors.red),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatMini(
                  label: 'Weekly Avg',
                  value: '${m.avgDailyXp.toInt()}',
                  icon: Icons.calendar_month,
                ),
              ),
              Container(width: 1, height: 30, color: AppColors.border),
              Expanded(
                child: _StatMini(
                  label: 'Best Day',
                  value: '${m.bestDayXp} XP',
                  icon: Icons.auto_awesome,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final heatmap = ref.watch(heatmapProvider);
    final activityData = ref.watch(hourlyActivityProvider);
    final gState = ref.watch(gamificationProvider);
    final isDefeated = gState.boss.isDefeated;

    final values = activityData
        .map((d) => (d['v'] ?? d['tasks'] ?? 0) as num)
        .map((n) => n.toInt())
        .toList();

    final maxV = values.isEmpty
        ? 1
        : values.reduce((a, b) => a > b ? a : b).clamp(1, 999999);

    final selectedDayStats = (_selWeek != null && _selDay != null)
        ? heatmap[_selWeek!][_selDay!]
        : null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 130),
      children: [
        const SectionLabel('HOURLY ACTIVITY', tooltip: 'When you typically complete tasks, based on activity log timestamps.'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: AppTheme.surfaceBox(),
          child: activityData.isEmpty 
            ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text('No recent activity recorded.', 
                      style: AppTheme.sans(size: 11, color: AppColors.muted, style: FontStyle.italic)),
                ),
              )
            : Column(
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
                                  AppTheme.mono(size: 10, color: AppColors.muted)),
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
        const SectionLabel('WORK CONTEXT & HEATMAP', tooltip: 'Daily XP heatmap for the past 12 weeks. Tap a cell for day details.'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: AppTheme.surfaceBox(),
          child: Column(
            children: [
               Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   HeatmapGrid(
                    data: heatmap,
                    selectedWeek: _selWeek,
                    selectedDay: _selDay,
                    onSelect: (w, d) => setState(() {
                      _selWeek = w;
                      _selDay = d;
                    }),
                  ),
                  if (isDefeated) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.stars, size: 14, color: AppColors.accent),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "YOU CONQUERED THE WEEK!",
                            style: AppTheme.mono(size: 11, weight: FontWeight.w900, color: AppColors.accent).copyWith(letterSpacing: 1),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 12),
              // Detail context at the bottom
              SizedBox(
                height: 34,
                child: selectedDayStats != null 
                  ? Row(
                      children: [
                        Icon(Icons.info_outline, size: 14, color: AppColors.accent.withValues(alpha: 0.6)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: AppTheme.sans(size: 11, color: AppColors.muted),
                              children: [
                                TextSpan(
                                  text: '${_getDateLabel(_selWeek!, _selDay!)}: ',
                                  style: AppTheme.sans(size: 11, weight: FontWeight.w700, color: AppColors.accent),
                                ),
                                TextSpan(
                                  text: '${selectedDayStats.xp} XP',
                                  style: AppTheme.mono(size: 11, weight: FontWeight.w700, color: AppColors.gold),
                                ),
                                if (selectedDayStats.topProject.isNotEmpty) ...[
                                  const TextSpan(text: ' mainly in '),
                                  TextSpan(
                                    text: selectedDayStats.topProject,
                                    style: AppTheme.sans(size: 11, weight: FontWeight.w700, color: AppColors.text),
                                  ),
                                ] else ...[
                                  const TextSpan(text: ' earned.'),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Icon(Icons.touch_app_outlined, size: 14, color: AppColors.muted.withValues(alpha: 0.5)),
                        const SizedBox(width: 8),
                        Text(
                          'Tap a cell above to see daily context...',
                          style: AppTheme.sans(size: 11, color: AppColors.muted, style: FontStyle.italic),
                        ),
                      ],
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const SectionLabel('MOMENTUM & STREAKS', tooltip: 'Today\'s XP, weekly average, and your best single-day XP.'),
        const SizedBox(height: 8),
        _momentumSection(ref.watch(momentumProvider)),
      ],
    );
  }
}

class _StatMini extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  const _StatMini({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: color ?? AppColors.subtle),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTheme.sans(size: 11, color: AppColors.muted)),
            Text(value, style: AppTheme.mono(size: 13, weight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }
}


