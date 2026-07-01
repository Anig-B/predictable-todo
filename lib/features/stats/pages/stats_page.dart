import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive_scale.dart';
import '../../gamification/providers/gamification_provider.dart';
import '../widgets/overview_tab.dart';
import '../widgets/projects_tab.dart';
import '../widgets/time_tab.dart';

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
    // Only kept tState if needed later, otherwise will be removed by lint if unused.
    final gState = ref.watch(gamificationProvider);
    final totalXp = gState.totalXp;
    final rs = ResponsiveScale(context);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: rs.tabletCenter(600)(
          Column(
            children: [
              // Header
              Padding(
                padding: rs.fromLTRB(16, 14, 16, 8),
                child: Row(
                  children: [
                    Text('Stats',
                        style: AppTheme.mono(size: rs.f(20), weight: FontWeight.w800)),
                    const Spacer(),
                    Text('$totalXp XP total',
                        style: AppTheme.mono(size: rs.f(11), color: AppColors.accent)),
                  ],
                ),
              ),
              // Tab bar
              Padding(
                padding: rs.symH(16),
                child: Container(
                  decoration: AppTheme.surfaceBox(radius: rs.p(10)),
                  padding: rs.all(3),
                  child: TabBar(
                    controller: _tabCtrl,
                    indicator: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(rs.p(8)),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelStyle: AppTheme.sans(size: rs.f(11), weight: FontWeight.w700),
                    unselectedLabelStyle:
                        AppTheme.sans(size: rs.f(11), color: AppColors.muted),
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
              SizedBox(height: rs.p(8)),
              Expanded(
                child: TabBarView(
                  controller: _tabCtrl,
                  children: const [
                    OverviewTab(),
                    ProjectsTab(),
                    TimeTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
