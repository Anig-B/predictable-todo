import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/challenge_model.dart';
import '../../tasks/models/task_model.dart';
import '../../../core/data/seed_data.dart';
import 'gamification_provider.dart';

class ChallengeNotifier extends StateNotifier<List<ChallengeModel>> {
  final Ref ref;
  
  ChallengeNotifier(this.ref) : super([]) {
    _init();
  }

  int get doneCount => state.where((c) => c.done).length;
  bool get allDone => state.isNotEmpty && state.every((c) => c.done);

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if we need to reset for a new day
    final lastResetStr = prefs.getString('challenges_last_reset');
    final now = DateTime.now();
    final todayStr = '${now.year}-${now.month}-${now.day}';
    
    if (lastResetStr != todayStr) {
      _rollNewQuests();
      await prefs.setString('challenges_last_reset', todayStr);
    } else {
      final savedStr = prefs.getString('challenges_data');
      if (savedStr != null) {
        try {
          final List decoded = jsonDecode(savedStr);
          state = decoded.map((e) => ChallengeModel.fromJson(e)).toList();
        } catch (e) {
          _rollNewQuests();
        }
      } else {
        _rollNewQuests();
      }
    }
  }

  void _rollNewQuests() {
    final pool = List<ChallengeModel>.from(SeedData.questPool);
    pool.shuffle(Random());
    state = pool.take(3).toList();
    _persist();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('challenges_data', jsonEncode(state.map((c) => c.toJson()).toList()));
  }

  void _progressQuest(ChallengeModel ch, {int amount = 1}) {
    if (ch.done) return;
    
    final newProg = (ch.progress + amount).clamp(0, ch.target);
    final isDone = newProg >= ch.target;
    
    state = state.map((c) {
      if (c.id == ch.id) {
        return c.copyWith(progress: newProg, done: isDone);
      }
      return c;
    }).toList();
    
    _persist();
    
    if (isDone) {
      ref.read(gamificationProvider.notifier).onQuestCompleted(ch.reward);
    }
  }

  void onTaskCompleted(TaskModel task, int completedInRow, bool hasProof) {
    if (state.isEmpty) return;
    final hour = DateTime.now().hour;
    
    for (final ch in state) {
      if (ch.done) continue;
      
      switch (ch.type) {
        case ChallengeType.earlyBird:
          if (hour < 10) _progressQuest(ch);
          break;
        case ChallengeType.tripleThreat:
          if (completedInRow >= ch.target) _progressQuest(ch, amount: ch.target);
          break;
        case ChallengeType.healthHero:
          if (task.category == TaskCategory.health) _progressQuest(ch);
          break;
        case ChallengeType.consistency:
          _progressQuest(ch);
          break;
        case ChallengeType.proofProvider:
          if (hasProof) _progressQuest(ch);
          break;
        case ChallengeType.projectFocus:
          if (task.project.isNotEmpty) _progressQuest(ch);
          break;
        default: break;
      }
    }
  }

  void onBossDamaged(int damageEvents) {
    for (final ch in state) {
      if (!ch.done && ch.type == ChallengeType.bossDamage) {
        _progressQuest(ch, amount: damageEvents);
      }
    }
  }

  void onSocialAction() {
    for (final ch in state) {
      if (!ch.done && ch.type == ChallengeType.socialScout) {
        _progressQuest(ch);
      }
    }
  }
}

final challengeProvider =
    StateNotifierProvider<ChallengeNotifier, List<ChallengeModel>>(
  (ref) => ChallengeNotifier(ref),
);
