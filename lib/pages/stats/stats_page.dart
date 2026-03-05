import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/task_provider.dart';
import '../../providers/gamification_provider.dart';
import '../../core/data/seed_data.dart';
import '../../widgets/charts/donut_chart.dart';
import '../../widgets/charts/sparkline_chart.dart';
import '../../widgets/charts/bar_chart_widget.dart';
import '../../widgets/charts/gauge_chart.dart';
import '../../widgets/charts/heatmap_grid.dart';

class StatsPage extends ConsumerStatefulWidget {
  const StatsPage({super.key});

  @override
  ConsumerState<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends ConsumerState<StatsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  final _heatmap = HeatmapGrid.generate();

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
                      style: AppTheme.mono(
                          size: 20, weight: FontWeight.w800)),
                  const Spacer(),
                  Text('$totalXp XP total',
                      style: AppTheme.mono(
                          size: 10, color: AppColors.accent)),
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
                  dividerColor: Colors.transparent,
                  labelStyle:
                      AppTheme.sans(size: 11, weight: FontWeight.w700),
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
                  _ProjectsTab(),
                  _TimeTab(heatmap: _heatmap),
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
  final dynamic tState;
  final dynamic gState;

  const _OverviewTab({required this.tState, required this.gState});

  @override
  Widget build(BuildContext context) {
    final totalXp = tState.doneXp + gState.bonusXp;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 130),
      children: [
        _SectionLabel('CATEGORY BREAKDOWN'),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DonutChart(data: SeedData.categoryData),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: SeedData.categoryData.map((d) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          color: d['color'] as Color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(d['name'] as String,
                            style: AppTheme.sans(size: 11, weight: FontWeight.w600)),
                      ),
                      Text('${d['value']}%',
                          style: AppTheme.mono(size: 9, color: AppColors.muted)),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _SectionLabel('WEEKLY XP'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: AppTheme.surfaceBox(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SparklineChart(data: SeedData.weeklyXp),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: SeedData.weeklyXp.map((d) => Text(
                  d['day'] as String,
                  style: AppTheme.mono(size: 8, color: AppColors.subtle),
                )).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _SectionLabel('KEY STATS'),
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
                value: gState.combo.toDouble(),
                max: 10,
                label: 'COMBO',
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
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 130),
      children: [
        _SectionLabel('PROJECT PROGRESS'),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: AppTheme.surfaceBox(),
          child: HorizontalBarChart(data: SeedData.projectStats),
        ),
        const SizedBox(height: 16),
        _SectionLabel('PROJECT DETAILS'),
        const SizedBox(height: 8),
        ...SeedData.projectStats.map((p) {
          final pct = (p['completed'] as int) / (p['total'] as int);
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: AppTheme.surfaceBox(),
            child: Row(
              children: [
                Container(
                  width: 10, height: 10,
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
                          style: AppTheme.sans(size: 12, weight: FontWeight.w700)),
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
        _SectionLabel('HOURLY ACTIVITY'),
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
                          style: AppTheme.mono(
                              size: 9, color: AppColors.muted)),
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
        _SectionLabel('12-WEEK HEATMAP'),
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

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: AppTheme.mono(size: 9, color: AppColors.subtle, weight: FontWeight.w700)
            .copyWith(letterSpacing: 2));
  }
}
