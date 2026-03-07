import '../../theme/app_colors.dart';
import '../../../features/tasks/models/task_model.dart';
import '../../../features/tasks/models/note_model.dart';
import 'demo_set_model.dart';

final gymData = DemoSet(
  id: 'gym',
  name: 'Gym Freak (Push/Pull)',
  icon: '🏋️',
  desc: 'Balanced strength routine for maximum hypertrophy',
  color: AppColors.accent,
  tasks: [
    const TaskModel(
        id: 0,
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
        id: 0,
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
        id: 0,
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
        id: 0,
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
        id: 0,
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
        id: 0,
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
      id: 'gym-n2',
      content:
          '🥗 Nutrition: Post-workout window is optimal for fast-absorbing carbs + protein to kickstart glycogen replenishment.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ],
);
