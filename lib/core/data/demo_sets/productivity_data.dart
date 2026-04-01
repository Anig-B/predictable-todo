import '../../theme/app_colors.dart';
import '../../../features/tasks/models/task_model.dart';
import '../../../features/tasks/models/note_model.dart';
import '../../../features/leaderboard/models/leaderboard_entry_model.dart';
import 'demo_set_model.dart';

final productivityData = DemoSet(
  id: 'productivity',
  name: 'Elite Productivity',
  icon: '🧠',
  desc: 'Master your day with deep work and rapid planning',
  color: AppColors.gold,
  tasks: [
    const TaskModel(
        id: '0',
        title: 'Deep Work Block (90min)',
        desc: 'Zero distractions, phone in other room.',
        time: '9:00 AM',
        points: 150,
        project: 'Execution',
        streak: 0,
        done: false,
        priority: TaskPriority.high,
        category: TaskCategory.work),
    const TaskModel(
        id: '0',
        title: 'Daily Highlight Setup',
        desc: 'Pick the ONE thing that must get done today.',
        time: '8:30 AM',
        points: 40,
        project: 'Planning',
        streak: 0,
        done: false,
        priority: TaskPriority.high,
        category: TaskCategory.work),
    const TaskModel(
        id: '0',
        title: 'Inbox Zero Sprint',
        desc: 'Clear and archive all pending emails.',
        time: '11:00 AM',
        points: 60,
        project: 'Execution',
        streak: 0,
        done: false,
        priority: TaskPriority.medium,
        category: TaskCategory.work),
    const TaskModel(
        id: '0',
        title: 'Weekly Review (60min)',
        desc: 'Review goals, blockers, and next week plan.',
        time: '4:00 PM',
        points: 100,
        project: 'Planning',
        streak: 0,
        done: false,
        priority: TaskPriority.high,
        category: TaskCategory.learning),
    const TaskModel(
        id: '0',
        title: 'Shutdown Ritual',
        desc: 'Clear tab list and write tomorrow top 3.',
        time: '6:00 PM',
        points: 30,
        project: 'Planning',
        streak: 0,
        done: false,
        priority: TaskPriority.low,
        category: TaskCategory.personal),
  ],
  notes: [
    NoteModel(
      id: 'prod-n1',
      content:
          '🌊 Flow State: It takes an average of 23 minutes to regain focus after a distraction. Guard your deep work blocks.',
      createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    ),
    NoteModel(
      id: 'prod-n2',
      content:
          '📅 Rule of 3: Accomplishing 3 meaningful tasks is better than finishing 20 trivial ones.',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ],
  leaderboard: [
    LeaderboardEntry(
      name: 'Oliver (Deep Worker)',
      avatar: 'https://i.pravatar.cc/150?u=oliver_prod',
      xp: 19800,
      level: 15,
      streak: 90,
      tasksWeek: 60,
    ),
    LeaderboardEntry(
      name: 'Grace (Inbox Zero)',
      avatar: 'https://i.pravatar.cc/150?u=grace_prod',
      xp: 17500,
      level: 11,
      streak: 30,
      tasksWeek: 42,
    ),
    LeaderboardEntry(
      name: 'Ben (The Strategist)',
      avatar: 'https://i.pravatar.cc/150?u=ben_prod',
      xp: 15100,
      level: 9,
      streak: 14,
      tasksWeek: 25,
    ),
  ],
  projectStats: [
    {
      'name': 'Deep Work',
      'total': 30,
      'completed': 22,
      'color': AppColors.purple
    },
    {'name': 'Planning', 'total': 25, 'completed': 20, 'color': AppColors.gold},
    {
      'name': 'Execution',
      'total': 50,
      'completed': 38,
      'color': AppColors.accent
    },
    {'name': 'Review', 'total': 10, 'completed': 8, 'color': AppColors.blue},
  ],
  hourlyData: [
    {'h': '8a', 'v': 400},
    {'h': '9a', 'v': 1200},
    {'h': '10a', 'v': 1500},
    {'h': '11a', 'v': 900},
    {'h': '2p', 'v': 700},
    {'h': '4p', 'v': 1100},
    {'h': '5p', 'v': 500},
  ],
);
