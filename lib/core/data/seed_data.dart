import 'package:flutter/material.dart';
import '../../features/tasks/models/task_model.dart';
import '../../features/gamification/models/boss_model.dart';
import '../../features/gamification/models/challenge_model.dart';
import '../../features/notifications/models/notification_model.dart';
import '../../features/gamification/models/skill_node_model.dart';
import '../../features/leaderboard/models/leaderboard_entry_model.dart';
import '../../features/tasks/models/activity_log_model.dart';
import '../../features/gamification/models/loot_item_model.dart';
import '../theme/app_colors.dart';

class DemoSet {
  final String id;
  final String name;
  final String icon;
  final String desc;
  final Color color;
  final List<TaskModel> tasks;

  const DemoSet({
    required this.id,
    required this.name,
    required this.icon,
    required this.desc,
    required this.color,
    required this.tasks,
  });
}

class SeedData {
  SeedData._();

  static const List<TaskModel> tasks = [
    TaskModel(id: 1, title: 'Morning Meditation', desc: '10 minutes of mindfulness breathing exercises.', time: '6:30 AM', points: 50, project: 'Wellness', streak: 12, done: false, priority: TaskPriority.high, category: TaskCategory.health),
    TaskModel(id: 2, title: 'Review Pull Requests', desc: 'Check and approve pending PRs on the main repo.', time: '9:00 AM', points: 80, project: 'DevOps', streak: 5, done: true, priority: TaskPriority.high, category: TaskCategory.work),
    TaskModel(id: 3, title: 'Read 20 Pages', desc: "Continue reading 'Atomic Habits' — Chapter 7.", time: '12:30 PM', points: 30, project: 'Growth', streak: 21, done: false, priority: TaskPriority.medium, category: TaskCategory.learning),
    TaskModel(id: 4, title: 'Gym Session', desc: 'Upper body: bench, OHP, rows, curls.', time: '5:00 PM', points: 100, project: 'Wellness', streak: 8, done: false, priority: TaskPriority.high, category: TaskCategory.health),
    TaskModel(id: 5, title: 'Update Design System', desc: 'Sync Figma tokens with codebase.', time: '3:00 PM', points: 60, project: 'UI Kit', streak: 3, done: false, priority: TaskPriority.medium, category: TaskCategory.work),
    TaskModel(id: 6, title: 'Journal Entry', desc: 'Wins, lessons, and gratitude list.', time: '9:30 PM', points: 40, project: 'Growth', streak: 30, done: false, priority: TaskPriority.low, category: TaskCategory.personal),
    TaskModel(id: 7, title: 'Team Standup Notes', desc: 'Prepare blockers and progress update.', time: '8:45 AM', points: 25, project: 'DevOps', streak: 15, done: true, priority: TaskPriority.low, category: TaskCategory.work),
    TaskModel(id: 8, title: 'Drink 2L Water', desc: 'Track water intake throughout the day.', time: 'All day', points: 20, project: 'Wellness', streak: 45, done: true, priority: TaskPriority.low, category: TaskCategory.health),
  ];

  static const BossModel boss = BossModel(
    name: 'Procrastination Dragon',
    emoji: '🐉',
    hp: 500,
    maxHp: 500,
    reward: 300,
    tasksDone: 0,
    tasksNeeded: 15,
  );

  static const List<ChallengeModel> challenges = [
    ChallengeModel(id: 1, title: 'Early Bird',    desc: 'Complete a task before 8 AM',    reward: 75,  icon: '🌅', done: false),
    ChallengeModel(id: 2, title: 'Triple Threat', desc: 'Complete 3 tasks in a row',       reward: 100, icon: '⚡', done: false),
    ChallengeModel(id: 3, title: 'Health Hero',   desc: 'Complete 2 Health tasks',         reward: 60,  icon: '💪', done: false),
  ];

  static const List<NotificationModel> notifications = [
    // Today — unread
    NotificationModel(id: 1,  text: '🔥 12-day streak — keep it going!',           time: '2m ago',   read: false),
    NotificationModel(id: 2,  text: '🏆 Priya just passed your weekly XP score!',   time: '15m ago',  read: false),
    NotificationModel(id: 3,  text: "⭐ New badge unlocked: 'Consistency King'",    time: '1h ago',   read: false),
    NotificationModel(id: 4,  text: '⚡ Combo ×4 active — complete a task now!',   time: '1h ago',   read: false),
    NotificationModel(id: 5,  text: '🎁 Loot box ready — you earned 5 tasks!',      time: '2h ago',   read: false),
    NotificationModel(id: 6,  text: '🐉 Boss DEFEATED! You dealt the final blow.',  time: '3h ago',   read: false),
    NotificationModel(id: 7,  text: '↻ Daily quest "Morning Run" has reset.',       time: '4h ago',   read: false),
    // Today — read
    NotificationModel(id: 8,  text: '📈 Productivity up 23% vs last week.',         time: '5h ago',   read: true),
    NotificationModel(id: 9,  text: '🎯 Challenge complete: Triple Threat ×3 done!',time: '6h ago',   read: true),
    NotificationModel(id: 10, text: '🌀 Spin wheel reward: +150 XP bonus added.',   time: '8h ago',   read: true),
    // Yesterday
    NotificationModel(id: 11, text: '🥇 You reached Rank S for the first time!',    time: 'Yesterday', read: true),
    NotificationModel(id: 12, text: "🐾 Pet evolved to 'Dragon'! Keep grinding.",   time: 'Yesterday', read: true),
    NotificationModel(id: 13, text: '💼 Work category streak: 7 days straight.',    time: 'Yesterday', read: true),
    NotificationModel(id: 14, text: '🛡️ Streak shield used — streak protected!',   time: 'Yesterday', read: true),
    // Older
    NotificationModel(id: 15, text: '📚 Wisdom II skill unlocked in skill tree.',   time: '2 days ago', read: true),
    NotificationModel(id: 16, text: '🏅 Weekly leaderboard: you moved to #2!',      time: '3 days ago', read: true),
    NotificationModel(id: 17, text: '↻ Weekly quest "Read 30 min" has reset.',      time: '3 days ago', read: true),
    NotificationModel(id: 18, text: '🎉 Level 12 reached — new title unlocked!',    time: '4 days ago', read: true),
  ];

  static const List<SkillNodeModel> skillTree = [
    SkillNodeModel(id: 'focus1',    name: 'Focus I',    desc: '+5% Work XP',    icon: '🎯', cost: 100, unlocked: true),
    SkillNodeModel(id: 'focus2',    name: 'Focus II',   desc: '+10% Work XP',   icon: '🎯', cost: 250, unlocked: true),
    SkillNodeModel(id: 'focus3',    name: 'Focus III',  desc: '+20% Work XP',   icon: '🎯', cost: 500, unlocked: false),
    SkillNodeModel(id: 'vitality1', name: 'Vitality I', desc: '+5% Health XP',  icon: '❤️', cost: 100, unlocked: true),
    SkillNodeModel(id: 'vitality2', name: 'Vitality II',desc: '+10% Health XP', icon: '❤️', cost: 250, unlocked: false),
    SkillNodeModel(id: 'wisdom1',   name: 'Wisdom I',   desc: '+5% Learn XP',   icon: '📖', cost: 100, unlocked: true),
    SkillNodeModel(id: 'wisdom2',   name: 'Wisdom II',  desc: '+10% Learn XP',  icon: '📖', cost: 250, unlocked: false),
    SkillNodeModel(id: 'combo',     name: 'Combo+',     desc: 'Slower combo decay', icon: '🔥', cost: 400, unlocked: false),
  ];

  static const List<LeaderboardEntry> leaderboard = [
    LeaderboardEntry(name: 'You',       xp: 2480, avatar: '🧑‍💻', level: 14, streak: 30, tasksWeek: 42, isYou: true),
    LeaderboardEntry(name: 'Priya S.',  xp: 2350, avatar: '👩‍🎨', level: 13, streak: 18, tasksWeek: 38),
    LeaderboardEntry(name: 'Marcus W.', xp: 2100, avatar: '🧔',   level: 12, streak: 25, tasksWeek: 35),
    LeaderboardEntry(name: 'Luna K.',   xp: 1890, avatar: '👩‍🔬', level: 11, streak: 10, tasksWeek: 31),
    LeaderboardEntry(name: 'Jake T.',   xp: 1650, avatar: '🧑‍🚀', level: 10, streak: 7,  tasksWeek: 28),
    LeaderboardEntry(name: 'Ava M.',    xp: 1520, avatar: '👩‍🏫', level: 9,  streak: 14, tasksWeek: 24),
  ];

  static const List<ActivityLogModel> activityLog = [
    ActivityLogModel(task: 'Review Pull Requests', points: 80,  time: 'Today, 9:14 AM',      icon: '💼'),
    ActivityLogModel(task: 'Team Standup Notes',   points: 25,  time: 'Today, 8:52 AM',      icon: '💼'),
    ActivityLogModel(task: 'Drink 2L Water',       points: 20,  time: 'Today, 6:00 PM',      icon: '💪'),
    ActivityLogModel(task: 'Morning Meditation',   points: 50,  time: 'Yesterday, 6:35 AM',  icon: '💪'),
    ActivityLogModel(task: 'Gym Session',          points: 100, time: 'Yesterday, 5:22 PM',  icon: '💪'),
    ActivityLogModel(task: 'Read 20 Pages',        points: 30,  time: 'Yesterday, 12:45 PM', icon: '📚'),
    ActivityLogModel(task: 'Journal Entry',        points: 40,  time: 'Yesterday, 9:40 PM',  icon: '🏠'),
  ];

  static final List<LootItemModel> lootPool = [
    LootItemModel(icon: '⚡', name: '+150 Bonus XP',  desc: 'A surge of energy!',      rarity: LootRarity.rare,      color: AppColors.accent),
    LootItemModel(icon: '🛡️', name: 'Streak Shield',  desc: 'Protect your streak',     rarity: LootRarity.epic,      color: AppColors.purple),
    LootItemModel(icon: '✨', name: '3× Multiplier',  desc: 'Triple XP next task',     rarity: LootRarity.legendary, color: AppColors.gold),
    LootItemModel(icon: '🎨', name: 'Neon Theme',     desc: 'Unlock neon glow',        rarity: LootRarity.rare,      color: AppColors.red),
    LootItemModel(icon: '🐲', name: 'Dragon Egg',     desc: 'Pet evolution boost',     rarity: LootRarity.legendary, color: AppColors.orange),
  ];

  // ── Stats chart data ─────────────────────────────────

  static const List<Map<String, dynamic>> weeklyXp = [
    {'day': 'Mon', 'xp': 320}, {'day': 'Tue', 'xp': 480},
    {'day': 'Wed', 'xp': 250}, {'day': 'Thu', 'xp': 560},
    {'day': 'Fri', 'xp': 410}, {'day': 'Sat', 'xp': 180},
    {'day': 'Sun', 'xp': 340},
  ];

  static final List<Map<String, dynamic>> categoryData = [
    {'name': 'Work',     'value': 35, 'color': AppColors.purple},
    {'name': 'Health',   'value': 28, 'color': AppColors.accent},
    {'name': 'Learning', 'value': 20, 'color': AppColors.gold},
    {'name': 'Personal', 'value': 17, 'color': AppColors.red},
  ];

  static final List<Map<String, dynamic>> projectStats = [
    {'name': 'Wellness', 'completed': 24, 'total': 30, 'color': AppColors.accent},
    {'name': 'DevOps',   'completed': 18, 'total': 25, 'color': AppColors.purple},
    {'name': 'Growth',   'completed': 31, 'total': 35, 'color': AppColors.gold},
    {'name': 'UI Kit',   'completed': 8,  'total': 15, 'color': AppColors.orange},
    {'name': 'Personal', 'completed': 12, 'total': 20, 'color': AppColors.red},
  ];

  static const List<Map<String, dynamic>> hourlyData = [
    {'h': '6a', 'v': 3}, {'h': '7a', 'v': 2}, {'h': '8a', 'v': 5},
    {'h': '9a', 'v': 8}, {'h': '10a','v': 7}, {'h': '11a','v': 6},
    {'h': '12p','v': 4}, {'h': '1p', 'v': 3}, {'h': '2p', 'v': 5},
    {'h': '3p', 'v': 7}, {'h': '4p', 'v': 6}, {'h': '5p', 'v': 8},
    {'h': '6p', 'v': 4}, {'h': '7p', 'v': 3}, {'h': '8p', 'v': 2},
    {'h': '9p', 'v': 4}, {'h': '10p','v': 1},
  ];

  // ── Spin wheel segments ──────────────────────────────

  static final List<Map<String, dynamic>> wheelSegments = [
    {'label': '+50 XP',  'value': 50,  'type': 'xp',     'color': AppColors.accent},
    {'label': '2× Next', 'value': 2,   'type': 'multi',   'color': AppColors.purple},
    {'label': '+20 XP',  'value': 20,  'type': 'xp',     'color': AppColors.blue},
    {'label': '🛡️ Shield','value': 1,  'type': 'shield',  'color': AppColors.gold},
    {'label': '+100 XP', 'value': 100, 'type': 'xp',     'color': AppColors.red},
    {'label': '+30 XP',  'value': 30,  'type': 'xp',     'color': AppColors.orange},
    {'label': '3× Next', 'value': 3,   'type': 'multi',   'color': AppColors.accent},
    {'label': '+75 XP',  'value': 75,  'type': 'xp',     'color': AppColors.purple},
  ];

  // ── Badges ───────────────────────────────────────────

  static const List<Map<String, dynamic>> badges = [
    {'icon': '🔥', 'name': 'Streak Lord',    'unlocked': true},
    {'icon': '⚡', 'name': 'Speed Demon',    'unlocked': true},
    {'icon': '🎯', 'name': 'Perfectionist',  'unlocked': true},
    {'icon': '🏆', 'name': 'Champion',       'unlocked': true},
    {'icon': '🌟', 'name': 'Rising Star',    'unlocked': true},
    {'icon': '💎', 'name': 'Diamond',        'unlocked': true},
    {'icon': '🦁', 'name': 'Brave Heart',    'unlocked': false},
    {'icon': '🌙', 'name': 'Night Owl',      'unlocked': false},
    {'icon': '🌅', 'name': 'Early Bird',     'unlocked': true},
    {'icon': '🤝', 'name': 'Team Player',    'unlocked': false},
  ];

  // ── Demo Sets ─────────────────────────────────────────

  static const List<DemoSet> demoSets = [
    DemoSet(
      id: 'rebuzz',
      name: 'Rebuzz POS Demo',
      icon: '🏪',
      desc: '10 marketing tasks to build a predictable sales pipeline',
      color: AppColors.purple,
      tasks: [
        TaskModel(id: 0, title: 'Map Primary & Secondary ICPs',      desc: 'Identify exact criteria for best Rebuzz POS customers.',                       time: '9:00 AM',  points: 80, project: 'Strategy', streak: 0, done: false, priority: TaskPriority.high,   category: TaskCategory.work),
        TaskModel(id: 0, title: 'Segment Database by Niche',          desc: 'Break TAM into sub-niches: cafes automating loyalty vs. retailers.',           time: '10:00 AM', points: 60, project: 'Strategy', streak: 0, done: false, priority: TaskPriority.high,   category: TaskCategory.work),
        TaskModel(id: 0, title: 'Build Targeted Outbound Lists',      desc: 'Scrape or build 100–200 high-quality ICP-matched contacts per week.',          time: '11:00 AM', points: 80, project: 'Outbound', streak: 0, done: false, priority: TaskPriority.high,   category: TaskCategory.work),
        TaskModel(id: 0, title: 'Draft Referral Email Sequences',     desc: 'Write 3-step plain-text sequences aimed at getting POS referrals.',            time: '2:00 PM',  points: 60, project: 'Outbound', streak: 0, done: false, priority: TaskPriority.medium, category: TaskCategory.work),
        TaskModel(id: 0, title: 'Create Sales Enablement 1-Pagers',  desc: 'Develop collateral highlighting cost-saving benefits for SDRs.',               time: '3:00 PM',  points: 50, project: 'Outbound', streak: 0, done: false, priority: TaskPriority.medium, category: TaskCategory.work),
        TaskModel(id: 0, title: 'Develop Gated Lead Magnets',        desc: 'Create the 2026 Guide eBook and a POS ROI Calculator.',                        time: '9:00 AM',  points: 80, project: 'Inbound',  streak: 0, done: false, priority: TaskPriority.high,   category: TaskCategory.work),
        TaskModel(id: 0, title: 'Setup Inbound Qualification Funnel', desc: 'Build automated email workflows to nurture content downloaders.',              time: '11:00 AM', points: 80, project: 'Inbound',  streak: 0, done: false, priority: TaskPriority.high,   category: TaskCategory.work),
        TaskModel(id: 0, title: 'Launch Educational Webinar',        desc: 'Host a 20-min monthly webinar on integrated POS ops.',                         time: '1:00 PM',  points: 50, project: 'Inbound',  streak: 0, done: false, priority: TaskPriority.medium, category: TaskCategory.work),
        TaskModel(id: 0, title: 'Build Case Study Library',          desc: 'Interview top 5 Rebuzz POS clients. Publish with hard metrics.',               time: '10:00 AM', points: 60, project: 'Customer', streak: 0, done: false, priority: TaskPriority.medium, category: TaskCategory.work),
        TaskModel(id: 0, title: 'Launch Client Referral Program',    desc: 'Create formalized affiliate/referral campaign incentivizing POS users.',       time: '2:00 PM',  points: 50, project: 'Customer', streak: 0, done: false, priority: TaskPriority.low,    category: TaskCategory.work),
      ],
    ),
  ];
}
