import '../models/boss_model.dart';

class BossData {
  static const Map<String, BossModel> bosses = {
    'chaos_lord': BossModel(
      id: 'chaos_lord',
      name: 'Chaos Lord',
      emoji: '👹', // Replaced image with emoji
      hp: 1000,
      maxHp: 1000,
      reward: 500,
      tasksDone: 0,
      tasksNeeded: 20,
      color: 'fire',
    ),
    'procrastination_zombie': BossModel(
      id: 'procrastination_zombie',
      name: 'Procrastination Zombie',
      emoji: '🧟‍♂️',
      hp: 800,
      maxHp: 800,
      reward: 400,
      tasksDone: 0,
      tasksNeeded: 15,
      color: 'undead',
    ),
    'lazy_master': BossModel(
      id: 'lazy_master',
      name: 'Lazy Master',
      emoji: '🦥',
      hp: 600,
      maxHp: 600,
      reward: 300,
      tasksDone: 0,
      tasksNeeded: 10,
      color: 'earth',
    ),
    'mystery_genie': BossModel(
      id: 'mystery_genie',
      name: 'Mystery Genie',
      emoji: '🧞',
      hp: 2000,
      maxHp: 2000,
      reward: 1500,
      tasksDone: 0,
      tasksNeeded: 30,
      color: 'rare',
    ),
  };

  static BossModel getById(String id) => bosses[id] ?? bosses['chaos_lord']!;
}
