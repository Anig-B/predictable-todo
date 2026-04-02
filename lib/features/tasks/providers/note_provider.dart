import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/storage_service.dart';
import '../models/note_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/note_repository.dart';

class NoteNotifier extends StateNotifier<List<NoteModel>> {
  final Ref ref;
  StreamSubscription<List<NoteModel>>? _sub;

  NoteNotifier(this.ref) : super([]) {
    _init();

    ref.listen(currentUserProvider, (previous, next) {
      if (next != null) {
        _subscribeToNotes(next.id);
      } else {
        _sub?.cancel();
        // Fallback to local storage when logged out if needed, or clear
        // Here we clear to ensure privacy, but _init will load local on next start
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
    
    // Capture current local state in case we need to sync it up
    final localNotes = List<NoteModel>.from(state);

    _sub = ref.read(noteRepositoryProvider).watchNotes(userId).listen((remoteNotes) {
      debugPrint('DEBUG: Received ${remoteNotes.length} notes from Supabase');
      
      if (remoteNotes.isEmpty && localNotes.isNotEmpty) {
        debugPrint('DEBUG: Remote is empty but local has ${localNotes.length} notes. Syncing up!');
        _syncLocalToRemote(userId, localNotes);
      } else {
        state = remoteNotes;
      }
    }, onError: (e) {
      debugPrint('DEBUG: Error in notes stream: $e');
    });
  }

  Future<void> _syncLocalToRemote(String userId, List<NoteModel> local) async {
    final repo = ref.read(noteRepositoryProvider);
    for (final note in local) {
      try {
        await repo.addNote(userId, note);
      } catch (e) {
        debugPrint('DEBUG: Failed to sync note ${note.id}: $e');
      }
    }
    // The stream will naturally update state once synced
  }

  bool _initialized = false;

  Future<void> _init() async {
    if (_initialized) return;
    debugPrint('DEBUG: Initializing NoteNotifier...');
    final saved = await StorageService.loadNotes();
    if (saved != null) {
      final loaded = saved
          .map((e) => NoteModel.fromJson(e as Map<String, dynamic>))
          .toList();
      debugPrint('DEBUG: Loaded ${loaded.length} local notes');
      state = loaded;
    }
    _initialized = true;
  }

  Future<void> loadDemo(List<NoteModel> notes) async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      // Optimistic
      final previousState = state;
      state = [...notes, ...state];
      
      try {
        final repo = ref.read(noteRepositoryProvider);
        for (final n in notes) {
          await repo.addNote(user.id, n);
        }
      } catch (e) {
        state = previousState;
      }
    } else {
      state = [...notes, ...state];
      await _persist();
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
      // Optimistic update
      final previousState = state;
      state = [note, ...state];
      
      try {
        await ref.read(noteRepositoryProvider).addNote(user.id, note);
      } catch (e) {
        debugPrint('DEBUG: Error adding note: $e');
        state = previousState; // Revert on failure
      }
    } else {
      state = [note, ...state];
      await _persist();
    }
  }

  Future<void> updateNote(String id, String content) async {
    final user = ref.read(currentUserProvider);
    
    if (user != null) {
      final note = state.firstWhere((n) => n.id == id);
      final updated = note.copyWith(content: content);
      
      // Optimistic update
      final previousState = state;
      state = state.map((n) => n.id == id ? updated : n).toList();
      
      try {
        await ref.read(noteRepositoryProvider).updateNote(updated);
      } catch (e) {
        debugPrint('DEBUG: Error updating note: $e');
        state = previousState; // Revert on failure
      }
    } else {
      state = [
        for (final note in state)
          if (note.id == id) note.copyWith(content: content) else note,
      ];
      await _persist();
    }
  }

  Future<void> deleteNote(String id) async {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      // Optimistic update
      final previousState = state;
      state = state.where((n) => n.id != id).toList();
      
      try {
        await ref.read(noteRepositoryProvider).deleteNote(id);
      } catch (e) {
        debugPrint('DEBUG: Error deleting note: $e');
        state = previousState; // Revert on failure
      }
    } else {
      state = state.where((n) => n.id != id).toList();
      await _persist();
    }
  }

  Future<void> _persist() async {
    await StorageService.saveNotes(state.map((n) => n.toJson()).toList());
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
