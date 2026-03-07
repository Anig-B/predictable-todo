import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class RankTier {
  final String name;
  final int minXp;
  final String icon;
  final Color color;

  const RankTier({
    required this.name,
    required this.minXp,
    required this.icon,
    required this.color,
  });
}

class PetStage {
  final String name;
  final String emoji;
  final int minTasks;
  final double size;

  const PetStage({
    required this.name,
    required this.emoji,
    required this.minTasks,
    required this.size,
  });
}

class XpCalculator {
  XpCalculator._();

  static const int xpPerLevel = 200;

  static const List<RankTier> rankTiers = [
    RankTier(name: 'Bronze', minXp: 0, icon: '🥉', color: Color(0xFFCD7F32)),
    RankTier(name: 'Silver', minXp: 500, icon: '🥈', color: Color(0xFFC0C0C0)),
    RankTier(name: 'Gold', minXp: 1500, icon: '🥇', color: Color(0xFFFFD700)),
    RankTier(
        name: 'Diamond', minXp: 3000, icon: '💎', color: Color(0xFF00D4FF)),
    RankTier(name: 'Legend', minXp: 5000, icon: '👑', color: AppColors.red),
  ];

  static const List<PetStage> petStages = [
    PetStage(name: 'Egg', emoji: '🥚', minTasks: 0, size: 28),
    PetStage(name: 'Baby Slime', emoji: '🫧', minTasks: 3, size: 32),
    PetStage(name: 'Fox Cub', emoji: '🦊', minTasks: 10, size: 36),
    PetStage(name: 'Phoenix', emoji: '🦅', minTasks: 25, size: 40),
    PetStage(name: 'Dragon', emoji: '🐲', minTasks: 50, size: 44),
  ];

  static int level(int totalXp) => (totalXp / xpPerLevel).floor() + 1;

  static int xpInLevel(int totalXp) => totalXp % xpPerLevel;

  static double levelProgress(int totalXp) =>
      (xpInLevel(totalXp) / xpPerLevel).clamp(0.0, 1.0);

  static RankTier currentRank(int totalXp) {
    return rankTiers.lastWhere((r) => totalXp >= r.minXp,
        orElse: () => rankTiers.first);
  }

  static RankTier? nextRank(int totalXp) {
    final idx = rankTiers.indexOf(currentRank(totalXp));
    if (idx < rankTiers.length - 1) return rankTiers[idx + 1];
    return null;
  }

  static double rankProgress(int totalXp) {
    final cur = currentRank(totalXp);
    final nxt = nextRank(totalXp);
    if (nxt == null) return 1.0;
    return ((totalXp - cur.minXp) / (nxt.minXp - cur.minXp)).clamp(0.0, 1.0);
  }

  static PetStage currentPet(int totalLifetimeTasks) {
    return petStages.lastWhere((p) => totalLifetimeTasks >= p.minTasks,
        orElse: () => petStages.first);
  }

  static PetStage? nextPet(int totalLifetimeTasks) {
    return petStages.firstWhere(
      (p) => p.minTasks > totalLifetimeTasks,
      orElse: () => petStages.last,
    );
  }

  static double petProgress(int totalLifetimeTasks) {
    final cur = currentPet(totalLifetimeTasks);
    final nxt = nextPet(totalLifetimeTasks);
    if (nxt == null || nxt == cur) return 1.0;
    return ((totalLifetimeTasks - cur.minTasks) / (nxt.minTasks - cur.minTasks))
        .clamp(0.0, 1.0);
  }

  static int comboMultiplier(int comboPoints) {
    if (comboPoints >= 500) return 4;
    if (comboPoints >= 250) return 3;
    if (comboPoints >= 100) return 2;
    return 1;
  }
}
