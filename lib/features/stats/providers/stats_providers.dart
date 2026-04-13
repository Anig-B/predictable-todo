import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../tasks/providers/task_provider.dart';
import '../../tasks/models/task_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/data/seed_data.dart';
import '../widgets/charts/heatmap_grid.dart';

final categoryBreakdownProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final tState = ref.watch(taskProvider);
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
});

final weeklyXpProvider = Provider<List<Map<String, dynamic>>>((ref) {
  final tState = ref.watch(taskProvider);
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

  if (tState.tasks.isEmpty) {
    return SeedData.projectStats.asMap().entries.map((e) {
      final color = colors[e.key % colors.length];
      return {
        'name': e.value['name'] as String,
        'completed': (e.value['value'] as int) ~/ 10,
        'total': 20,
        'color': color,
      };
    }).toList();
  }

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

final heatmapProvider = Provider<List<List<int>>>((ref) {
  final tState = ref.watch(taskProvider);
  return HeatmapGrid.fromLogs(tState.activityLog);
});

class MomentumData {
  final int todayXp;
  final double avgDailyXp;
  final double momentum;
  final bool isUp;

  MomentumData({
    required this.todayXp,
    required this.avgDailyXp,
    required this.momentum,
    required this.isUp,
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

  return MomentumData(
    todayXp: todayXp,
    avgDailyXp: avgDailyXp,
    momentum: momentum,
    isUp: isUp,
  );
});
