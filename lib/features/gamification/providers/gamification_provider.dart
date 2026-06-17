import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile/data/profile_repository.dart';
import '../models/boss_model.dart';
import '../../../core/data/seed_data.dart';
import '../../../core/utils/xp_calculator.dart';
import '../data/boss_data.dart';
import '../../tasks/providers/task_provider.dart';

class GamificationState {
  final int totalXp;
  final int weeklyXp;
  final int bonusXp; // Local session bonus for UI feedback
  final int comboPoints;
  final int comboCount;
  final int multiplier;
  final BossModel boss;
  final int totalLifetimeTasks;
  final int shields;
  final int lootCount;
  final int nightOwlCount;
  final bool spinUsed;
  final DateTime? lastSpunDate;
  final int currentStreak;
  final DateTime? lastActiveDate;
  final DateTime? lastBossResetDate;
  final String? lastBossId;
  final List<String> unlockedBadges;
  final List<String> selectedBadges;
  final bool bossRewardClaimed;
  final bool dailyQuestRewardClaimed;
  final bool isLoading;

  const GamificationState({
    this.totalXp = 0,
    this.weeklyXp = 0,
    this.bonusXp = 0,
    this.comboPoints = 0,
    this.comboCount = 0,
    this.multiplier = 1,
    required this.boss,
    this.totalLifetimeTasks = 0,
    this.shields = 1,
    this.lootCount = 0,
    this.nightOwlCount = 0,
    this.spinUsed = false,
    this.lastSpunDate,
    this.currentStreak = 0,
    this.lastActiveDate,
    this.lastBossResetDate,
    this.lastBossId,
    this.unlockedBadges = const ['Early Adopter'],
    this.selectedBadges = const [],
    this.bossRewardClaimed = false,
    this.dailyQuestRewardClaimed = false,
    this.isLoading = false,
  });

  int get comboMulti => XpCalculator.comboMultiplier(comboPoints);
  int get effectiveMulti => max(multiplier, comboMulti);

  bool get isSpinAvailable {
    if (lastSpunDate == null) return true;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final spunDate =
        DateTime(lastSpunDate!.year, lastSpunDate!.month, lastSpunDate!.day);
    return todayDate.isAfter(spunDate);
  }

  GamificationState copyWith({
    int? totalXp,
    int? weeklyXp,
    int? bonusXp,
    int? comboPoints,
    int? comboCount,
    int? multiplier,
    BossModel? boss,
    int? totalLifetimeTasks,
    int? shields,
    int? lootCount,
    int? nightOwlCount,
    bool? spinUsed,
    DateTime? lastSpunDate,
    int? currentStreak,
    DateTime? lastActiveDate,
    bool clearLastActiveDate = false,
    DateTime? lastBossResetDate,
    String? lastBossId,
    List<String>? unlockedBadges,
    List<String>? selectedBadges,
    bool? bossRewardClaimed,
    bool? dailyQuestRewardClaimed,
    bool? isLoading,
  }) =>
      GamificationState(
        totalXp: totalXp ?? this.totalXp,
        weeklyXp: weeklyXp ?? this.weeklyXp,
        bonusXp: bonusXp ?? this.bonusXp,
        comboPoints: comboPoints ?? this.comboPoints,
        comboCount: comboCount ?? this.comboCount,
        multiplier: multiplier ?? this.multiplier,
        boss: boss ?? this.boss,
        totalLifetimeTasks: totalLifetimeTasks ?? this.totalLifetimeTasks,
        shields: shields ?? this.shields,
        lootCount: lootCount ?? this.lootCount,
        nightOwlCount: nightOwlCount ?? this.nightOwlCount,
        spinUsed: spinUsed ?? this.spinUsed,
        lastSpunDate: lastSpunDate ?? this.lastSpunDate,
        currentStreak: currentStreak ?? this.currentStreak,
        lastActiveDate: clearLastActiveDate
            ? null
            : (lastActiveDate ?? this.lastActiveDate),
        lastBossResetDate: lastBossResetDate ?? this.lastBossResetDate,
        lastBossId: lastBossId ?? this.lastBossId,
        unlockedBadges: unlockedBadges ?? this.unlockedBadges,
        selectedBadges: selectedBadges ?? this.selectedBadges,
        bossRewardClaimed: bossRewardClaimed ?? this.bossRewardClaimed,
        dailyQuestRewardClaimed: dailyQuestRewardClaimed ?? this.dailyQuestRewardClaimed,
        isLoading: isLoading ?? this.isLoading,
      );

}

const _initialState = GamificationState(
  boss: SeedData.boss,
  isLoading: true,
);

class GamificationNotifier extends StateNotifier<GamificationState> {
  final Ref ref;
  final _supabase = Supabase.instance.client;
  RealtimeChannel? _subscription;

  GamificationNotifier(this.ref) : super(_initialState) {
    ref.listen(currentUserProvider, (previous, next) {
      if (next != null) {
        _fetchRemoteStats(next.id);
        _listenToStats(next.id);
      } else {
        _stopListening();
        state = _initialState;
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        _fetchRemoteStats(user.id);
        _listenToStats(user.id);
      }
    });
  }

  void _listenToStats(String userId) {
    _stopListening();
    _subscription = _supabase
        .channel('public:user_stats:user_id=eq.$userId')
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
              _fetchRemoteStats(userId);
            })
        .subscribe();
  }

  void _stopListening() {
    _subscription?.unsubscribe();
    _subscription = null;
  }

  @override
  void dispose() {
    _stopListening();
    _comboTimer?.cancel();
    super.dispose();
  }

  Timer? _comboTimer;

  void _checkComboExpiry() {
    final last = state.lastActiveDate;
    if (last != null && DateTime.now().difference(last).inHours >= 24 && state.comboPoints > 0) {
      state = state.copyWith(comboPoints: 0, comboCount: 0);
    }
  }

  Future<void> _fetchRemoteStats(String userId) async {
    final stats = await ref.read(profileRepositoryProvider).fetchUserStats(userId);
    if (stats != null) {
      state = state.copyWith(
        currentStreak: stats['current_streak'] as int? ?? state.currentStreak,
        totalXp: stats['xp'] as int? ?? state.totalXp,
        weeklyXp: stats['weekly_xp'] as int? ?? state.weeklyXp,
        bonusXp: stats['bonus_xp'] as int? ?? state.bonusXp,
        comboPoints: stats['combo_points'] as int? ?? state.comboPoints,
        comboCount: stats['combo_count'] as int? ?? state.comboCount,
        shields: stats['shields'] as int? ?? state.shields,
        lootCount: stats['loot_count'] as int? ?? state.lootCount,
        spinUsed: stats['spin_used'] as bool? ?? state.spinUsed,
        lastSpunDate: stats['last_spun_date'] != null
            ? DateTime.tryParse(stats['last_spun_date'] as String)
            : state.lastSpunDate,
        lastBossResetDate: stats['last_boss_reset_at'] != null 
            ? DateTime.tryParse(stats['last_boss_reset_at'] as String) 
            : state.lastBossResetDate,
        boss: BossData.getById(stats['boss_id'] as String? ?? state.boss.id).copyWith(
          hp: stats['boss_hp'] as int? ?? state.boss.hp,
          tasksDone: stats['boss_tasks_done'] as int? ?? state.boss.tasksDone,
        ),
        lastBossId: stats['last_boss_id'] as String? ?? state.lastBossId,
        unlockedBadges: (stats['unlocked_badges'] as List<dynamic>?)?.cast<String>() ?? 
            state.unlockedBadges,
        selectedBadges: (stats['selected_badges'] as List<dynamic>?)?.cast<String>() ?? 
            state.selectedBadges,
        bossRewardClaimed: stats['boss_reward_claimed'] ?? false,
        dailyQuestRewardClaimed: stats['daily_quest_reward_claimed'] ?? false,
        totalLifetimeTasks: stats['total_lifetime_tasks'] ?? state.totalLifetimeTasks,
        nightOwlCount: stats['night_owl_count'] as int? ?? state.nightOwlCount,
        multiplier: stats['multiplier'] as int? ?? state.multiplier,
        isLoading: false,
      );
      _checkComboExpiry();
      _checkWeeklyBossReset();
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  void _syncToRemote() {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    
    ref.read(profileRepositoryProvider).updateUserStats(user.id, {
      'xp': state.totalXp,
      'weekly_xp': state.weeklyXp,
      'bonus_xp': state.bonusXp,
      'combo_points': state.comboPoints,
      'combo_count': state.comboCount,
      'shields': state.shields,
      'loot_count': state.lootCount,
      'current_streak': state.currentStreak,
      'spin_used': state.spinUsed,
      'last_spun_date': state.lastSpunDate?.toIso8601String(),
      'boss_id': state.boss.id,
      'boss_hp': state.boss.hp,
      'boss_tasks_done': state.boss.tasksDone,
      'last_boss_reset_at': state.lastBossResetDate?.toIso8601String(),
      'last_boss_id': state.lastBossId,
      'unlocked_badges': state.unlockedBadges,
      'selected_badges': state.selectedBadges,
      'boss_reward_claimed': state.bossRewardClaimed,
      'daily_quest_reward_claimed': state.dailyQuestRewardClaimed,
      'last_active_at': state.lastActiveDate?.toIso8601String(),
      'total_lifetime_tasks': state.totalLifetimeTasks,
      'night_owl_count': state.nightOwlCount,
      'multiplier': state.multiplier,
    });
  }

  GamificationState _checkBadgeUnlocks(GamificationState s) {
    final newBadges = List<String>.from(s.unlockedBadges);

    if (s.currentStreak >= 7 && !newBadges.contains('7-Day Streak')) {
      newBadges.add('7-Day Streak');
    }
    if (s.boss.isDefeated && !newBadges.contains('Boss Slayer')) {
      newBadges.add('Boss Slayer');
    }
    if (s.totalLifetimeTasks >= 100 && !newBadges.contains('Gem Collector')) {
      newBadges.add('Gem Collector');
    }
    if (s.totalLifetimeTasks >= 50 && !newBadges.contains('Perfect Week')) {
      newBadges.add('Perfect Week');
    }
    if (s.nightOwlCount >= 10 && !newBadges.contains('Night Owl')) {
      newBadges.add('Night Owl');
    }
    if (s.boss.id == 'mystery_genie' && s.boss.isDefeated && !newBadges.contains('Mystery Genie')) {
      newBadges.add('Mystery Genie');
    }
    if (s.comboCount >= 5 && !newBadges.contains('Focus Master')) {
      newBadges.add('Focus Master');
    }
    if (s.totalXp >= 5000 && !newBadges.contains('Peak Performer')) {
      newBadges.add('Peak Performer');
    }
    if (s.totalLifetimeTasks >= 200 && !newBadges.contains('Weekend Warrior')) {
      newBadges.add('Weekend Warrior');
    }

    if (newBadges.length == s.unlockedBadges.length) return s;
    return s.copyWith(unlockedBadges: newBadges);
  }

  int _updatedStreak() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final last = state.lastActiveDate;

    if (last == null) return 1;

    final lastDate = DateTime(last.year, last.month, last.day);
    final diff = todayDate.difference(lastDate).inDays;

    if (diff == 0) return state.currentStreak;
    if (diff == 1) return state.currentStreak + 1;
    return 1;
  }

  void _checkWeeklyBossReset() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysSinceMonday = (today.weekday - 1) % 7;
    final lastMonday = today.subtract(Duration(days: daysSinceMonday));

    final lastReset = state.lastBossResetDate;
    final isNewWeek = lastReset == null || lastReset.isBefore(lastMonday);

    if (isNewWeek) {
      final newBossId = _determineWeeklyBoss();
      state = state.copyWith(
        lastBossId: state.boss.id,
        boss: BossData.getById(newBossId),
        lastBossResetDate: lastMonday,
        bossRewardClaimed: false,
        dailyQuestRewardClaimed: false,
      );
        _syncToRemote();
    }
  }

  String _determineWeeklyBoss() {
    final tasks = ref.read(taskProvider).tasks;
    final activity = ref.read(taskProvider).activityLog;

    // Condition 1: Rare Mystery Genie (Once a month-ish check)
    // For simplicity, we'll use a random chance if the user was consistent last week
    final lastWeekActivity = activity.where((a) {
      return a.createdAt
          .isAfter(DateTime.now().subtract(const Duration(days: 7)));
    }).length;

    final isConsistent = lastWeekActivity >= 10; // Averaging 1.5 tasks per day
    if (isConsistent && Random().nextDouble() < 0.2) {
      return 'mystery_genie';
    }

    // Condition 2: Overwhelmed -> Chaos Lord
    if (tasks.where((t) => !t.done).length > 15) {
      return 'chaos_lord';
    }

    // Condition 3: Procrastination Zombie
    final overdueCount = tasks.where((t) => !t.done && t.isOverdue).length;
    if (overdueCount > 5 || (state.currentStreak < 2 && lastWeekActivity > 0)) {
      return 'procrastination_zombie';
    }

    // Condition 4: Lazy Master
    if (lastWeekActivity == 0) {
      return 'lazy_master';
    }

    // Default or fallback
    final available = ['chaos_lord', 'procrastination_zombie', 'lazy_master'];
    available.remove(state.boss.id); // Avoid repeating the same boss
    return available[Random().nextInt(available.length)];
  }

  int onTaskCompleted(int basePoints) {
    final pet = XpCalculator.currentPet(state.totalLifetimeTasks);
    final companionXp = pet.xpBonus;
    final companionDmg = pet.bossDmgBonus;

    final multi = state.effectiveMulti;
    final bonus = multi > 1 ? basePoints * (multi - 1) : 0;
    final newComboPoints = state.comboPoints + basePoints;
    final newComboCount = state.comboCount + 1;

    _comboTimer?.cancel();
    _comboTimer = Timer(const Duration(hours: 24), () {
      if (mounted) {
        state = state.copyWith(comboPoints: 0, comboCount: 0);
      }
    });

    final dmg = state.boss.damagePerTask + companionDmg;
    final newHp = (state.boss.hp - dmg).clamp(0, state.boss.maxHp);
    final newBoss = state.boss.copyWith(
      hp: newHp,
      tasksDone: state.boss.tasksDone + 1,
    );

    final earnedXp = basePoints + bonus + companionXp;
    final hour = DateTime.now().hour;
    final isNightOwl = hour >= 20;
    final newNightOwlCount = isNightOwl ? state.nightOwlCount + 1 : state.nightOwlCount;

    final now = DateTime.now();
    final thisMonday = now.subtract(Duration(days: now.weekday - 1));
    final lastActiveDay = state.lastActiveDate;
    final sameWeek = lastActiveDay != null &&
        lastActiveDay.isAfter(thisMonday.subtract(const Duration(days: 1)));
    final newWeeklyXp = sameWeek ? state.weeklyXp + earnedXp : earnedXp;

    state = state.copyWith(
      totalXp: state.totalXp + earnedXp,
      weeklyXp: newWeeklyXp,
      comboPoints: newComboPoints,
      bonusXp: state.bonusXp + bonus,
      comboCount: newComboCount,
      multiplier: multi > 1 ? 1 : state.multiplier,
      boss: newBoss,
      totalLifetimeTasks: state.totalLifetimeTasks + 1,
      lootCount: state.lootCount + 1,
      nightOwlCount: newNightOwlCount,
      currentStreak: _updatedStreak(),
      lastActiveDate: DateTime.now(),
    );
    state = _checkBadgeUnlocks(state);
    _syncToRemote();

    return bonus + companionXp;
  }

  void onTaskUncompleted(int basePoints, int bonusEarned) {
    final pet = XpCalculator.currentPet(state.totalLifetimeTasks);
    final companionDmg = pet.bossDmgBonus;

    final lostXp = basePoints + bonusEarned;
    
    // Boss defeat is sticky. If boss is dead, don't revive.
    int newHp = state.boss.hp;
    int newTasksDone = state.boss.tasksDone;
    if (!state.boss.isDefeated) {
      final dmg = state.boss.damagePerTask + companionDmg;
      newHp = (state.boss.hp + dmg).clamp(0, state.boss.maxHp);
      newTasksDone = (state.boss.tasksDone - 1).clamp(0, 999);
    }

    state = state.copyWith(
      totalXp: (state.totalXp - lostXp).clamp(0, 9999999),
      weeklyXp: (state.weeklyXp - lostXp).clamp(0, 9999999),
      bonusXp: (state.bonusXp - bonusEarned).clamp(0, 999999),
      comboPoints: (state.comboPoints - basePoints).clamp(0, 999999),
      comboCount: (state.comboCount - 1).clamp(0, 999),
      boss: state.boss.copyWith(
        hp: newHp,
        tasksDone: newTasksDone,
      ),
      totalLifetimeTasks: (state.totalLifetimeTasks - 1).clamp(0, 999999),
    );

    if (state.comboCount == 0) {
      _comboTimer?.cancel();
      state = state.copyWith(comboPoints: 0);
    }
    _syncToRemote();
  }

  void onTaskMissed(int lostPoints) {
    if (!state.boss.isDefeated) {
      final dmg = state.boss.damagePerTask;
      final newHp = (state.boss.hp + dmg).clamp(0, state.boss.maxHp);
      state = state.copyWith(
        boss: state.boss.copyWith(
          hp: newHp,
        ),
      );
        _syncToRemote();
    }
  }

  void onQuestCompleted(int rewardXp) {
    state = state.copyWith(
      totalXp: state.totalXp + rewardXp,
      bonusXp: state.bonusXp + rewardXp,
    );
    _syncToRemote();
  }

  void addProofBonus(int amount) {
    if (amount <= 0) return;
    state = state.copyWith(
      totalXp: state.totalXp + amount,
      bonusXp: state.bonusXp + amount,
    );
    _syncToRemote();
  }

  void applySpinResult(Map<String, dynamic> seg) {
    final type = seg['type'] as String;
    final value = seg['value'] as int;
    if (type == 'xp') {
      state = state.copyWith(
        totalXp: state.totalXp + value,
        bonusXp: state.bonusXp + value,
      );
    }
    if (type == 'multi') state = state.copyWith(multiplier: value);
    if (type == 'shield') state = state.copyWith(shields: state.shields + 1);
    state = state.copyWith(spinUsed: true, lastSpunDate: DateTime.now());
    _syncToRemote();
  }

  void applyLootItem(String itemName) {
    switch (itemName) {
      case 'Focus Potion':
        state = state.copyWith(
          totalXp: state.totalXp + 150,
          bonusXp: state.bonusXp + 150,
        );
      case 'Golden Ticket':
        state = state.copyWith(multiplier: 3);
      case 'Chaos Shield':
        state = state.copyWith(shields: state.shields + 1);
    }
    _syncToRemote();
  }

  void resetBossForTesting() {
    final ids = BossData.bosses.keys.toList();
    final currentIdx = ids.indexOf(state.boss.id);
    final nextIdx = (currentIdx + 1) % ids.length;
    final nextBossId = ids[nextIdx];

    state = state.copyWith(
      lastBossId: state.boss.id,
      boss: BossData.getById(nextBossId),
      lastBossResetDate: DateTime.now(), // Force reset current week
    );
    _syncToRemote();
  }

  Future<void> reset() async {
    _comboTimer?.cancel();
    state = _initialState;
    _syncToRemote();
    final user = ref.read(currentUserProvider);
    if (user != null) {
      await _supabase.from('user_stats').update({
        'last_spun_date': null,
        'spin_used': false,
        'night_owl_count': 0,
        'multiplier': 1,
      }).eq('user_id', user.id);
    }
    state = state.copyWith(isLoading: false);
  }

  void toggleBadgeSelection(String badgeName) {
    if (!state.unlockedBadges.contains(badgeName)) return;

    final current = List<String>.from(state.selectedBadges);
    if (current.contains(badgeName)) {
      current.remove(badgeName);
    } else {
      if (current.length >= 3) current.removeAt(0);
      current.add(badgeName);
    }
    state = state.copyWith(selectedBadges: current);
    _syncToRemote();
  }

  Future<bool> claimBossReward() async {
    if (!state.boss.isDefeated || state.bossRewardClaimed) return false;
    try {
      final response = await _supabase.rpc('claim_boss_reward');
      if (response != null && response['success'] == true) {
        state = _checkBadgeUnlocks(state.copyWith(bossRewardClaimed: true));
            return true;
      }
    } catch (e) {
       // Silently fail or handle error appropriately in production
    }
    // Optimistic fallback for local UI if offline
    state = _checkBadgeUnlocks(state.copyWith(
      totalXp: state.totalXp + state.boss.reward,
      bossRewardClaimed: true,
    ));
    return true;
  }

  bool get shouldShowLoot => state.lootCount > 0 && state.lootCount % 5 == 0;

  void claimDailyQuestReward() {
    state = state.copyWith(dailyQuestRewardClaimed: true);
    _syncToRemote();
  }

  void resetDailyQuestReward() {
    state = state.copyWith(dailyQuestRewardClaimed: false);
    _syncToRemote();
  }
}

final gamificationProvider =
    StateNotifierProvider<GamificationNotifier, GamificationState>(
  (ref) => GamificationNotifier(ref),
);
