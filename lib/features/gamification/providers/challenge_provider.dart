import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'dart:convert';
import '../models/challenge_model.dart';
import '../../tasks/models/task_model.dart';
import '../../../core/data/seed_data.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile/data/profile_repository.dart';
import 'gamification_provider.dart';
import 'effects_provider.dart';

class ChallengeNotifier extends StateNotifier<List<ChallengeModel>> {
  final Ref ref;
  final _supabase = Supabase.instance.client;
  RealtimeChannel? _subscription;
  
  ChallengeNotifier(this.ref) : super([]) {
    _init();

    ref.listen(currentUserProvider, (previous, next) {
      if (next != null) {
        _syncFromRemote(next.id);
        _listenToRemote(next.id);
      } else {
        _stopListening();
        state = [];
      }
    });

    final user = ref.read(currentUserProvider);
    if (user != null) {
      _syncFromRemote(user.id);
      _listenToRemote(user.id);
    }
  }

  int get doneCount => state.where((c) => c.done).length;
  bool get allDone => state.isNotEmpty && state.every((c) => c.done);

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStr = prefs.getString('challenges_data');
    if (savedStr != null) {
      try {
        final List decoded = jsonDecode(savedStr);
        state = decoded.map((e) => ChallengeModel.fromJson(e)).toList();
      } catch (_) {}
    }
  }

  void _listenToRemote(String userId) {
    _stopListening();
    _subscription = _supabase
        .channel('public:user_stats:quests:$userId')
        .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'user_stats',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) {
              _syncFromRemote(userId);
            })
        .subscribe();
  }

  void _stopListening() {
    _subscription?.unsubscribe();
    _subscription = null;
  }

  Future<void> _syncFromRemote(String userId) async {
    final stats = await ref.read(profileRepositoryProvider).fetchUserStats(userId);
    if (stats == null) return;

    final questsRaw = stats['daily_quests'] as List<dynamic>?;
    final lastResetStr = stats['quests_last_reset_at'] as String?;
    final lastReset = lastResetStr != null ? DateTime.tryParse(lastResetStr) : null;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    bool needsReset = false;
    if (lastReset == null) {
      needsReset = true;
    } else {
      final lastResetDate = DateTime(lastReset.year, lastReset.month, lastReset.day);
      if (today.isAfter(lastResetDate)) {
        needsReset = true;
      }
    }

    if (needsReset) {
      _rollNewQuests(userId);
    } else if (questsRaw != null) {
      final remoteQuests = questsRaw.map((e) => ChallengeModel.fromJson(e)).toList();
      if (jsonEncode(remoteQuests) != jsonEncode(state)) {
        state = remoteQuests;
        _persist();
      }
    }
  }

  void _rollNewQuests(String userId) {
    final pool = List<ChallengeModel>.from(SeedData.questPool);
    pool.shuffle(Random());
    state = pool.take(3).toList();
    _persist();
    _syncToRemote(userId, isReset: true);
    ref.read(gamificationProvider.notifier).resetDailyQuestReward();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('challenges_data', jsonEncode(state.map((c) => c.toJson()).toList()));
  }

  void _syncToRemote(String userId, {bool isReset = false}) {
    final Map<String, dynamic> data = {
      'daily_quests': state.map((c) => c.toJson()).toList(),
    };
    if (isReset) {
      data['quests_last_reset_at'] = DateTime.now().toIso8601String();
    }
    ref.read(profileRepositoryProvider).updateUserStats(userId, data);
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

    final user = ref.read(currentUserProvider);
    if (user != null) {
      _syncToRemote(user.id);
    }
    
    if (isDone) {
      ref.read(gamificationProvider.notifier).onQuestCompleted(ch.reward);
      _showCompletionToast();
    }
  }

  void _showCompletionToast() {
    final count = state.where((c) => c.done).length;
    final total = state.length;
    if (total == 0) return;

    String icon = '📜';
    String title = '$count/$total Daily Quests!';
    String desc = '';

    if (count == 1) {
      desc = '1 daily task complete! Complete remaining 2 for bonus prizes. 🎁';
    } else if (count == 2) {
      icon = '✨';
      desc = '2 daily tasks complete! Only 1 left for your bonus chest! 🎁';
    } else if (count == 3) {
      icon = '🏆';
      title = 'All Quests Cleared!';
      desc = 'Claim your bonus reward in the Scrolls section! ✨';
    }

    if (desc.isNotEmpty) {
      ref.read(effectsProvider.notifier).showToast(
            icon: icon,
            title: title,
            desc: desc,
          );
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

  @override
  void dispose() {
    _stopListening();
    super.dispose();
  }
}

final challengeProvider =
    StateNotifierProvider<ChallengeNotifier, List<ChallengeModel>>(
  (ref) => ChallengeNotifier(ref),
);
