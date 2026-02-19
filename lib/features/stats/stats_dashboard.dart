import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../core/services/firebase_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../models/pipeline_metric_model.dart';
import '../pipeline/pipeline_tracker_screen.dart';
import '../handoff/handoff_screen.dart';
import 'package:intl/intl.dart';
import 'leaderboard_widget.dart';

class StatsDashboard extends StatelessWidget {
  const StatsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = context.read<FirebaseService>();
    final userProfile = context.watch<UserModel?>();

    if (userProfile == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Performance',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const HandoffScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.playlist_add_check_rounded,
                        color: AppTheme.primaryColor,
                      ),
                      tooltip: 'Handoff Checklists',
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PipelineTrackerScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add_chart_rounded, size: 18),
                      label: const Text('Log'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildPipelineSummary(context, firebaseService, userProfile.uid),
            const SizedBox(height: 20),
            _buildQuickStats(),
            const SizedBox(height: 30),
            _buildChartCard(
              context,
              title: 'Completion Rate',
              child: SizedBox(
                height: 200,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: 100,
                    barGroups: [
                      _makeGroupData(0, 85),
                      _makeGroupData(1, 90),
                      _makeGroupData(2, 75),
                      _makeGroupData(3, 95),
                      _makeGroupData(4, 100),
                      _makeGroupData(5, 40),
                      _makeGroupData(6, 60),
                    ],
                    gridData: FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                            return Text(
                              days[value.toInt()],
                              style: const TextStyle(color: AppTheme.greyColor),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildChartCard(
              context,
              title: 'Activity Heatmap',
              child: Container(
                height: 120,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.bgColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 15,
                    crossAxisSpacing: 4,
                    mainAxisSpacing: 4,
                  ),
                  itemCount: 60,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        color: index % 5 == 0
                            ? AppTheme.primaryColor
                            : AppTheme.secondaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
            const LeaderboardWidget(),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(
      children: [
        _buildStatItem('85%', 'Weekly Rate', Icons.trending_up, Colors.green),
        const SizedBox(width: 15),
        _buildStatItem('12', 'Day Streak', Icons.fireplace, Colors.orange),
      ],
    );
  }

  Widget _buildStatItem(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.secondaryColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 15),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              label,
              style: const TextStyle(color: AppTheme.greyColor, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(
    BuildContext context, {
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildPipelineSummary(
    BuildContext context,
    FirebaseService service,
    String userId,
  ) {
    // Get last 7 days including today
    return StreamBuilder<List<PipelineMetricModel>>(
      stream: service.getPipelineMetrics(
        userId,
        DateTime.now().subtract(const Duration(days: 7)),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildChartCard(
            context,
            title: 'Pipeline Health',
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'No data yet. Log your activity!',
                  style: TextStyle(color: AppTheme.greyColor),
                ),
              ),
            ),
          );
        }

        final metrics = snapshot.data!;
        // Simple aggregate for the week or show today's if available
        final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
        final todayMetric = metrics.firstWhere(
          (m) => m.date == todayStr,
          orElse: () => PipelineMetricModel(
            id: '',
            userId: '',
            teamId: '',
            date: '',
            calls: 0,
            connects: 0,
            meetingsBooked: 0,
            timestamp: DateTime.now(),
          ),
        );

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor.withOpacity(0.8),
                AppTheme.primaryColor,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Today\'s Pipeline 🚀',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildPipelineItem(
                    'Calls',
                    todayMetric.calls.toString(),
                    Icons.phone,
                  ),
                  _buildPipelineItem(
                    'Connects',
                    todayMetric.connects.toString(),
                    Icons.record_voice_over,
                  ),
                  _buildPipelineItem(
                    'Meetings',
                    todayMetric.meetingsBooked.toString(),
                    Icons.calendar_today,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPipelineItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  BarChartGroupData _makeGroupData(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: y > 70 ? AppTheme.primaryColor : AppTheme.greyColor,
          width: 12,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
