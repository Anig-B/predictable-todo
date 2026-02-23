import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../models/task_model.dart';

/// Call [SeedDataService.seed] once to populate the current user/team
/// with realistic Predictable Revenue sales team demo data.
class SeedDataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  Future<void> seed({
    required String userId,
    required String teamId,
  }) async {
    final batch = _db.batch();

    // ── 1. Recurring Sales Tasks ─────────────────────────────────────────────
    final tasks = _buildTasks(userId, teamId);
    for (final task in tasks) {
      final ref = _db.collection('task_definitions').doc(task['id'] as String);
      batch.set(ref, task);
    }

    // ── 2. Past 7 days of completions ────────────────────────────────────────
    final completions = _buildCompletions(userId, teamId, tasks);
    for (final c in completions) {
      final ref = _db.collection('completions').doc(c['id'] as String);
      batch.set(ref, c);
    }

    // ── 3. Past 7 days of pipeline metrics ───────────────────────────────────
    final metrics = _buildPipelineMetrics(userId, teamId);
    for (final m in metrics) {
      final ref = _db.collection('pipeline_metrics').doc(m['id'] as String);
      batch.set(ref, m);
    }

    await batch.commit();
  }

  // ── Task Definitions ────────────────────────────────────────────────────────

  List<Map<String, dynamic>> _buildTasks(String userId, String teamId) {
    final now = Timestamp.now();

    return [
      _task(
        id: _uuid.v4(),
        teamId: teamId,
        creatorId: userId,
        title: '50 Cold Calls',
        description: 'Hit daily cold call quota. Log in CRM after each call.',
        recurrence: 'daily',
        category: 'spear',
        priority: 'high',
        now: now,
      ),
      _task(
        id: _uuid.v4(),
        teamId: teamId,
        creatorId: userId,
        title: 'Personalised Email Sequences',
        description:
            'Send 20 personalised outbound emails. Use the SPEAR framework.',
        recurrence: 'daily',
        category: 'spear',
        priority: 'high',
        now: now,
      ),
      _task(
        id: _uuid.v4(),
        teamId: teamId,
        creatorId: userId,
        title: 'LinkedIn Outreach (10 Connects)',
        description:
            'Send 10 connection requests + personalised notes to ICP prospects.',
        recurrence: 'daily',
        category: 'seed',
        priority: 'medium',
        now: now,
      ),
      _task(
        id: _uuid.v4(),
        teamId: teamId,
        creatorId: userId,
        title: 'Follow-Up Open Opportunities',
        description:
            'Review and action all opportunities that have not moved in 3+ days.',
        recurrence: 'daily',
        category: 'net',
        priority: 'high',
        now: now,
      ),
      _task(
        id: _uuid.v4(),
        teamId: teamId,
        creatorId: userId,
        title: 'Weekly Pipeline Review',
        description:
            'Scrub pipeline with manager. Update stage, value, and close dates.',
        recurrence: 'weekly',
        daysOfWeek: [1], // Monday
        category: 'net',
        priority: 'high',
        now: now,
      ),
      _task(
        id: _uuid.v4(),
        teamId: teamId,
        creatorId: userId,
        title: 'Discovery Call Prep',
        description:
            'Research the 3 prospects booked for discovery this week. Build custom decks.',
        recurrence: 'weekly',
        daysOfWeek: [2], // Tuesday
        category: 'spear',
        priority: 'medium',
        now: now,
      ),
      _task(
        id: _uuid.v4(),
        teamId: teamId,
        creatorId: userId,
        title: 'Update CRM Notes',
        description:
            'Ensure all call outcomes from today are logged in the CRM before end of day.',
        recurrence: 'daily',
        category: 'other',
        priority: 'low',
        now: now,
      ),
    ];
  }

  Map<String, dynamic> _task({
    required String id,
    required String teamId,
    required String creatorId,
    required String title,
    required String description,
    required String recurrence,
    required String category,
    required String priority,
    required Timestamp now,
    List<int> daysOfWeek = const [],
    int? dayOfMonth,
  }) {
    return {
      'id': id,
      'teamId': teamId,
      'creatorId': creatorId,
      'assigneeIds': [creatorId],
      'title': title,
      'description': description,
      'recurrenceType': recurrence,
      'daysOfWeek': daysOfWeek,
      'dayOfMonth': dayOfMonth,
      'category': category,
      'priority': priority,
      'subTasks': [],
      'isActive': true,
      'createdAt': now,
    };
  }

  // ── Past Completions ─────────────────────────────────────────────────────────

  List<Map<String, dynamic>> _buildCompletions(
    String userId,
    String teamId,
    List<Map<String, dynamic>> tasks,
  ) {
    final fmt = DateFormat('yyyy-MM-dd');
    final completions = <Map<String, dynamic>>[];

    // Mark daily tasks completed for last 6 days (skip today for realism)
    final dailyTasks = tasks.where((t) => t['recurrenceType'] == 'daily');

    for (int daysAgo = 1; daysAgo <= 6; daysAgo++) {
      final date = DateTime.now().subtract(Duration(days: daysAgo));
      final dateStr = fmt.format(date);

      for (final task in dailyTasks) {
        // 80% completion rate for realism
        if (daysAgo == 3 && task['priority'] == 'low') continue;

        final taskId = task['id'] as String;
        final id = '${taskId}_${userId}_$dateStr';
        completions.add({
          'id': id,
          'taskId': taskId,
          'userId': userId,
          'teamId': teamId,
          'date': dateStr,
          'status': 'completed',
          'notes': _demoNote(task['title'] as String, daysAgo),
          'result': '',
          'timestamp': Timestamp.fromDate(
            date.copyWith(hour: 17, minute: 30),
          ),
        });
      }
    }

    return completions;
  }

  String _demoNote(String taskTitle, int daysAgo) {
    final notes = {
      '50 Cold Calls': [
        'Hit 52. 3 connects, 1 interested.',
        'Tough day — 48 calls, 2 connects.',
        'Strong session! 55 calls, 4 connects, 2 demos booked.',
        'Hit 50 flat. Friday energy low but done.',
        'Hit quota. Left 12 VMs.',
        '53 calls. Good energy.',
      ],
      'Personalised Email Sequences': [
        'Sent 22 emails. 2 OOO bounces.',
        '20 sent. Testing new subject line.',
        '25 sent with personalised intros.',
        '20 done by 11am.',
        'Sent to 3 new ICPs + 17 follow-ups.',
        '20 sent. 1 positive reply!',
      ],
    };

    final taskNotes = notes[taskTitle];
    if (taskNotes != null && daysAgo <= taskNotes.length) {
      return taskNotes[daysAgo - 1];
    }
    return 'Completed.';
  }

  // ── Pipeline Metrics ─────────────────────────────────────────────────────────

  List<Map<String, dynamic>> _buildPipelineMetrics(
    String userId,
    String teamId,
  ) {
    final fmt = DateFormat('yyyy-MM-dd');
    final rand = [
      {'calls': 52, 'connects': 3, 'meetings': 1},
      {'calls': 48, 'connects': 2, 'meetings': 0},
      {'calls': 55, 'connects': 4, 'meetings': 2},
      {'calls': 50, 'connects': 2, 'meetings': 1},
      {'calls': 53, 'connects': 3, 'meetings': 1},
      {'calls': 46, 'connects': 1, 'meetings': 0},
      {'calls': 60, 'connects': 5, 'meetings': 2},
    ];

    final metrics = <Map<String, dynamic>>[];
    for (int i = 0; i < 7; i++) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateStr = fmt.format(date);
      final id = '${userId}_$dateStr';
      final data = rand[i];
      metrics.add({
        'id': id,
        'userId': userId,
        'teamId': teamId,
        'date': dateStr,
        'calls': data['calls'],
        'connects': data['connects'],
        'meetingsBooked': data['meetings'],
        'timestamp': date.millisecondsSinceEpoch,
      });
    }
    return metrics;
  }
}

extension on DateTime {
  DateTime copyWith({int? hour, int? minute}) {
    return DateTime(
      year,
      month,
      day,
      hour ?? this.hour,
      minute ?? this.minute,
    );
  }
}
