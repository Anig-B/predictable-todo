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

  // Add multiple tasks (batch)
  Future<void> addTasks(String userId, List<TaskModel> tasks) async {
    final list = tasks.map((t) {
      final data = t.toJson();
      data['user_id'] = userId;
      return data;
    }).toList();
    await _supabase.from('tasks').insert(list);
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
      if (notes != null) updates['proof_notes'] = notes;
      if (imageUrl != null) updates['proof_image'] = imageUrl;
      if (bonusEarned != null || notes != null) updates['proof_rating'] = bonusEarned != null ? (bonusEarned > 0 ? 5 : 0) : 0; // Temporary fallback if rating not passed
    } else {
      updates['lastCompletedAt'] = null;
      updates['bonusEarned'] = 0;
      updates['proof_notes'] = null;
      updates['proof_image'] = null;
      updates['proof_rating'] = 0;
    }
    
    await _supabase.from('tasks').update(updates).eq('id', id);
  }

  // Update setTaskCompletion signature to match
  Future<void> setTaskCompletionFull(String id, bool done, {int? bonusEarned, String? notes, String? imageUrl, int? rating}) async {
    final updates = <String, dynamic>{
      'done': done,
    };
    if (done) {
      updates['lastCompletedAt'] = DateTime.now().toIso8601String();
      if (bonusEarned != null) updates['bonusEarned'] = bonusEarned;
      if (notes != null) updates['proof_notes'] = notes;
      if (imageUrl != null) updates['proof_image'] = imageUrl;
      if (rating != null) updates['proof_rating'] = rating;
    } else {
      updates['lastCompletedAt'] = null;
      updates['bonusEarned'] = 0;
      updates['proof_notes'] = null;
      updates['proof_image'] = null;
      updates['proof_rating'] = 0;
    }
    await _supabase.from('tasks').update(updates).eq('id', id);
  }

  // Add activity log
  Future<void> addActivityLog(String userId, Map<String, dynamic> log) async {
    final data = Map<String, dynamic>.from(log);
    data['user_id'] = userId;
    await _supabase.from('activity_logs').insert(data);
  }

  // Fetch activity logs
  Future<List<Map<String, dynamic>>> fetchActivityLogs(String userId) async {
    final response = await _supabase
        .from('activity_logs')
        .select()
        .eq('user_id', userId)
        .order('time', ascending: false)
        .limit(50);
    return response;
  }

  // Delete all user data
  Future<void> deleteAllData(String userId) async {
    // Delete activity logs
    await _supabase.from('activity_logs').delete().eq('user_id', userId);
    // Delete tasks
    await _supabase.from('tasks').delete().eq('user_id', userId);
    // Delete notes
    await _supabase.from('notes').delete().eq('user_id', userId);
    // Reset user stats
    await _supabase.from('user_stats').update({
      'xp': 0,
      'level': 1,
      'current_streak': 0,
      'combo_count': 0,
      'combo_points': 0,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('user_id', userId);
  }
}

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository(Supabase.instance.client);
});
