import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leaderboard_entry_model.dart';
import '../data/leaderboard_repository.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../social/providers/social_provider.dart';

// Provides leaderboard entries based on standard filters: weekly, all-time, friends, project
final leaderboardListProvider = FutureProvider.family<List<LeaderboardEntry>, String>((ref, filter) async {
  final repo = ref.watch(leaderboardRepositoryProvider);
  final user = ref.watch(currentUserProvider);
  final profile = ref.watch(profileProvider);
  
  if (user == null) return [];

  switch (filter) {
    case 'weekly':
      return await repo.fetchWeeklyTop(5, excludeId: user.id);
    case 'all-time':
      return await repo.fetchAllTimeTop(10, excludeId: user.id);
    case 'friends':
      // Watch friends list to trigger re-fetch when it changes.
      ref.watch(socialProvider.select((s) => s.friends));
      return await repo.fetchFriends(user.id);
    case 'project':
      return await repo.fetchProjectMembers(profile.project, excludeId: user.id);
    default:
      return [];
  }
});
