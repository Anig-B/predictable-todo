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

            return Scaffold(
              backgroundColor: Colors.transparent,
              body: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('EEEE, MMM d').format(DateTime.now()),
                            style: const TextStyle(
                              color: AppTheme.greyColor,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Your Daily Habits',
                            style: Theme.of(context).textTheme.displaySmall,
                          ),
                          const SizedBox(height: 20),
                          _buildStreakCard(),
                          const SizedBox(height: 30),
                          const Text(
                            'TODAY\'S TASKS',
                            style: TextStyle(
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
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
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final task = todayTasks[index];
                        final isDone = completedTaskIds.contains(task.id);
                        return _buildTaskItem(
                          context,
                          task,
                          isDone,
                          userProfile,
                        );
                      }, childCount: todayTasks.length),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStreakCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Current Streak',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                '12 Days',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Icon(
            Icons.fireplace_rounded,
            color: Colors.orangeAccent,
            size: 50,
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(
    BuildContext context,
    TaskDefinitionModel task,
    bool isDone,
    UserModel user,
  ) {
    Color categoryColor = task.category == TaskCategory.spear
        ? Colors.blue
        : (task.category == TaskCategory.seed ? Colors.green : Colors.purple);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor,
        borderRadius: BorderRadius.circular(15),
        border: isDone
            ? Border.all(color: AppTheme.successColor.withOpacity(0.5))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 5,
            height: 40,
            decoration: BoxDecoration(
              color: isDone ? AppTheme.successColor : categoryColor,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    decoration: isDone ? TextDecoration.lineThrough : null,
                    color: isDone ? AppTheme.greyColor : Colors.white,
                  ),
                ),
                Text(
                  task.category.name.toUpperCase(),
                  style: TextStyle(
                    color: isDone ? AppTheme.greyColor : categoryColor,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              if (!isDone) {
                context.read<FirebaseService>().completeTask(
                  taskId: task.id,
                  userId: user.uid,
                  teamId: user.currentTeamId!,
                  status: 'completed',
                );
              }
            },
            icon: Icon(
              isDone
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              color: isDone ? AppTheme.successColor : AppTheme.greyColor,
            ),
          ),
        ],
      ),
    );
  }
}
