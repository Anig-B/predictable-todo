import '../../theme/app_colors.dart';
import '../../../features/tasks/models/task_model.dart';
import '../../../features/tasks/models/note_model.dart';
import 'demo_set_model.dart';

final rebuzzData = DemoSet(
  id: 'rebuzz',
  name: 'Rebuzz Lead Gen',
  icon: '🏪',
  desc: 'SDR & Marketing stack for predictable POS sales',
  color: AppColors.purple,
  tasks: [
    const TaskModel(
        id: 0,
        title: 'Map Primary & Secondary ICPs',
        desc:
            'Identify exact criteria for best Rebuzz POS customers based on high-velocity turnover and low tech-debt.',
        time: '08:30 AM',
        points: 120,
        project: 'Strategy',
        streak: 0,
        done: false,
        priority: TaskPriority.high,
        category: TaskCategory.work),
    const TaskModel(
        id: 0,
        title: 'Segment Database by Niche',
        desc:
            'Break TAM into sub-niches (craft cafes, boutique retailers, high-end bistros) for personalized messaging.',
        time: '10:15 AM',
        points: 80,
        project: 'Strategy',
        streak: 0,
        done: false,
        priority: TaskPriority.high,
        category: TaskCategory.work),
    const TaskModel(
        id: 0,
        title: 'Launch SDR Outbound Sequence',
        desc:
            'Trigger custom LinkedIn + Email flows for 50 leads in the "Boutique Retail" segment.',
        time: '11:45 AM',
        points: 100,
        project: 'Outbound',
        streak: 0,
        done: false,
        priority: TaskPriority.high,
        category: TaskCategory.work),
    const TaskModel(
        id: 0,
        title: 'Weekly SDR Scorecard Review',
        desc:
            'Analyze reply rates and meeting booked metrics from the previous week.',
        time: '09:00 AM',
        points: 200,
        project: 'Analytics',
        streak: 4,
        done: false,
        priority: TaskPriority.high,
        recurring: TaskRecurring.weekly,
        weeklyDay: 1, // Monday
        category: TaskCategory.work),
    const TaskModel(
        id: 0,
        title: 'Monthly TAM Expansion Audit',
        desc:
            'Scour local business registries for new shop openings and potential Rebuzz converts.',
        time: '02:30 PM',
        points: 500,
        project: 'Growth',
        streak: 1,
        done: false,
        priority: TaskPriority.high,
        recurring: TaskRecurring.monthly,
        monthlyDay: 1,
        category: TaskCategory.work),
    const TaskModel(
        id: 0,
        title: 'POS ROI Calculator Whitepaper',
        desc:
            'Publish gated lead magnet for top-of-funnel traffic focusing on cost-reduction vs legacy systems.',
        time: '01:45 PM',
        points: 150,
        project: 'Inbound',
        streak: 0,
        done: false,
        priority: TaskPriority.high,
        category: TaskCategory.work),
    const TaskModel(
        id: 0,
        title: 'Draft SDR One-pagers',
        desc:
            'Create visual scripts for common objections (Price, Hardware, Onboarding).',
        time: '03:15 PM',
        points: 60,
        project: 'Sales Ops',
        streak: 0,
        done: false,
        priority: TaskPriority.medium,
        category: TaskCategory.work),
  ],
  notes: [
    NoteModel(
      id: 'reb-n1',
      content:
          '💡 ICP Insight: Fast-casual dining has 15% higher LTV with our current loyalty module than standard retail.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NoteModel(
      id: 'reb-n2',
      content:
          '📜 Strategy: Shift focus to "Self-Service Kiosks" for the Q3 campaign. The ROI for merchants is undeniable in high-volume areas.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    NoteModel(
      id: 'reb-n3',
      content:
          '🕵️ Competitor Watch: LegacyPOS just raised their monthly maintenance fee by 20%. This is a prime opportunity for our SDRs to lead with "Predictable Pricing".',
      createdAt: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
    ),
    NoteModel(
      id: 'reb-n4',
      content:
          '🎤 Customer Quote (The Daily Grind Cafe): "The kitchen display system saved us from 3 order errors during the morning rush today. Best feature yet."',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    NoteModel(
      id: 'reb-n5',
      content:
          '📝 Sales Script Refinement: Always ask "How long does it take for your inventory to sync across devices?" early in the call. It highlights the lag in their current system.',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ],
);
