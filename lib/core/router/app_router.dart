import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/pages/auth_page.dart';
import '../../features/shell/pages/main_shell.dart';
import '../../features/tasks/pages/home_page.dart';
import '../../features/stats/pages/stats_page.dart';
import '../../features/leaderboard/pages/leaderboard_page.dart';
import '../../features/profile/pages/profile_page.dart';
import '../../features/notifications/pages/notifications_page.dart';
import '../../features/gamification/pages/challenges_page.dart';
import '../../features/tasks/pages/add_task_page.dart';
import '../../features/tasks/pages/note_page.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/tasks',
    redirect: (context, state) {
      final isAuthPage = state.matchedLocation == '/auth';
      
      // Wait for auth to be initialized
      if (authState.isLoading) return null;

      final session = authState.value?.session;
      final isAuthenticated = session != null;

      if (!isAuthenticated && !isAuthPage) {
        return '/auth';
      }

      if (isAuthenticated && isAuthPage) {
        return '/tasks';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthPage(),
      ),
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
            pageBuilder: (_, __) =>
                const NoTransitionPage(child: LeaderboardPage()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (_, __) => const NoTransitionPage(child: ProfilePage()),
          ),
        ],
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
      GoRoute(
        path: '/challenges',
        builder: (context, state) => const ChallengesPage(),
      ),
      GoRoute(
        path: '/new-quest',
        builder: (context, state) => const AddTaskPage(),
      ),
      GoRoute(
        path: '/notes',
        builder: (context, state) => const NotePage(),
      ),
    ],
  );
});
