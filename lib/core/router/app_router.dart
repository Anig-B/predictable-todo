import 'package:go_router/go_router.dart';
import '../../features/shell/pages/main_shell.dart';
import '../../features/tasks/pages/tasks_page.dart';
import '../../features/stats/pages/stats_page.dart';
import '../../features/leaderboard/pages/leaderboard_page.dart';
import '../../features/profile/pages/profile_page.dart';

final appRouter = GoRouter(
  initialLocation: '/tasks',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/tasks',
          pageBuilder: (_, __) => const NoTransitionPage(child: TasksPage()),
        ),
        GoRoute(
          path: '/stats',
          pageBuilder: (_, __) => const NoTransitionPage(child: StatsPage()),
        ),
        GoRoute(
          path: '/leaderboard',
          pageBuilder: (_, __) => const NoTransitionPage(child: LeaderboardPage()),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (_, __) => const NoTransitionPage(child: ProfilePage()),
        ),
      ],
    ),
  ],
);
