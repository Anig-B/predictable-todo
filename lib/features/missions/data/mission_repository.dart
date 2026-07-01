import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mission_model.dart';

class MissionRepository {
  final SupabaseClient _supabase;

  MissionRepository(this._supabase);

  Future<List<MissionModel>> fetchUserMissions(String userId) async {
    final response = await _supabase
        .from('missions')
        .select('*, mission_members!inner(joined_at)')
        .eq('mission_members.user_id', userId)
        .order('created_at', ascending: false);

    return response.map((j) {
      final members = j['mission_members'] as List<dynamic>? ?? [];
      final memberData =
          members.isNotEmpty ? members.first as Map<String, dynamic> : null;
      j['joined_at'] = memberData?['joined_at'];
      return MissionModel.fromJson(j);
    }).toList();
  }

  Future<void> acceptInvite(String missionId, String userId) async {
    await _supabase.from('mission_members').update({
      'joined_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('mission_id', missionId).eq('user_id', userId);
  }

  Future<void> declineInvite(String missionId, String userId) async {
    await _supabase
        .from('mission_members')
        .delete()
        .eq('mission_id', missionId)
        .eq('user_id', userId);
  }
}

final missionRepositoryProvider = Provider<MissionRepository>((ref) {
  return MissionRepository(Supabase.instance.client);
});
