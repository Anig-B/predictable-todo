import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/firebase_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';

class TaskManagerScreen extends StatelessWidget {
  const TaskManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = context.read<FirebaseService>();
    final userProfile = context.watch<UserModel?>();

    if (userProfile == null || userProfile.currentTeamId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<List<TaskDefinitionModel>>(
        stream: firebaseService.getTasksForTeam(userProfile.currentTeamId!),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = snapshot.data!;

          if (tasks.isEmpty) {
            return const Center(
              child: Text(
                'No recurring tasks found.',
                style: TextStyle(color: AppTheme.greyColor),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return _buildTaskCard(context, task);
            },
          );
        },
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, TaskDefinitionModel task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        title: Text(
          task.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${task.recurrenceType.name.toUpperCase()} • ${task.category.name.toUpperCase()}',
          style: const TextStyle(color: AppTheme.greyColor, fontSize: 12),
        ),
        trailing: Switch(
          value: task.isActive,
          activeThumbColor: AppTheme.primaryColor,
          onChanged: (v) {
            // TODO: Implement toggle active status
          },
        ),
        onTap: () {
          // TODO: Implement edit task
        },
      ),
    );
  }
}
