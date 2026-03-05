import 'package:go_router/go_router.dart';
import '../../pages/shell/main_shell.dart';
import '../../pages/tasks/tasks_page.dart';
import '../../pages/stats/stats_page.dart';
import '../../pages/leaderboard/leaderboard_page.dart';
import '../../pages/profile/profile_page.dart';

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
