import '../../theme/app_colors.dart';
import '../../../features/tasks/models/task_model.dart';
import '../../../features/tasks/models/note_model.dart';
import '../../../features/leaderboard/models/leaderboard_entry_model.dart';
import 'demo_set_model.dart';

final gymData = DemoSet(
  id: 'gym',
  name: 'Gym Freak (Push/Pull)',
  icon: '🏋️',
  desc: 'Balanced strength routine for maximum hypertrophy',
  color: AppColors.accent,
  tasks: [
    const TaskModel(
        id: '0',
        title: 'Heavy Bench Press (5×5)',
        desc: 'Focus on form and progressive overload.',
        time: '5:00 PM',
        points: 100,
        project: 'Muscle',
        streak: 0,
        done: false,
        priority: TaskPriority.high,
        category: TaskCategory.health),
    const TaskModel(
        id: '0',
        title: 'Weighted Pull-ups (3×8)',
        desc: 'Add 10lb and focus on full extension.',
        time: '5:30 PM',
        points: 80,
        project: 'Muscle',
        streak: 0,
        done: false,
        priority: TaskPriority.high,
        category: TaskCategory.health),
    const TaskModel(
        id: '0',
        title: 'Overhead Press (3×10)',
        desc: 'Strict military press standing.',
        time: '6:00 PM',
        points: 70,
        project: 'Muscle',
        streak: 0,
        done: false,
        priority: TaskPriority.medium,
        category: TaskCategory.health),
    const TaskModel(
        id: '0',
        title: 'Lateral Raises (3×15)',
        desc: 'Burn out the side delts.',
        time: '6:30 PM',
        points: 50,
        project: 'Muscle',
        streak: 0,
        done: false,
        priority: TaskPriority.low,
        category: TaskCategory.health),
    const TaskModel(
        id: '0',
        title: '15-Min Incline Walk',
        desc: 'Active recovery and heart health.',
        time: '7:00 PM',
        points: 40,
        project: 'Fat Loss',
        streak: 0,
        done: false,
        priority: TaskPriority.low,
        category: TaskCategory.health),
    const TaskModel(
        id: '0',
        title: 'Post-Workout Protein',
        desc: '50g protein intake within 90 mins.',
        time: '7:30 PM',
        points: 30,
        project: 'Nutrition',
        streak: 0,
        done: false,
        priority: TaskPriority.medium,
        category: TaskCategory.health),
  ],
  notes: [
    NoteModel(
      id: 'gym-n1',
      content:
          '💡 Form Tip: Retract scapula during bench press to protect shoulders and engage chest effectively.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    NoteModel(
      id: 'gym-n3',
      content:
          '💧 Hydration: Losing even 2% of body weight in water can significantly decrease strength performance.',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    NoteModel(
      id: 'gym-n4',
      content:
          '💤 Recovery: Growth happens during sleep, not in the gym. Aim for 8 hours for hormonal balance.',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ],
  leaderboard: [
    LeaderboardEntry(
      name: 'Jax (Mass Monster)',
      avatar: 'https://i.pravatar.cc/150?u=jax_gym',
      xp: 18500,
      level: 12,
      streak: 45,
      tasksWeek: 50,
    ),
    LeaderboardEntry(
      name: 'Luna (Yoga Queen)',
      avatar: 'https://i.pravatar.cc/150?u=luna_gym',
      xp: 16200,
      level: 9,
      streak: 22,
      tasksWeek: 35,
    ),
    LeaderboardEntry(
      name: 'Flex (The Ripper)',
      avatar: 'https://i.pravatar.cc/150?u=flex_gym',
      xp: 14100,
      level: 8,
      streak: 10,
      tasksWeek: 28,
    ),
  ],
  projectStats: [
    {
      'name': 'Strength',
      'total': 40,
      'completed': 25,
      'color': AppColors.accent
    },
    {
      'name': 'Hypertrophy',
      'total': 30,
      'completed': 18,
      'color': AppColors.purple
    },
    {
      'name': 'Endurance',
      'total': 20,
      'completed': 12,
      'color': AppColors.blue
    },
    {'name': 'Mobility', 'total': 15, 'completed': 5, 'color': AppColors.gold},
  ],
  hourlyData: [
    {'h': '6a', 'v': 900},
    {'h': '7a', 'v': 750},
    {'h': '8a', 'v': 300},
    {'h': '4p', 'v': 400},
    {'h': '5p', 'v': 1100},
    {'h': '6p', 'v': 1400},
    {'h': '7p', 'v': 800},
  ],
);
