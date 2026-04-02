import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note_model.dart';

class NoteRepository {
  final SupabaseClient _supabase;

  NoteRepository(this._supabase);

  /// Watch notes for a specific user
  Stream<List<NoteModel>> watchNotes(String userId) {
    return _supabase
        .from('notes')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => NoteModel.fromJson(json)).toList());
  }

  /// Add a new note
  Future<void> addNote(String userId, NoteModel note) async {
    final data = note.toJson();
    data['user_id'] = userId;
    await _supabase.from('notes').insert(data);
  }

  /// Update an existing note
  Future<void> updateNote(NoteModel note) async {
    final data = note.toJson();
    data.remove('id'); // ID is used for filter
    await _supabase.from('notes').update(data).eq('id', note.id);
  }

  /// Delete a note
  Future<void> deleteNote(String id) async {
    await _supabase.from('notes').delete().eq('id', id);
  }
}

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepository(Supabase.instance.client);
});
