import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../tasks/providers/task_provider.dart';
import '../../tasks/models/task_model.dart';
import '../../gamification/providers/gamification_provider.dart';
import '../../../core/data/seed_data.dart';
import '../widgets/charts/donut_chart.dart';
import '../widgets/charts/sparkline_chart.dart';
import '../widgets/charts/bar_chart_widget.dart';
import '../widgets/charts/gauge_chart.dart';
import '../widgets/charts/heatmap_grid.dart';

class StatsPage extends ConsumerStatefulWidget {
  const StatsPage({super.key});

  @override
  ConsumerState<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends ConsumerState<StatsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tState = ref.watch(taskProvider);
    final gState = ref.watch(gamificationProvider);
    final totalXp = tState.doneXp + gState.bonusXp;
    final heatmap = HeatmapGrid.fromLogs(tState.activityLog);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                children: [
                  Text('Stats',
                      style: AppTheme.mono(size: 20, weight: FontWeight.w800)),
                  const Spacer(),
                  Text('$totalXp XP total',
                      style: AppTheme.mono(size: 10, color: AppColors.accent)),
                ],
              ),
            ),
            // Tab bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: AppTheme.surfaceBox(radius: 10),
                padding: const EdgeInsets.all(3),
                child: TabBar(
                  controller: _tabCtrl,
                  indicator: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelStyle: AppTheme.sans(size: 11, weight: FontWeight.w700),
                  unselectedLabelStyle:
                      AppTheme.sans(size: 11, color: AppColors.muted),
                  labelColor: AppColors.bg,
                  unselectedLabelColor: AppColors.muted,
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Projects'),
                    Tab(text: 'Time'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabCtrl,
                children: [
                  _OverviewTab(tState: tState, gState: gState),
                  _ProjectsTab(tState: tState),
                  _TimeTab(heatmap: heatmap),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Overview Tab ─────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  final TaskState tState;
  final GamificationState gState;

  const _OverviewTab({required this.tState, required this.gState});

  List<Map<String, dynamic>> _categoryData() {
    final doneTasks = tState.tasks.where((t) => t.done).toList();
    if (doneTasks.isEmpty) return SeedData.categoryData;

    final totalXp = doneTasks.fold(0, (s, t) => s + t.points);
    if (totalXp == 0) return SeedData.categoryData;

    const colors = {
      TaskCategory.work: AppColors.purple,
      TaskCategory.health: AppColors.accent,
      TaskCategory.learning: AppColors.gold,
      TaskCategory.personal: AppColors.red,
    };

    return TaskCategory.values
        .map((cat) {
          final xp = doneTasks
              .where((t) => t.category == cat)
              .fold(0, (s, t) => s + t.points);
          final pct = (xp / totalXp * 100).round();
          return {'name': cat.label, 'value': pct, 'color': colors[cat]!};
        })
        .where((d) => (d['value'] as int) > 0)
        .toList();
  }

  List<Map<String, dynamic>> _weeklyXpData() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final today = DateTime.now().weekday; // 1=Mon … 7=Sun

    final xpByDay = List.filled(7, 0);
    for (final log in tState.activityLog) {
      if (log.time.startsWith('Today')) {
        xpByDay[today - 1] += log.points;
      } else if (log.time.startsWith('Yesterday')) {
        final yday = (today - 2 + 7) % 7;
        xpByDay[yday] += log.points;
      }
    }

    return List.generate(7, (i) => {'day': days[i], 'xp': xpByDay[i]});
  }

  @override
  Widget build(BuildContext context) {
    final totalXp = tState.doneXp + gState.bonusXp;
    final categoryData = _categoryData();
    final weeklyXp = _weeklyXpData();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 130),
      children: [
        _MomentumCard(tState: tState),
        const SizedBox(height: 16),
        const _SectionLabel('CATEGORY BREAKDOWN'),
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
        const _SectionLabel('WEEKLY XP'),
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
        const _SectionLabel('KEY STATS'),
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

// ── Projects Tab ─────────────────────────────────────────

class _ProjectsTab extends StatelessWidget {
  final TaskState tState;
  const _ProjectsTab({required this.tState});

  List<Map<String, dynamic>> _projectStats() {
    if (tState.tasks.isEmpty) return SeedData.projectStats;

    const colors = [
      AppColors.accent,
      AppColors.purple,
      AppColors.gold,
      AppColors.orange,
      AppColors.red,
    ];

    final projects = <String, Map<String, dynamic>>{};
    for (final task in tState.tasks) {
      final p = task.project;
      projects.putIfAbsent(p, () => {'completed': 0, 'total': 0});
      projects[p]!['total'] = (projects[p]!['total'] as int) + 1;
      if (task.done) {
        projects[p]!['completed'] = (projects[p]!['completed'] as int) + 1;
      }
    }

    return projects.entries.toList().asMap().entries.map((e) {
      final color = colors[e.key % colors.length];
      return {
        'name': e.value.key,
        'completed': e.value.value['completed'],
        'total': e.value.value['total'],
        'color': color,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final projectStats = _projectStats();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 130),
      children: [
        const _SectionLabel('PROJECT PROGRESS'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: AppTheme.surfaceBox(),
          child: HorizontalBarChart(data: projectStats),
        ),
        const SizedBox(height: 16),
        const _SectionLabel('PROJECT DETAILS'),
        const SizedBox(height: 8),
        ...projectStats.map((p) {
          final pct = (p['completed'] as int) / (p['total'] as int);
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

// ── Time Tab ─────────────────────────────────────────────

class _TimeTab extends StatelessWidget {
  final List<List<int>> heatmap;
  const _TimeTab({required this.heatmap});

  @override
  Widget build(BuildContext context) {
    final maxV = SeedData.hourlyData
        .map((d) => d['v'] as int)
        .reduce((a, b) => a > b ? a : b);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 130),
      children: [
        const _SectionLabel('HOURLY ACTIVITY'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: AppTheme.surfaceBox(),
          child: Column(
            children: SeedData.hourlyData.map((d) {
              final pct = (d['v'] as int) / maxV;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(d['h'] as String,
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
        const _SectionLabel('12-WEEK HEATMAP'),
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

// ── Shared ───────────────────────────────────────────────

class _MomentumCard extends StatelessWidget {
  final TaskState tState;
  const _MomentumCard({required this.tState});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final weekAgo = todayStart.subtract(const Duration(days: 7));

    final todayXp = tState.activityLog
        .where((l) => l.createdAt.isAfter(todayStart))
        .fold(0, (s, l) => s + l.points);

    final weekXp = tState.activityLog
        .where((l) =>
            l.createdAt.isAfter(weekAgo) && l.createdAt.isBefore(todayStart))
        .fold(0, (s, l) => s + l.points);

    final avgDailyXp = weekXp / 7;
    final momentum =
        avgDailyXp > 0 ? todayXp / avgDailyXp : (todayXp > 0 ? 2.0 : 1.0);
    final isUp = momentum >= 1.0;

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
                  Text('Productivity Pulse',
                      style: AppTheme.sans(size: 13, weight: FontWeight.w800)),
                  Text(isUp ? 'Generating momentum' : 'Gaining traction',
                      style: AppTheme.sans(size: 9, color: AppColors.subtle)),
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
                      style: AppTheme.mono(size: 8, color: AppColors.subtle)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _MomentumStat(
                  label: 'Today',
                  value: '$todayXp XP',
                  color: AppColors.accent),
              _MomentumStat(
                  label: '7D Avg',
                  value: '${avgDailyXp.round()} XP',
                  color: AppColors.purple),
              _MomentumStat(
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

class _MomentumStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MomentumStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.mono(size: 8, color: AppColors.subtle)),
        const SizedBox(height: 2),
        Text(value,
            style:
                AppTheme.sans(size: 11, weight: FontWeight.w700, color: color)),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: AppTheme.mono(
                size: 9, color: AppColors.subtle, weight: FontWeight.w700)
            .copyWith(letterSpacing: 2));
  }
}
