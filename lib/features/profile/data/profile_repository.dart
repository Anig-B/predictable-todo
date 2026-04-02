import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileRepository {
  final SupabaseClient _supabase;

  ProfileRepository(this._supabase);

  Future<ProfileModel?> fetchProfile(String userId) async {
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;

    return ProfileModel(
      name: response['username'] ?? 'Quest Master',
      avatar: response['avatar_url'] ?? '🧑‍💻',
      tagline: response['tagline'] ?? '#QUESTLOG',
      project: response['project'] ?? '',
    );
  }

  Future<Map<String, dynamic>?> fetchUserStats(String userId) async {
    final response = await _supabase
        .from('user_stats')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    
    return response;
  }

  Future<void> updateProfile(String userId, ProfileModel profile) async {
    await _supabase.from('profiles').upsert({
      'id': userId,
      'username': profile.name,
      'avatar_url': profile.avatar,
      'tagline': profile.tagline,
      'project': profile.project,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(Supabase.instance.client);
});
