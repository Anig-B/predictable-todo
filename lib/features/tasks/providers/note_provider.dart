import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/note_repository.dart';

class NoteNotifier extends StateNotifier<List<NoteModel>> {
  final Ref ref;
  StreamSubscription<List<NoteModel>>? _sub;

  NoteNotifier(this.ref) : super([]) {
    ref.listen(currentUserProvider, (previous, next) {
      if (next != null) {
        _subscribeToNotes(next.id);
      } else {
        _sub?.cancel();
        state = [];
      }
    });

    final initUser = ref.read(currentUserProvider);
    if (initUser != null) {
      _subscribeToNotes(initUser.id);
    }
  }

  void _subscribeToNotes(String userId) {
    _sub?.cancel();
    debugPrint('DEBUG: Subscribing to Supabase notes for user $userId...');

    _sub = ref.read(noteRepositoryProvider).watchNotes(userId).listen((remoteNotes) {
      debugPrint('DEBUG: Received ${remoteNotes.length} notes from Supabase');
      state = remoteNotes;
    }, onError: (e) {
      debugPrint('DEBUG: Error in notes stream: $e');
    });
  }

  Future<void> loadDemo(List<NoteModel> notes) async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      final previousState = state;
      state = [...notes, ...state];
      
      try {
        await ref.read(noteRepositoryProvider).addNotes(user.id, notes);
      } catch (e) {
        debugPrint('DEBUG: Failed to load demo notes: $e');
        state = previousState;
      }
    }
  }

  Future<void> addNote(String content) async {
    final note = NoteModel(
      id: 'optimistic-${DateTime.now().millisecondsSinceEpoch}',
      content: content,
      createdAt: DateTime.now(),
    );
    
    final user = ref.read(currentUserProvider);
    if (user != null) {
      final previousState = state;
      state = [note, ...state];
      
      try {
        await ref.read(noteRepositoryProvider).addNote(user.id, note);
      } catch (e) {
        debugPrint('DEBUG: Error adding note: $e');
        state = previousState;
      }
    }
  }

  Future<void> updateNote(String id, String content) async {
    final user = ref.read(currentUserProvider);
    
    if (user != null) {
      final note = state.firstWhere((n) => n.id == id);
      final updated = note.copyWith(content: content);
      
      final previousState = state;
      state = state.map((n) => n.id == id ? updated : n).toList();
      
      try {
        await ref.read(noteRepositoryProvider).updateNote(updated);
      } catch (e) {
        debugPrint('DEBUG: Error updating note: $e');
        state = previousState;
      }
    }
  }

  Future<void> deleteNote(String id) async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      final previousState = state;
      state = state.where((n) => n.id != id).toList();
      
      try {
        await ref.read(noteRepositoryProvider).deleteNote(id);
      } catch (e) {
        debugPrint('DEBUG: Error deleting note: $e');
        state = previousState;
      }
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final noteProvider =
    StateNotifierProvider<NoteNotifier, List<NoteModel>>((ref) {
  return NoteNotifier(ref);
});
