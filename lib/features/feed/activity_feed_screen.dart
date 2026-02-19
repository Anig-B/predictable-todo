import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/firebase_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';
import 'package:intl/intl.dart';

class ActivityFeedScreen extends StatelessWidget {
  const ActivityFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseService = context.read<FirebaseService>();
    final userProfile = context.watch<UserModel?>();

    if (userProfile == null || userProfile.currentTeamId == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<List<TaskCompletionModel>>(
      stream: firebaseService.getTeamActivity(userProfile.currentTeamId!),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final activities = snapshot.data!;
        if (activities.isEmpty) {
          return const Center(
            child: Text(
              'No recent activity.',
              style: TextStyle(color: AppTheme.greyColor),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activity = activities[index];
            return _buildActivityItem(context, activity, firebaseService);
          },
        );
      },
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    TaskCompletionModel activity,
    FirebaseService service,
  ) {
    return FutureBuilder<UserModel?>(
      future: service.getUserData(activity.userId),
      builder: (context, userSnapshot) {
        final user = userSnapshot.data;
        if (user == null) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.secondaryColor,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage: user.photoUrl.isNotEmpty
                    ? NetworkImage(user.photoUrl)
                    : null,
                backgroundColor: AppTheme.primaryColor,
                child: user.photoUrl.isEmpty
                    ? Text(
                        user.displayName[0],
                        style: const TextStyle(color: Colors.white),
                      )
                    : null,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        children: [
                          TextSpan(
                            text: user.displayName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: ' completed a task'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _getRelativeTime(activity.timestamp),
                      style: const TextStyle(
                        color: AppTheme.greyColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (activity.result.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          'Result: ${activity.result}',
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.local_fire_department_rounded,
                  color: AppTheme.greyColor,
                ),
                onPressed: () {
                  // Todo: Implement like/reaction logic
                },
              ),
            ],
          ),
        );
      },
    );
  }

  String _getRelativeTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return DateFormat('MMM d').format(time);
    }
  }
}
