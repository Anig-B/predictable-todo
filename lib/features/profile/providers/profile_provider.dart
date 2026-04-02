import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/storage_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/profile_repository.dart';
import '../models/profile_model.dart';

class ProfileNotifier extends StateNotifier<ProfileModel> {
  final Ref ref;
  
  static final _defaultProfile = ProfileModel(
    name: 'Quest Master',
    avatar: '🧑‍💻',
    tagline: '#QUESTLOG',
    project: '',
  );

  ProfileNotifier(this.ref) : super(_defaultProfile) {
    _init();

    ref.listen(currentUserProvider, (previous, next) {
      if (next != null) {
        _fetchRemoteProfile(next.id);
      } else {
        state = _defaultProfile;
      }
    });

    final user = ref.read(currentUserProvider);
    if (user != null) {
      _fetchRemoteProfile(user.id);
    }
  }

  Future<void> _init() async {
    final saved = await StorageService.loadProfile();
    if (saved != null) {
      state = ProfileModel.fromJson(saved);
    }
  }

  Future<void> _fetchRemoteProfile(String userId) async {
    final remote = await ref.read(profileRepositoryProvider).fetchProfile(userId);
    if (remote != null) {
      state = remote;
      await StorageService.saveProfile(state.toJson());
    }
  }

  Future<void> updateProfile({String? name, String? avatar, String? tagline, String? project}) async {
    state = state.copyWith(name: name, avatar: avatar, tagline: tagline, project: project);
    await StorageService.saveProfile(state.toJson());

    final user = ref.read(currentUserProvider);
    if (user != null) {
      await ref.read(profileRepositoryProvider).updateProfile(user.id, state);
    }
  }

  Future<void> reset() async {
    state = _defaultProfile;
    await StorageService.saveProfile(state.toJson());

    final user = ref.read(currentUserProvider);
    if (user != null) {
      await ref.read(profileRepositoryProvider).updateProfile(user.id, state);
    }
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileModel>((ref) {
  return ProfileNotifier(ref);
});
