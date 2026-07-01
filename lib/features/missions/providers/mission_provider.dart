import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/mission_repository.dart';
import '../models/mission_model.dart';

final missionsProvider = FutureProvider<List<MissionModel>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final repo = ref.read(missionRepositoryProvider);
  return repo.fetchUserMissions(user.id);
});
