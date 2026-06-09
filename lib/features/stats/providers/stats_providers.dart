import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../tasks/providers/task_provider.dart';
import '../../tasks/models/task_model.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/charts/heatmap_grid.dart';

final categoryBreakdownProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final tState = ref.watch(taskProvider);
  final doneTasks = tState.tasks.where((t) => t.done).toList();
  if (doneTasks.isEmpty) return [];

  final totalXp = doneTasks.fold(0, (s, t) => s + t.points);
  if (totalXp == 0) return [];

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
});

final weeklyXpProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final tState = ref.watch(taskProvider);
  const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final mondayStart = todayStart.subtract(Duration(days: now.weekday - 1));

  final xpByDay = List.filled(7, 0);
  for (final log in tState.activityLog) {
    if (log.createdAt.isAfter(mondayStart.subtract(const Duration(seconds: 1))) && 
        log.createdAt.isBefore(mondayStart.add(const Duration(days: 7)))) {
      final dayIdx = log.createdAt.weekday - 1;
      xpByDay[dayIdx] += log.points;
    }
  }

  return List.generate(7, (i) => {'day': days[i], 'xp': xpByDay[i]});
});

final hourlyActivityProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final tState = ref.watch(taskProvider);
  if (tState.activityLog.isEmpty) return [];

  final Map<String, int> counts = {};

  for (final log in tState.activityLog) {
    final hour = log.createdAt.hour;
    final suffix = hour >= 12 ? 'p' : 'a';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final label = '$displayHour$suffix';
    counts[label] = (counts[label] ?? 0) + 1;
  }

  final orderedLabels = [
    '6a','7a','8a','9a','10a','11a','12p','1p','2p','3p','4p','5p','6p','7p','8p','9p','10p','11p'
  ];
  
  final List<Map<String, dynamic>> res = [];
  for (final label in orderedLabels) {
    if (counts.containsKey(label)) {
      res.add({'h': label, 'v': counts[label]});
    }
  }
  return res;
});

final projectProgressProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final tState = ref.watch(taskProvider);
  
  const colors = [
    AppColors.accent,
    AppColors.purple,
    AppColors.gold,
    AppColors.orange,
    AppColors.red,
  ];

  if (tState.tasks.isEmpty) return [];

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
});

final heatmapProvider = Provider<List<List<DayStats>>>((ref) {
  final tState = ref.watch(taskProvider);
  return HeatmapGrid.fromLogs(tState.activityLog);
});

class MomentumData {
  final int todayXp;
  final double avgDailyXp;
  final double momentum;
  final bool isUp;
  final int bestDayXp;

  MomentumData({
    required this.todayXp,
    required this.avgDailyXp,
    required this.momentum,
    required this.isUp,
    required this.bestDayXp,
  });
}

final momentumProvider = Provider<MomentumData>((ref) {
  final tState = ref.watch(taskProvider);
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
  final momentum = avgDailyXp > 0 ? todayXp / avgDailyXp : (todayXp > 0 ? 2.0 : 1.0);
  final isUp = momentum >= 1.0;

  final bestDayXp = (() {
    final Map<int, int> xpByDay = {};
    for (final log in tState.activityLog) {
      final day = DateTime(log.createdAt.year, log.createdAt.month, log.createdAt.day);
      xpByDay[day.millisecondsSinceEpoch] =
          (xpByDay[day.millisecondsSinceEpoch] ?? 0) + log.points;
    }
    return xpByDay.values.isEmpty ? 0 : xpByDay.values.reduce((a, b) => a > b ? a : b);
  })();

  return MomentumData(
    todayXp: todayXp,
    avgDailyXp: avgDailyXp,
    momentum: momentum,
    isUp: isUp,
    bestDayXp: bestDayXp,
  );
});
