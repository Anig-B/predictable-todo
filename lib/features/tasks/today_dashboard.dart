import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../core/services/firebase_service.dart';
import 'package:intl/intl.dart';

class TodayDashboard extends StatelessWidget {
  const TodayDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = context.read<FirebaseService>();
    final userProfile = context.watch<UserModel?>();

    if (userProfile == null || userProfile.currentTeamId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final dayOfWeek = DateTime.now().weekday;

    return StreamBuilder<List<TaskDefinitionModel>>(
      stream: firebaseService.getTasksForTeam(userProfile.currentTeamId!),
      builder: (context, taskSnapshot) {
        if (taskSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final allTasks = taskSnapshot.data ?? [];
        final todayTasks = allTasks.where((task) {
          if (task.recurrenceType == RecurrenceType.daily) return true;
          if (task.recurrenceType == RecurrenceType.weekly) {
            return task.daysOfWeek.contains(dayOfWeek);
          }
          if (task.recurrenceType == RecurrenceType.monthly) {
            return task.dayOfMonth == DateTime.now().day;
          }
          return false;
        }).toList();

        return StreamBuilder<List<TaskCompletionModel>>(
          stream: firebaseService.getCompletionsForUser(userProfile.uid, today),
          builder: (context, completionSnapshot) {
            final completions = completionSnapshot.data ?? [];
            final completedTaskIds = completions
                .where((c) => c.status == 'completed')
                .map((c) => c.taskId)
                .toSet();

            final completionRate = todayTasks.isEmpty
                ? 0
                : ((completedTaskIds.length / todayTasks.length) * 100).round();

            return Scaffold(
              backgroundColor: Colors.transparent,
              body: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date line
                          Text(
                            DateFormat('EEEE, MMM d').format(DateTime.now()),
                            style: const TextStyle(
                              color: AppTheme.greyColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Text(
                            "Today's Mission",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textColor,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // ── 4 stat cards ─────────────────────────────
                          Row(
                            children: [
                              _StatCard(
                                label: 'Completion',
                                value: '$completionRate%',
                                gradient: AppTheme.emeraldGradient,
                                icon: Icons.check_circle_rounded,
                                change: '+12%',
                              ),
                              const SizedBox(width: 10),
                              _StatCard(
                                label: 'Tasks Today',
                                value: '${todayTasks.length}',
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF60A5FA),
                                    Color(0xFF06B6D4),
                                  ],
                                ),
                                icon: Icons.task_alt_rounded,
                                change: '${completedTaskIds.length} done',
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              _StatCard(
                                label: 'Streak',
                                value: '12',
                                gradient: AppTheme.orangeGradient,
                                icon: Icons.local_fire_department_rounded,
                                change: 'Best: 21',
                              ),
                              const SizedBox(width: 10),
                              _StatCard(
                                label: 'Team Rank',
                                value: '#2',
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFA78BFA),
                                    Color(0xFFEC4899),
                                  ],
                                ),
                                icon: Icons.emoji_events_rounded,
                                change: '↑ 1',
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),
                          const Text(
                            "TODAY'S TASKS",
                            style: TextStyle(
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),

                  if (todayTasks.isEmpty)
                    const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: Text(
                            'No tasks scheduled for today!',
                            style: TextStyle(color: AppTheme.greyColor),
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final task = todayTasks[index];
                          final isDone = completedTaskIds.contains(task.id);
                          return _TaskCard(
                            task: task,
                            isDone: isDone,
                            user: userProfile,
                          );
                        }, childCount: todayTasks.length),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ── Stat card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final LinearGradient gradient;
  final IconData icon;
  final String change;

  const _StatCard({
    required this.label,
    required this.value,
    required this.gradient,
    required this.icon,
    required this.change,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.greyColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              change,
              style: const TextStyle(
                color: AppTheme.successColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Task card ────────────────────────────────────────────────────────────────

class _TaskCard extends StatelessWidget {
  final TaskDefinitionModel task;
  final bool isDone;
  final UserModel user;

  const _TaskCard({
    required this.task,
    required this.isDone,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final (badgeBg, badgeText, typeName) = _typeBadge(task.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDone
            ? Colors.white.withValues(alpha: 0.35)
            : Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Check button
          GestureDetector(
            onTap: () {
              if (!isDone) {
                context.read<FirebaseService>().completeTask(
                  taskId: task.id,
                  userId: user.uid,
                  teamId: user.currentTeamId!,
                  status: 'completed',
                );
              }
            },
            child: Icon(
              isDone
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              color: isDone ? AppTheme.successColor : AppTheme.subtleColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: isDone ? AppTheme.greyColor : AppTheme.textColor,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    decorationColor: AppTheme.greyColor,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        typeName,
                        style: TextStyle(
                          color: badgeText,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.local_fire_department,
                            color: Colors.orange,
                            size: 12,
                          ),
                          SizedBox(width: 2),
                          Text(
                            '12',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (task.priority == TaskPriority.high) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE4E6),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'HIGH',
                          style: TextStyle(
                            color: Color(0xFFE11D48),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color, String) _typeBadge(TaskCategory category) {
    switch (category) {
      case TaskCategory.spear:
        return (AppTheme.spearBg, AppTheme.spearText, 'Spear');
      case TaskCategory.seed:
        return (AppTheme.seedBg, AppTheme.seedText, 'Seed');
      case TaskCategory.net:
        return (AppTheme.netBg, AppTheme.netText, 'Net');
      default:
        return (const Color(0xFFF1F5F9), AppTheme.greyColor, category.name);
    }
  }
}
