import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/task_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskRepository {
  final SupabaseClient _supabase;
  
  TaskRepository(this._supabase);

  // Get tasks for the current user
  Stream<List<TaskModel>> watchTasks(String userId) {
    return _supabase
        .from('tasks')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((data) => data.map((json) => TaskModel.fromJson(json)).toList());
  }

  // Add a new task
  Future<void> addTask(String userId, TaskModel task) async {
    final data = task.toJson();
    data['user_id'] = userId;
    await _supabase.from('tasks').insert(data);
  }

  // Update a task
  Future<void> updateTask(TaskModel task) async {
    await _supabase.from('tasks').update(task.toJson()).eq('id', task.id);
  }

  // Delete a task
  Future<void> deleteTask(String id) async {
    await _supabase.from('tasks').delete().eq('id', id);
  }

  // Upload proof image
  Future<String?> uploadProofImage(String userId, Uint8List bytes, String ext) async {
    final name = '${DateTime.now().millisecondsSinceEpoch}.$ext';
    final fullPath = '$userId/$name';
    
    await _supabase.storage.from('task-proofs').uploadBinary(fullPath, bytes);
    return _supabase.storage.from('task-proofs').getPublicUrl(fullPath);
  }
  
  // Mark task as completed/uncompleted
  Future<void> setTaskCompletion(String id, bool done, {int? bonusEarned, String? notes, String? imageUrl}) async {
    final updates = <String, dynamic>{
      'done': done,
    };
    if (done) {
      updates['lastCompletedAt'] = DateTime.now().toIso8601String();
      if (bonusEarned != null) updates['bonusEarned'] = bonusEarned;
      if (notes != null) updates['proof_notes'] = notes;
      if (imageUrl != null) updates['proof_image'] = imageUrl;
    } else {
      updates['lastCompletedAt'] = null;
      updates['bonusEarned'] = 0;
      updates['proof_notes'] = null;
      updates['proof_image'] = null;
    }
    
    await _supabase.from('tasks').update(updates).eq('id', id);
  }
}

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(Supabase.instance.client);
});
