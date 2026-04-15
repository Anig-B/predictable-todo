import '../../features/tasks/models/task_model.dart';
import '../../features/gamification/models/boss_model.dart';
import '../../features/gamification/models/challenge_model.dart';
import '../../features/gamification/models/skill_node_model.dart';
import '../../features/leaderboard/models/leaderboard_entry_model.dart';
import '../../features/tasks/models/activity_log_model.dart';
import '../../features/gamification/models/loot_item_model.dart';
import '../theme/app_colors.dart';
import 'demo_sets/demo_set_model.dart';
import 'demo_sets/rebuzz_data.dart';
import 'demo_sets/gym_data.dart';
import 'demo_sets/productivity_data.dart';
import 'demo_sets/diet_data.dart';

export 'demo_sets/demo_set_model.dart';

class SeedData {
  SeedData._();

  // ── Global App Data ───────────────────────────────────

  static const List<TaskModel> tasks = [];

  static const BossModel boss = BossModel(
    id: 'chaos_lord',
    name: 'Chaos Lord',
    emoji: '👹', // Replaced image with emoji
    hp: 1000,
    maxHp: 1000,
    reward: 500,
    tasksDone: 0,
    tasksNeeded: 20,
  );

  static const List<ChallengeModel> questPool = [
    ChallengeModel(
      id: 1, 
      type: ChallengeType.earlyBird, 
      title: 'Morning Hustle',
      desc: 'Complete 3 tasks before 10 AM',
      reward: 350,
      icon: '🌅',
      done: false,
      target: 3,
    ),
    ChallengeModel(
      id: 2,
      type: ChallengeType.tripleThreat,
      title: 'Momentum',
      desc: 'Complete 3 tasks in a row today',
      reward: 500,
      icon: '🔥',
      done: false,
      target: 3,
    ),
    ChallengeModel(
      id: 3,
      type: ChallengeType.healthHero,
      title: 'Body & Mind',
      desc: 'Complete 2 health category tasks',
      reward: 400,
      icon: '💪',
      done: false,
      target: 2,
    ),
    ChallengeModel(
      id: 4,
      type: ChallengeType.bossDamage,
      title: 'Boss Battler',
      desc: 'Damage the current boss 5 times',
      reward: 600,
      icon: '⚔️',
      done: false,
      target: 5,
    ),
    ChallengeModel(
      id: 5,
      type: ChallengeType.socialScout,
      title: 'Social Scout',
      desc: 'View 3 other player profiles',
      reward: 200,
      icon: '🕵️',
      done: false,
      target: 3,
    ),
    ChallengeModel(
      id: 6,
      type: ChallengeType.proofProvider,
      title: 'Show Your Work',
      desc: 'Provide proof notes or an image for 2 tasks',
      reward: 800,
      icon: '📸',
      done: false,
      target: 2,
    ),
    ChallengeModel(
      id: 7,
      type: ChallengeType.consistency,
      title: 'Steady Hand',
      desc: 'Complete 5 total tasks today',
      reward: 750,
      icon: '🎯',
      done: false,
      target: 5,
    ),
    ChallengeModel(
      id: 8,
      type: ChallengeType.projectFocus,
      title: 'Project Pusher',
      desc: 'Complete 3 tasks in a single project',
      reward: 450,
      icon: '📁',
      done: false,
      target: 3,
    ),
  ];
  static const List<String> avatarEmojis = [
    '👤', '🧑‍🚀', '🦊', '🦁', '🦉', '🦋', '🍀', '🍎', '🧩', '🎨', 
    '🎮', '🎸', '⚽', '🌌', '🍦', '🍩', '🤖', '👾', '👻', '🎃'
  ];

  static const List<SkillNodeModel> skillTree = [
    SkillNodeModel(
      id: 's1',
      name: 'Focus',
      desc: 'Increase deep work efficiency',
      icon: '🎯',
      cost: 100,
      unlocked: true,
    ),
    SkillNodeModel(
      id: 's2',
      name: 'Strategy',
      desc: 'Higher points for planned tasks',
      icon: '♟️',
      cost: 200,
      unlocked: true,
    ),
    SkillNodeModel(
      id: 's3',
      name: 'Endurance',
      desc: 'Reduces streak loss penalty',
      icon: '🔋',
      cost: 300,
      unlocked: false,
    ),
    SkillNodeModel(
      id: 's4',
      name: 'Efficiency',
      desc: 'Tasks take 10% less time',
      icon: '⚡',
      cost: 400,
      unlocked: false,
    ),
    SkillNodeModel(
      id: 's5',
      name: 'Mindfulness',
      desc: 'Bonus XP for consistent ratings',
      icon: '🧘',
      cost: 500,
      unlocked: false,
    ),
    SkillNodeModel(
      id: 's6',
      name: 'Prioritization',
      desc: 'Double XP for high priority',
      icon: '🔝',
      cost: 600,
      unlocked: false,
    ),
  ];

  static const List<LeaderboardEntry> leaderboard = [
    LeaderboardEntry(
      id: 'dummy_id',
      shortId: '000000',
      weeklyXp: 0,
      name: 'You',
      avatar: '🧑‍💻',
      xp: 12450,
      level: 5,
      streak: 7,
      tasksWeek: 12,
      isYou: true,
    ),
    LeaderboardEntry(
      id: 'dummy_id',
      shortId: '000000',
      weeklyXp: 0,
      name: 'Sarah Chen',
      avatar: '👩‍💻',
      xp: 15200,
      level: 10,
      streak: 15,
      tasksWeek: 45,
    ),
    LeaderboardEntry(
      id: 'dummy_id',
      shortId: '000000',
      weeklyXp: 0,
      name: 'Mike Ross',
      avatar: '👨‍💼',
      xp: 14800,
      level: 8,
      streak: 10,
      tasksWeek: 30,
    ),
    LeaderboardEntry(
      id: 'dummy_id',
      shortId: '000000',
      weeklyXp: 0,
      name: 'Alex Rivera',
      avatar: '🧑‍🎨',
      xp: 13500,
      level: 7,
      streak: 5,
      tasksWeek: 28,
    ),
    LeaderboardEntry(
      id: 'dummy_id',
      shortId: '000000',
      weeklyXp: 0,
      name: 'Elena Gilbert',
      avatar: '👩‍⚕️',
      xp: 11200,
      level: 6,
      streak: 12,
      tasksWeek: 20,
    ),
    LeaderboardEntry(
      id: 'dummy_id',
      shortId: '000000',
      weeklyXp: 0,
      name: 'Damon Salvatore',
      avatar: '🧛',
      xp: 9800,
      level: 4,
      streak: 3,
      tasksWeek: 15,
    ),
    LeaderboardEntry(
      id: 'dummy_id',
      shortId: '000000',
      weeklyXp: 0,
      name: 'Bonnie Bennett',
      avatar: '🧙‍♀️',
      xp: 8500,
      level: 3,
      streak: 8,
      tasksWeek: 11,
    ),
  ];

  static const List<ActivityLogModel> activityLogs = [];

  static const List<LootItemModel> lootPool = [
    LootItemModel(
      name: 'Focus Potion',
      desc: '2x points for next 30 mins',
      rarity: LootRarity.rare,
      color: AppColors.purple,
      icon: '🧪',
    ),
    LootItemModel(
      name: 'Golden Ticket',
      desc: 'Skip any task without penalty',
      rarity: LootRarity.epic,
      color: AppColors.gold,
      icon: '🎫',
    ),
    LootItemModel(
      name: 'Chaos Shield',
      desc: 'Protection from boss attacks',
      rarity: LootRarity.legendary,
      color: AppColors.accent,
      icon: '🛡️',
    ),
  ];

  static const List<Map<String, dynamic>> wheelSegments = [
    {'label': '100 XP', 'value': 100, 'color': AppColors.blue, 'type': 'xp'},
    {
      'label': 'Shield',
      'value': 1,
      'color': AppColors.purple,
      'type': 'shield'
    },
    {'label': '2× XP', 'value': 2, 'color': AppColors.gold, 'type': 'multi'},
    {'label': '50 XP', 'value': 50, 'color': AppColors.accent, 'type': 'xp'},
    {'label': '3× XP', 'value': 3, 'color': AppColors.red, 'type': 'multi'},
    {'label': '200 XP', 'value': 200, 'color': AppColors.gold, 'type': 'xp'},
  ];

  static String getBadgeIcon(String badgeName) {
    final b = badges.firstWhere((e) => e['name'] == badgeName, orElse: () => {'icon': '🏆'});
    return b['icon'] as String;
  }

  static const List<Map<String, dynamic>> badges = [
    {
      'icon': '🚀',
      'name': 'Early Adopter',
      'unlocked': true,
      'color': AppColors.purple
    },
    {
      'icon': '🔥',
      'name': '7-Day Streak',
      'unlocked': true,
      'color': AppColors.red
    },
    {
      'icon': '⚔️',
      'name': 'Boss Slayer',
      'unlocked': false,
      'color': AppColors.accent
    },
    {
      'icon': '💎',
      'name': 'Gem Collector',
      'unlocked': false,
      'color': AppColors.gold
    },
    {
      'icon': '🎯',
      'name': 'Perfect Week',
      'unlocked': true,
      'color': AppColors.blue
    },
    {
      'icon': '🦉',
      'name': 'Night Owl',
      'unlocked': false,
      'color': AppColors.purple
    },
    {
      'icon': '🧞',
      'name': 'Mystery Genie',
      'unlocked': false,
      'color': AppColors.gold
    },
    {
      'icon': '🧘',
      'name': 'Focus Master',
      'unlocked': false,
      'color': AppColors.accent
    },
    {
      'icon': '🧗',
      'name': 'Peak Performer',
      'unlocked': false,
      'color': AppColors.blue
    },
    {
      'icon': '💪',
      'name': 'Weekend Warrior',
      'unlocked': false,
      'color': AppColors.red
    },
  ];


  static const List<Map<String, dynamic>> categoryData = [
    {'name': 'Work', 'value': 45, 'color': AppColors.purple},
    {'name': 'Health', 'value': 25, 'color': AppColors.accent},
    {'name': 'Learning', 'value': 20, 'color': AppColors.gold},
    {'name': 'Personal', 'value': 10, 'color': AppColors.red},
  ];

  static const List<Map<String, dynamic>> projectStats = [
    {'name': 'Rebuzz', 'value': 120},
    {'name': 'Muscle', 'value': 85},
    {'name': 'Strategy', 'value': 60},
    {'name': 'Growth', 'value': 40},
  ];

  static const List<Map<String, dynamic>> hourlyData = [
    {'h': '8a', 'v': 2},
    {'h': '10a', 'v': 5},
    {'h': '12p', 'v': 3},
    {'h': '2p', 'v': 4},
    {'h': '4p', 'v': 6},
    {'h': '6p', 'v': 2},
  ];

  // ── Demo Sets ─────────────────────────────────────────

  static final List<DemoSet> demoSets = [
    rebuzzData,
    gymData,
    productivityData,
    dietData,
  ];
}
