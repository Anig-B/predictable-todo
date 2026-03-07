import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/storage_service.dart';
import '../models/note_model.dart';

class NoteNotifier extends StateNotifier<List<NoteModel>> {
  NoteNotifier() : super([]) {
    _init();
  }

  Future<void> _init() async {
    final saved = await StorageService.loadNotes();
    if (saved != null) {
      state = saved
          .map((e) => NoteModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
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
