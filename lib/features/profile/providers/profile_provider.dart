import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/storage_service.dart';
import '../models/profile_model.dart';

class ProfileNotifier extends StateNotifier<ProfileModel> {
  ProfileNotifier()
      : super(ProfileModel(
          name: 'Quest Master',
          avatar: '🧑‍💻',
          tagline: '#QUESTLOG',
          project: '',
        )) {
    _init();
  }

  Future<void> _init() async {
    final saved = await StorageService.loadProfile();
    if (saved != null) {
      state = ProfileModel.fromJson(saved);
    }
  }

  Future<void> updateProfile(
      {String? name, String? avatar, String? tagline, String? project}) async {
    state = state.copyWith(
        name: name, avatar: avatar, tagline: tagline, project: project);
    await StorageService.saveProfile(state.toJson());
  }

  Future<void> reset() async {
    state = ProfileModel(
      name: 'Quest Master',
      avatar: '🧑‍💻',
      tagline: '#QUESTLOG',
      project: '',
    );
    await StorageService.saveProfile(state.toJson());
  }
}

final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileModel>((ref) {
  return ProfileNotifier();
});
