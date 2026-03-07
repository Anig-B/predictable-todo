import '../../theme/app_colors.dart';
import '../../../features/tasks/models/task_model.dart';
import '../../../features/tasks/models/note_model.dart';
import 'demo_set_model.dart';

final dietData = DemoSet(
  id: 'diet',
  name: 'Pure Nutrition',
  icon: '🍱',
  desc: 'Clean eating and ritualized meal preparation',
  color: AppColors.red,
  tasks: [
    const TaskModel(
        id: 0,
        title: 'Morning Macro Check',
        desc: 'Track all meals for the day in advance.',
        time: '7:00 AM',
        points: 50,
        project: 'Tracking',
        streak: 0,
        done: false,
        priority: TaskPriority.medium,
        category: TaskCategory.health),
    const TaskModel(
        id: 0,
        title: 'Bulk Prep: Lean Protein',
        desc: 'Cook 2kg of chicken/tofu for the week.',
        time: '10:00 AM',
        points: 120,
        project: 'Meal Prep',
        streak: 0,
        done: false,
        priority: TaskPriority.high,
        category: TaskCategory.health),
    const TaskModel(
        id: 0,
        title: 'Gallon of Water',
        desc: 'Steady intake throughout the day.',
        time: 'All day',
        points: 60,
        project: 'Hydration',
        streak: 0,
        done: false,
        priority: TaskPriority.medium,
        category: TaskCategory.health),
    const TaskModel(
        id: 0,
        title: 'Zero Processed Sugar Day',
        desc: 'No sweets, sodas, or hidden sugars.',
        time: 'End of Day',
        points: 100,
        project: 'Fat Loss',
        streak: 0,
        done: false,
        priority: TaskPriority.high,
        category: TaskCategory.health),
    const TaskModel(
        id: 0,
        title: 'Grocery Haul (Clean)',
        desc: 'Veggies, complex carbs, and healthy fats.',
        time: '5:00 PM',
        points: 80,
        project: 'Meal Prep',
        streak: 0,
        done: false,
        priority: TaskPriority.medium,
        category: TaskCategory.learning),
  ],
  notes: [
    NoteModel(
      id: 'diet-n1',
      content:
          '🍵 Metabolism: Green tea contains catechins that help slightly boost fat oxidation during rest.',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    NoteModel(
      id: 'diet-n2',
      content:
          '🥗 Fiber First: Starting your meal with a giant salad reduces the glucose spike of the subsequent dishes.',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ],
);
