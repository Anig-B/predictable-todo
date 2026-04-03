import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../profile/data/profile_repository.dart';
import '../models/boss_model.dart';
import '../models/skill_node_model.dart';
import '../../../core/data/seed_data.dart';
import '../../../core/utils/xp_calculator.dart';
import '../../../core/services/storage_service.dart';
import '../data/boss_data.dart';
import '../../tasks/providers/task_provider.dart';

class GamificationState {
  final int totalXp;
  final int bonusXp; // Local session bonus for UI feedback
  final int comboPoints;
  final int comboCount;
  final int multiplier;
  final BossModel boss;
  final int totalLifetimeTasks;
  final int shields;
  final int lootCount;
  final int skillPoints;
  final List<SkillNodeModel> skillTree;
  final bool spinUsed;
  final DateTime? lastSpunDate;
  final int currentStreak;
  final DateTime? lastActiveDate;
  final DateTime? lastBossResetDate;
  final String? lastBossId;
  final List<String> unlockedBadges;
  final bool isLoading;

  const GamificationState({
    this.totalXp = 0,
    this.bonusXp = 0,
    this.comboPoints = 0,
    this.comboCount = 0,
    this.multiplier = 1,
    required this.boss,
    this.totalLifetimeTasks = 0,
    this.shields = 1,
    this.lootCount = 0,
    this.skillPoints = 0,
    required this.skillTree,
    this.spinUsed = false,
    this.lastSpunDate,
    this.currentStreak = 0,
    this.lastActiveDate,
    this.lastBossResetDate,
    this.lastBossId,
    this.unlockedBadges = const ['Early Adopter', '7-Day Streak', 'Perfect Week'],
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
    int? bonusXp,
    int? comboPoints,
    int? comboCount,
    int? multiplier,
    BossModel? boss,
    int? totalLifetimeTasks,
    int? shields,
    int? lootCount,
    int? skillPoints,
    List<SkillNodeModel>? skillTree,
    bool? spinUsed,
    DateTime? lastSpunDate,
    int? currentStreak,
    DateTime? lastActiveDate,
    bool clearLastActiveDate = false,
    DateTime? lastBossResetDate,
    String? lastBossId,
    List<String>? unlockedBadges,
    bool? isLoading,
  }) =>
      GamificationState(
        totalXp: totalXp ?? this.totalXp,
        bonusXp: bonusXp ?? this.bonusXp,
        comboPoints: comboPoints ?? this.comboPoints,
        comboCount: comboCount ?? this.comboCount,
        multiplier: multiplier ?? this.multiplier,
        boss: boss ?? this.boss,
        totalLifetimeTasks: totalLifetimeTasks ?? this.totalLifetimeTasks,
        shields: shields ?? this.shields,
        lootCount: lootCount ?? this.lootCount,
        skillPoints: skillPoints ?? this.skillPoints,
        skillTree: skillTree ?? this.skillTree,
        spinUsed: spinUsed ?? this.spinUsed,
        lastSpunDate: lastSpunDate ?? this.lastSpunDate,
        currentStreak: currentStreak ?? this.currentStreak,
        lastActiveDate: clearLastActiveDate
            ? null
            : (lastActiveDate ?? this.lastActiveDate),
        lastBossResetDate: lastBossResetDate ?? this.lastBossResetDate,
        lastBossId: lastBossId ?? this.lastBossId,
        unlockedBadges: unlockedBadges ?? this.unlockedBadges,
        isLoading: isLoading ?? this.isLoading,
      );

  Map<String, dynamic> toJson() => {
        'totalXp': totalXp,
        'bonusXp': bonusXp,
        'comboPoints': comboPoints,
        'comboCount': comboCount,
        'totalLifetimeTasks': totalLifetimeTasks,
        'shields': shields,
        'lootCount': lootCount,
        'skillPoints': skillPoints,
        'spinUsed': spinUsed,
        'lastSpunDate': lastSpunDate?.toIso8601String(),
        'bossHp': boss.hp,
        'bossDone': boss.tasksDone,
        'unlockedSkills':
            skillTree.where((s) => s.unlocked).map((s) => s.id).toList(),
        'currentStreak': currentStreak,
        'lastActiveDate': lastActiveDate?.toIso8601String(),
        'lastBossResetDate': lastBossResetDate?.toIso8601String(),
        'bossId': boss.id,
        'lastBossId': lastBossId,
        'unlockedBadges': unlockedBadges,
      };
}

const _initialState = GamificationState(
  boss: SeedData.boss,
  skillTree: SeedData.skillTree,
  isLoading: true,
);

class GamificationNotifier extends StateNotifier<GamificationState> {
  final Ref ref;

  GamificationNotifier(this.ref) : super(_initialState) {
    _init();

    ref.listen(currentUserProvider, (previous, next) {
      if (next != null) {
        _fetchRemoteStats(next.id);
      } else {
        state = _initialState;
      }
    });

    final user = ref.read(currentUserProvider);
    if (user != null) {
      _fetchRemoteStats(user.id);
    }
  }

  Timer? _comboTimer;

  Future<void> _init() async {
    final saved = await StorageService.loadGamification();
    if (saved == null) return;

    final unlockedIds = (saved['unlockedSkills'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toSet() ??
        {};

    DateTime? parseDate(String key) {
      final s = saved[key] as String?;
      return s != null ? DateTime.tryParse(s) : null;
    }

    state = GamificationState(
      totalXp: saved['totalXp'] as int? ?? 0,
      bonusXp: saved['bonusXp'] as int? ?? 0,
      comboPoints: saved['comboPoints'] as int? ?? 0,
      comboCount: saved['comboCount'] as int? ?? 0,
      totalLifetimeTasks: saved['totalLifetimeTasks'] as int? ?? 0,
      shields: saved['shields'] as int? ?? 1,
      lootCount: saved['lootCount'] as int? ?? 0,
      skillPoints: saved['skillPoints'] as int? ?? 0,
      spinUsed: saved['spinUsed'] as bool? ?? false,
      lastSpunDate: parseDate('lastSpunDate'),
      currentStreak: saved['currentStreak'] as int? ?? 0,
      lastBossResetDate: parseDate('lastBossResetDate'),
      lastBossId: saved['lastBossId'] as String?,
      unlockedBadges: (saved['unlockedBadges'] as List<dynamic>?)?.cast<String>() ?? 
          ['Early Adopter', '7-Day Streak', 'Perfect Week'],
      boss: BossData.getById(saved['bossId'] as String? ?? 'chaos_lord').copyWith(
        hp: saved['bossHp'] as int? ?? SeedData.boss.hp,
        tasksDone: saved['bossDone'] as int? ?? 0,
      ),
      skillTree: SeedData.skillTree
          .map((s) =>
              s.copyWith(unlocked: unlockedIds.contains(s.id) || s.unlocked))
          .toList(),
      isLoading: false,
    );

    _checkWeeklyBossReset();
  }

  Future<void> _fetchRemoteStats(String userId) async {
    final stats = await ref.read(profileRepositoryProvider).fetchUserStats(userId);
    if (stats != null) {
      state = state.copyWith(
        currentStreak: stats['current_streak'] as int? ?? 0,
        totalXp: stats['xp'] as int? ?? state.totalXp,
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
        isLoading: false,
      );
      _persist();
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  void _syncBossToRemote() {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    
    ref.read(profileRepositoryProvider).updateUserStats(user.id, {
      'boss_id': state.boss.id,
      'boss_hp': state.boss.hp,
      'boss_tasks_done': state.boss.tasksDone,
      'last_boss_reset_at': state.lastBossResetDate?.toIso8601String(),
      'last_boss_id': state.lastBossId,
      'unlocked_badges': state.unlockedBadges,
    });
  }

  void _persist() {
    StorageService.saveGamification(state.toJson());
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
      );
      _persist();
      _syncBossToRemote();
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
    final multi = state.effectiveMulti;
    final bonus = multi > 1 ? basePoints * (multi - 1) : 0;
    final newComboPoints = state.comboPoints + basePoints;
    final newComboCount = state.comboCount + 1;

    _comboTimer?.cancel();
    _comboTimer = Timer(const Duration(hours: 24), () {
      if (mounted) {
        state = state.copyWith(comboPoints: 0, comboCount: 0);
        _persist();
      }
    });

    final dmg = state.boss.damagePerTask;
    final newHp = (state.boss.hp - dmg).clamp(0, state.boss.maxHp);
    final newBoss = state.boss.copyWith(
      hp: newHp,
      tasksDone: state.boss.tasksDone + 1,
    );

    final earnedXp = basePoints + bonus;
    final spGained = earnedXp ~/ 10;
    
    // Achievement Logic: Unlock 'Mystery Achievement' if Mystery Genie is defeated
    List<String> newBadges = List.from(state.unlockedBadges);
    if (newBoss.id == 'mystery_genie' && newBoss.isDefeated && !newBadges.contains('Mystery Genie')) {
       newBadges.add('Mystery Genie');
    }

    state = state.copyWith(
      totalXp: state.totalXp + earnedXp,
      comboPoints: newComboPoints,
      comboCount: newComboCount,
      multiplier: multi > 1 ? 1 : state.multiplier,
      bonusXp: state.bonusXp + bonus,
      boss: newBoss,
      totalLifetimeTasks: state.totalLifetimeTasks + 1,
      lootCount: state.lootCount + 1,
      currentStreak: _updatedStreak(),
      lastActiveDate: DateTime.now(),
      skillPoints: state.skillPoints + spGained,
      unlockedBadges: newBadges,
    );
    _persist();
    _syncBossToRemote();

    return bonus;
  }

  void onTaskUncompleted(int basePoints, int bonusEarned) {
    final dmg = state.boss.damagePerTask;
    final newHp = (state.boss.hp + dmg).clamp(0, state.boss.maxHp);
    final lostXp = basePoints + bonusEarned;

    state = state.copyWith(
      totalXp: (state.totalXp - lostXp).clamp(0, 9999999),
      bonusXp: (state.bonusXp - bonusEarned).clamp(0, 999999),
      comboPoints: (state.comboPoints - basePoints).clamp(0, 999999),
      comboCount: (state.comboCount - 1).clamp(0, 999),
      boss: state.boss.copyWith(
        hp: newHp,
        tasksDone: (state.boss.tasksDone - 1).clamp(0, 999),
      ),
      totalLifetimeTasks: (state.totalLifetimeTasks - 1).clamp(0, 999999),
    );

    if (state.comboCount == 0) {
      _comboTimer?.cancel();
      state = state.copyWith(comboPoints: 0);
    }
    _persist();
    _syncBossToRemote();
  }

  void applySpinResult(Map<String, dynamic> seg) {
    final type = seg['type'] as String;
    final value = seg['value'] as int;
    if (type == 'xp') state = state.copyWith(bonusXp: state.bonusXp + value);
    if (type == 'multi') state = state.copyWith(multiplier: value);
    if (type == 'shield') state = state.copyWith(shields: state.shields + 1);
    state = state.copyWith(spinUsed: true, lastSpunDate: DateTime.now());
    _persist();
  }

  void applyLootItem(String itemName) {
    if (itemName.contains('XP')) {
      state = state.copyWith(bonusXp: state.bonusXp + 150);
    }
    if (itemName.contains('Shield')) {
      state = state.copyWith(shields: state.shields + 1);
    }
    if (itemName.contains('Multiplier')) state = state.copyWith(multiplier: 3);
    _persist();
  }

  bool unlockSkill(String id) {
    final node = state.skillTree
        .firstWhere((s) => s.id == id, orElse: () => state.skillTree.first);
    if (node.unlocked || state.skillPoints < node.cost) return false;
    state = state.copyWith(
      skillPoints: state.skillPoints - node.cost,
      skillTree: state.skillTree
          .map((s) => s.id == id ? s.copyWith(unlocked: true) : s)
          .toList(),
    );
    _persist();
    return true;
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
    _persist();
    _syncBossToRemote();
  }

  Future<void> reset() async {
    _comboTimer?.cancel();
    state = _initialState;
    _persist();
  }

  bool get shouldShowLoot => state.lootCount > 0 && state.lootCount % 5 == 0;

  @override
  void dispose() {
    _comboTimer?.cancel();
    super.dispose();
  }
}

final gamificationProvider =
    StateNotifierProvider<GamificationNotifier, GamificationState>(
  (ref) => GamificationNotifier(ref),
);
