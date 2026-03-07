import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/tasks/models/task_model.dart';
import '../../features/tasks/models/activity_log_model.dart';

class StorageService {
  StorageService._();

  static const _keyTasks = 'tasks_v1';
  static const _keyLog = 'activity_log_v1';
  static const _keyGami = 'gamification_v1';
  static const _keyProfile = 'profile_v1';
  static const _keyNotes = 'notes_v1';

  // ── Tasks ────────────────────────────────────────────

  static Future<void> saveTasks(List<TaskModel> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString(_keyTasks, json);
  }

  static Future<List<TaskModel>?> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyTasks);
    if (raw == null) return null;
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => TaskModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Activity log ─────────────────────────────────────

  static Future<void> saveLog(List<ActivityLogModel> log) async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(log.map((l) => l.toJson()).toList());
    await prefs.setString(_keyLog, json);
  }

  static Future<List<ActivityLogModel>?> loadLog() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyLog);
    if (raw == null) return null;
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => ActivityLogModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ── Gamification ─────────────────────────────────────

  static Future<void> saveGamification(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyGami, jsonEncode(data));
  }

  static Future<Map<String, dynamic>?> loadGamification() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyGami);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  // ── Profile ──────────────────────────────────────────

  static Future<void> saveProfile(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyProfile, jsonEncode(data));
  }

  static Future<Map<String, dynamic>?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyProfile);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ── Notes ─────────────────────────────────────────────

  static Future<void> saveNotes(List<Map<String, dynamic>> notes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNotes, jsonEncode(notes));
  }

  static Future<List<dynamic>?> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyNotes);
    if (raw == null) return null;
    return jsonDecode(raw) as List<dynamic>;
  }
}
