import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/boss_model.dart';
import '../models/skill_node_model.dart';
import '../../../core/data/seed_data.dart';
import '../../../core/utils/xp_calculator.dart';
import '../../../core/services/storage_service.dart';

class GamificationState {
  final int bonusXp;
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

  const GamificationState({
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
  });

  int get comboMulti => XpCalculator.comboMultiplier(comboPoints);
  int get effectiveMulti => max(multiplier, comboMulti);

  /// Spin resets daily — available if never spun or spun on a previous day.
  bool get isSpinAvailable {
    if (lastSpunDate == null) return true;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final spunDate =
        DateTime(lastSpunDate!.year, lastSpunDate!.month, lastSpunDate!.day);
    return todayDate.isAfter(spunDate);
  }

  GamificationState copyWith({
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
  }) =>
      GamificationState(
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
      );

  Map<String, dynamic> toJson() => {
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
      };
}

const _initialState = GamificationState(
  boss: SeedData.boss,
  skillTree: SeedData.skillTree,
);

class GamificationNotifier extends StateNotifier<GamificationState> {
  GamificationNotifier() : super(_initialState) {
    _init();
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
      lastActiveDate: parseDate('lastActiveDate'),
      lastBossResetDate: parseDate('lastBossResetDate'),
      boss: SeedData.boss.copyWith(
        hp: saved['bossHp'] as int? ?? SeedData.boss.hp,
        tasksDone: saved['bossDone'] as int? ?? 0,
      ),
      skillTree: SeedData.skillTree
          .map((s) =>
              s.copyWith(unlocked: unlockedIds.contains(s.id) || s.unlocked))
          .toList(),
    );

    _checkWeeklyBossReset();
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
    return 1; // streak broken
  }

  /// Resets the boss if a new Monday has passed since the last reset.
  void _checkWeeklyBossReset() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Find the most recent Monday
    final daysSinceMonday = (today.weekday - 1) % 7;
    final lastMonday = today.subtract(Duration(days: daysSinceMonday));

    final lastReset = state.lastBossResetDate;
    final shouldReset = lastReset == null || lastReset.isBefore(lastMonday);

    if (shouldReset && state.boss.isDefeated) {
      state = state.copyWith(
        boss: SeedData.boss,
        lastBossResetDate: lastMonday,
      );
      _persist();
    } else if (lastReset == null) {
      state = state.copyWith(lastBossResetDate: lastMonday);
      _persist();
    }
  }

  /// Called when a task is completed. Returns the earned bonus XP (from multiplier).
  int onTaskCompleted(int basePoints) {
    final multi = state.effectiveMulti;
    final bonus = multi > 1 ? basePoints * (multi - 1) : 0;
    final newComboPoints = state.comboPoints + basePoints;
    final newComboCount = state.comboCount + 1;

    _comboTimer?.cancel();
    _comboTimer = Timer(const Duration(seconds: 60), () {
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
    final spGained = earnedXp ~/ 10; // 1 SP per 10 XP

    state = state.copyWith(
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
    );
    _persist();

    return bonus;
  }

  /// Called when a task is unchecked.
  void onTaskUncompleted(int basePoints, int bonusEarned) {
    final dmg = state.boss.damagePerTask;
    final newHp = (state.boss.hp + dmg).clamp(0, state.boss.maxHp);
    state = state.copyWith(
      bonusXp: (state.bonusXp - bonusEarned).clamp(0, 999999),
      boss: state.boss.copyWith(
        hp: newHp,
        tasksDone: (state.boss.tasksDone - 1).clamp(0, 999),
      ),
      totalLifetimeTasks: (state.totalLifetimeTasks - 1).clamp(0, 999999),
    );
    _persist();
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

  void reset() {
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
  (ref) => GamificationNotifier(),
);
