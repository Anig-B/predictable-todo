import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../models/user_model.dart';
import '../../models/task_model.dart';
import '../../models/pipeline_metric_model.dart';
import '../../models/handoff_checklist_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final BehaviorSubject<UserModel?> _userSubject = BehaviorSubject<UserModel?>.seeded(null);
  String? _localUid;

  Stream<UserModel?> get userProfileStream => _userSubject.stream;

  // Since we bypass auth, we expose the local ID as a stream for compatibility
  Stream<String?> get authStateChanges => _userSubject.map((user) => user?.uid);

  Future<void> initLocalUser() async {
    final prefs = await SharedPreferences.getInstance();
    _localUid = prefs.getString('local_device_uid');

    if (_localUid == null) {
      _localUid = const Uuid().v4();
      await prefs.setString('local_device_uid', _localUid!);
    }

    // Subscribe to the un-authenticated local user document
    _db.collection('users').doc(_localUid).snapshots().listen((doc) async {
      if (!doc.exists) {
        // Create the user profile on first launch since there's no auth trigger
        final newUser = UserModel(
          uid: _localUid!,
          email: 'local_device@predictable_todo.local',
          displayName: 'Local Guest',
          photoUrl: 'https://ui-avatars.com/api/?name=Guest+User&background=random',
          teams: [],
        );
        await _db.collection('users').doc(_localUid).set(newUser.toMap());
        _userSubject.add(newUser);
      } else {
        _userSubject.add(UserModel.fromMap(doc.data()!));
      }
    });
  }

  Future<void> signOut() async {
    // In a local-only setup, sign out might just mean clearing local storage.
    // However, since we rely on it as persistent identity, we won't implement a 
    // destructive sign out here. We just leave it as a no-op to support UI elements
    // that might still call it.
  }

  // Team Methods
  Future<String> createTeam(String userId, String teamName) async {
    final inviteCode = DateTime.now().millisecondsSinceEpoch
        .toString()
        .substring(7);
    final teamRef = _db.collection('teams').doc();

    await teamRef.set({
      'name': teamName,
      'inviteCode': inviteCode,
      'ownerId': userId,
      'members': {userId: 'owner'},
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _db.collection('users').doc(userId).update({
      'currentTeamId': teamRef.id,
      'teams': FieldValue.arrayUnion([
        {'teamId': teamRef.id, 'role': 'owner'},
      ]),
    });

    return teamRef.id;
  }

  Future<void> joinTeam(String inviteCode, String userId) async {
    // 1. Find team by invite code
    final query = await _db
        .collection('teams')
        .where('inviteCode', isEqualTo: inviteCode)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Invalid invite code');
    }

    final teamDoc = query.docs.first;
    final teamId = teamDoc.id;

    // 2. Add user to team members
    await teamDoc.reference.update({'members.$userId': 'member'});

    // 3. Update user profile
    await _db.collection('users').doc(userId).update({
      'currentTeamId': teamId,
      'teams': FieldValue.arrayUnion([
        {'teamId': teamId, 'role': 'member'},
      ]),
    });
  }

  // Task Methods
  Future<void> createTask(TaskDefinitionModel task) async {
    _db.collection('task_definitions').add(task.toMap()).catchError((e) => print('Error creating task: $e'));
  }

  Stream<List<TaskDefinitionModel>> getTasksForTeam(String teamId) {
    return _db
        .collection('task_definitions')
        .where('teamId', isEqualTo: teamId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TaskDefinitionModel.fromMap(doc.id, doc.data()))
              .toList();
        });
  }

  Future<void> completeTask({
    required String taskId,
    required String userId,
    required String teamId,
    required String status,
    String notes = '',
    String result = '',
  }) async {
    final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final completionId = '${taskId}_${userId}_$date';

    final completion = TaskCompletionModel(
      id: completionId,
      taskId: taskId,
      userId: userId,
      teamId: teamId,
      date: date,
      status: status,
      notes: notes,
      result: result,
      timestamp: DateTime.now(),
    );

    _db
        .collection('completions')
        .doc(completionId)
        .set(completion.toMap()).catchError((e) => print('Error completing task: $e'));

    // Potentially update streak logic here
  }

  Stream<List<TaskCompletionModel>> getCompletionsForUser(
    String userId,
    String date,
  ) {
    return _db
        .collection('completions')
        .where('userId', isEqualTo: userId)
        .where('date', isEqualTo: date)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TaskCompletionModel.fromMap(doc.id, doc.data()))
              .toList();
        });
  }

  // Social & Stats Methods
  Stream<List<TaskCompletionModel>> getCompletionsForTeam(
    String teamId,
    DateTime startDate,
  ) {
    final startString = DateFormat('yyyy-MM-dd').format(startDate);
    return _db
        .collection('completions')
        .where('teamId', isEqualTo: teamId)
        .where('date', isGreaterThanOrEqualTo: startString)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TaskCompletionModel.fromMap(doc.id, doc.data()))
              .toList();
        });
  }

  Stream<List<UserModel>> getTeamMembers(String teamId) {
    // Note: Firestore doesn't support array-contains-any for complex objects easily
    // This is a naive implementation. For scale, maintain a separate subcollection of members
    return _db
        .collection('users')
        .where('currentTeamId', isEqualTo: teamId) // Simplification for now
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => UserModel.fromMap(doc.data()))
              .toList();
        });
  }

  Stream<List<TaskCompletionModel>> getTeamActivity(String teamId) {
    return _db
        .collection('completions')
        .where('teamId', isEqualTo: teamId)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => TaskCompletionModel.fromMap(doc.id, doc.data()))
              .toList();
        });
  }

  // Pipeline Methods
  Future<void> savePipelineMetric(PipelineMetricModel metric) async {
    _db.collection('pipeline_metrics').doc(metric.id).set(metric.toMap()).catchError((e) => print('Error saving metric: $e'));
  }

  Stream<List<PipelineMetricModel>> getPipelineMetrics(
    String userId,
    DateTime startDate,
  ) {
    final startString = DateFormat('yyyy-MM-dd').format(startDate);
    return _db
        .collection('pipeline_metrics')
        .where('userId', isEqualTo: userId)
        .where('date', isGreaterThanOrEqualTo: startString)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => PipelineMetricModel.fromMap(doc.id, doc.data()))
              .toList();
        });
  }

  // Handoff Checklist Methods
  Stream<ChecklistTemplateModel?> getChecklistTemplate(String teamId) {
    return _db.collection('checklist_templates').doc(teamId).snapshots().map((
      doc,
    ) {
      if (!doc.exists) return null;
      return ChecklistTemplateModel.fromMap(doc.id, doc.data()!);
    });
  }

  Future<void> saveChecklistTemplate(ChecklistTemplateModel template) async {
    _db
        .collection('checklist_templates')
        .doc(template.teamId)
        .set(template.toMap()).catchError((e) => print('Error saving template: $e'));
  }

  Future<void> saveHandoffChecklist(HandoffChecklistModel checklist) async {
    _db
        .collection('handoff_checklists')
        .doc(checklist.id)
        .set(checklist.toMap()).catchError((e) => print('Error saving checklist: $e'));
  }

  Stream<List<HandoffChecklistModel>> getTeamHandoffs(String teamId) {
    return _db
        .collection('handoff_checklists')
        .where('teamId', isEqualTo: teamId)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => HandoffChecklistModel.fromMap(doc.id, doc.data()))
              .toList();
        });
  }
  Future<UserModel?> getUserData(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
  }

  Stream<Map<String, dynamic>?> getTeamStream(String teamId) {
    return _db.collection('teams').doc(teamId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return doc.data();
    });
  }

  Future<void> leaveTeam(String userId, String teamId) async {
    await _db.collection('users').doc(userId).update({
      'currentTeamId': null,
      'teams': FieldValue.arrayRemove([
        {'teamId': teamId, 'role': 'owner'},
        {'teamId': teamId, 'role': 'member'},
      ]),
    });
  }
}
