import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/boss_model.dart';
import '../models/skill_node_model.dart';
import '../core/data/seed_data.dart';
import '../core/utils/xp_calculator.dart';

class GamificationState {
  final int bonusXp;
  final int combo;
  final int multiplier;
  final BossModel boss;
  final int totalLifetimeTasks;
  final int shields;
  final int lootCount;
  final int skillPoints;
  final List<SkillNodeModel> skillTree;
  final bool spinUsed;

  const GamificationState({
    this.bonusXp = 0,
    this.combo = 0,
    this.multiplier = 1,
    required this.boss,
    this.totalLifetimeTasks = 47,
    this.shields = 1,
    this.lootCount = 0,
    this.skillPoints = 320,
    required this.skillTree,
    this.spinUsed = false,
  });

  int get comboMulti => XpCalculator.comboMultiplier(combo);
  int get effectiveMulti => max(multiplier, comboMulti);

  GamificationState copyWith({
    int? bonusXp,
    int? combo,
    int? multiplier,
    BossModel? boss,
    int? totalLifetimeTasks,
    int? shields,
    int? lootCount,
    int? skillPoints,
    List<SkillNodeModel>? skillTree,
    bool? spinUsed,
  }) =>
      GamificationState(
        bonusXp: bonusXp ?? this.bonusXp,
        combo: combo ?? this.combo,
        multiplier: multiplier ?? this.multiplier,
        boss: boss ?? this.boss,
        totalLifetimeTasks: totalLifetimeTasks ?? this.totalLifetimeTasks,
        shields: shields ?? this.shields,
        lootCount: lootCount ?? this.lootCount,
        skillPoints: skillPoints ?? this.skillPoints,
        skillTree: skillTree ?? this.skillTree,
        spinUsed: spinUsed ?? this.spinUsed,
      );
}

class GamificationNotifier extends StateNotifier<GamificationState> {
  GamificationNotifier()
      : super(GamificationState(boss: SeedData.boss, skillTree: SeedData.skillTree));

  Timer? _comboTimer;

  /// Called when a task is completed. Returns the earned bonus XP (from multiplier).
  int onTaskCompleted(int basePoints) {
    final multi = state.effectiveMulti;
    final bonus = multi > 1 ? basePoints * (multi - 1) : 0;
    final newCombo = state.combo + 1;

    _comboTimer?.cancel();
    _comboTimer = Timer(const Duration(seconds: 60), () {
      if (mounted) state = state.copyWith(combo: 0);
    });

    // Boss damage
    final dmg = state.boss.damagePerTask;
    final newHp = (state.boss.hp - dmg).clamp(0, state.boss.maxHp);
    final newBoss = state.boss.copyWith(
      hp: newHp,
      tasksDone: state.boss.tasksDone + 1,
    );

    // Loot box every 5 tasks
    final newLootCount = state.lootCount + 1;

    state = state.copyWith(
      combo: newCombo,
      multiplier: multi > 1 ? 1 : state.multiplier, // consume spin multiplier
      bonusXp: state.bonusXp + bonus,
      boss: newBoss,
      totalLifetimeTasks: state.totalLifetimeTasks + 1,
      lootCount: newLootCount,
    );

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
  }

  void addBossReward() {
    state = state.copyWith(bonusXp: state.bonusXp + state.boss.reward);
  }

  void applySpinResult(Map<String, dynamic> seg) {
    final type = seg['type'] as String;
    final value = seg['value'] as int;
    if (type == 'xp') state = state.copyWith(bonusXp: state.bonusXp + value);
    if (type == 'multi') state = state.copyWith(multiplier: value);
    if (type == 'shield') state = state.copyWith(shields: state.shields + 1);
    state = state.copyWith(spinUsed: true);
  }

  void applyLootItem(String itemName) {
    if (itemName.contains('XP')) state = state.copyWith(bonusXp: state.bonusXp + 150);
    if (itemName.contains('Shield')) state = state.copyWith(shields: state.shields + 1);
    if (itemName.contains('Multiplier')) state = state.copyWith(multiplier: 3);
  }

  bool unlockSkill(String id) {
    final node = state.skillTree.firstWhere((s) => s.id == id, orElse: () => state.skillTree.first);
    if (node.unlocked || state.skillPoints < node.cost) return false;
    state = state.copyWith(
      skillPoints: state.skillPoints - node.cost,
      skillTree: state.skillTree.map((s) => s.id == id ? s.copyWith(unlocked: true) : s).toList(),
    );
    return true;
  }

  void reset() {
    _comboTimer?.cancel();
    state = GamificationState(boss: SeedData.boss, skillTree: SeedData.skillTree);
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
