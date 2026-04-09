import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leaderboard_entry_model.dart';

class LeaderboardRepository {
  final SupabaseClient _supabase;

  LeaderboardRepository(this._supabase);

  // Fetch top N users globally inside leaderboard_view.
  Future<List<LeaderboardEntry>> fetchAllTimeTop(int limit,
      {String? excludeId}) async {
    final response = await _supabase
        .from('leaderboard_view')
        .select()
        .order('xp', ascending: false)
        .limit(limit);

    final List<LeaderboardEntry> list = (response as List)
        .map((json) => LeaderboardEntry.fromJson(json))
        .toList();
    if (excludeId != null) {
      return list.where((e) => e.id != excludeId).toList();
    }
    return list;
  }

  // Fetch top N users weekly.
  Future<List<LeaderboardEntry>> fetchWeeklyTop(int limit,
      {String? excludeId}) async {
    final response = await _supabase
        .from('leaderboard_view')
        .select()
        .order('weekly_xp', ascending: false)
        .limit(limit);

    final List<LeaderboardEntry> list = (response as List)
        .map((json) => LeaderboardEntry.fromJson(json))
        .toList();
    if (excludeId != null) {
      return list.where((e) => e.id != excludeId).toList();
    }
    return list;
  }

  // Fetch friends
  Future<List<LeaderboardEntry>> fetchFriends(String userId) async {
    // Both sides of friendship
    final resp1 =
        await _supabase.from('friends').select('uid_2').eq('uid_1', userId);
    final resp2 =
        await _supabase.from('friends').select('uid_1').eq('uid_2', userId);

    final friendIds = <String>{};
    for (var r in resp1) {
      friendIds.add(r['uid_2']);
    }
    for (var r in resp2) {
      friendIds.add(r['uid_1']);
    }

    if (friendIds.isEmpty) return [];

    final response = await _supabase
        .from('leaderboard_view')
        .select()
        .inFilter('user_id', friendIds.toList())
        .order('xp', ascending: false);

    return (response as List)
        .map((json) => LeaderboardEntry.fromJson(json))
        .toList();
  }

  // Fetch project members
  Future<List<LeaderboardEntry>> fetchProjectMembers(String projectId,
      {String? excludeId}) async {
    if (projectId.isEmpty) return [];

    final response = await _supabase
        .from('leaderboard_view')
        .select()
        .eq('project', projectId)
        .order('xp', ascending: false);

    final List<LeaderboardEntry> list = (response as List)
        .map((json) => LeaderboardEntry.fromJson(json))
        .toList();
    if (excludeId != null) {
      return list.where((e) => e.id != excludeId).toList();
    }
    return list;
  }

  // Fetch true rank by XP
  Future<int> fetchRankByField(String userId, String field, int value) async {
    final response = await _supabase
        .from('leaderboard_view')
        .select('user_id')
        .gt(field, value);

    return (response as List).length + 1;
  }

  // Fetch all friend IDs for current user.
  Future<Set<String>> fetchFriendIds(String userId) async {
    final resp = await _supabase
        .from('friends')
        .select('uid_1, uid_2')
        .or('uid_1.eq.$userId,uid_2.eq.$userId');

    final ids = <String>{};
    for (var r in (resp as List)) {
      if (r['uid_1'] == userId) {
        ids.add(r['uid_2']);
      } else {
        ids.add(r['uid_1']);
      }
    }
    return ids;
  }

  // Send a challenge to another user
  Future<void> sendChallenge(String fromId, String toId) async {
    await _supabase.from('social_challenges').insert({
      'challenger_id': fromId,
      'challenged_id': toId,
      'status': 'pending',
      'reward': 0, // Assigned on completion
    });
  }

  // Fetch pending challenges for a user (sent or received)
  Future<List<Map<String, dynamic>>> fetchPendingChallenges(
      String userId) async {
    final response = await _supabase
        .from('social_challenges')
        .select()
        .eq('status', 'pending')
        .or('challenger_id.eq.$userId,challenged_id.eq.$userId');

    return List<Map<String, dynamic>>.from(response);
  }

  // Check if two users are already friends
  Future<bool> checkFriendship(String uid1, String uid2) async {
    final response = await _supabase
        .from('friends')
        .select()
        .or('and(uid_1.eq.$uid1,uid_2.eq.$uid2),and(uid_1.eq.$uid2,uid_2.eq.$uid1)')
        .maybeSingle();

    return response != null;
  }
}

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  return LeaderboardRepository(Supabase.instance.client);
});
