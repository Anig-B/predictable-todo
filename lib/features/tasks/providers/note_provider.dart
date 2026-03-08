import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/storage_service.dart';
import '../models/note_model.dart';

class NoteNotifier extends StateNotifier<List<NoteModel>> {
  NoteNotifier() : super([]) {
    _init();
  }

  bool _initialized = false;

  Future<void> _init() async {
    if (_initialized) return;
    final saved = await StorageService.loadNotes();
    if (saved != null) {
      final loaded = saved
          .map((e) => NoteModel.fromJson(e as Map<String, dynamic>))
          .toList();
      state = [
        ...loaded,
        ...state.where((n) => !loaded.any((l) => l.id == n.id))
      ];
    }
    _initialized = true;
  }

  Future<void> addNote(String content) async {
    final note = NoteModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      createdAt: DateTime.now(),
    );
    state = [note, ...state];
    await _persist();
  }

  Future<void> loadDemo(List<NoteModel> notes) async {
    await _init(); // Ensure we don't overwrite
    state = [...notes, ...state];
    await _persist();
  }

  Future<void> updateNote(String id, String content) async {
    state = [
      for (final note in state)
        if (note.id == id) note.copyWith(content: content) else note,
    ];
    await _persist();
  }

  Future<void> deleteNote(String id) async {
    state = state.where((n) => n.id != id).toList();
    await _persist();
  }

  Future<void> _persist() async {
    await StorageService.saveNotes(state.map((n) => n.toJson()).toList());
  }
}

final noteProvider =
    StateNotifierProvider<NoteNotifier, List<NoteModel>>((ref) {
  return NoteNotifier();
});
