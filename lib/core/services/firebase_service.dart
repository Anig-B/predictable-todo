import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart' as gsis;
import 'package:rxdart/rxdart.dart';
import 'package:intl/intl.dart';
import '../../models/user_model.dart';
import '../../models/task_model.dart';
import '../../models/user_model.dart';
import '../../models/task_model.dart';
import '../../models/pipeline_metric_model.dart';
import '../../models/handoff_checklist_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final gsis.GoogleSignIn _googleSignIn = gsis.GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Stream<UserModel?> get userProfileStream {
    return _auth.authStateChanges().switchMap((user) {
      if (user == null) return Stream.value(null);
      return _db.collection('users').doc(user.uid).snapshots().map((doc) {
        if (!doc.exists) return null;
        return UserModel.fromMap(doc.data()!);
      });
    });
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final gsis.GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final gsis.GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );
      if (userCredential.user != null) {
        await _updateUserData(userCredential.user!);
      }
      return userCredential;
    } catch (e) {
      print('Error signing in with Google: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> _updateUserData(User user) async {
    final userRef = _db.collection('users').doc(user.uid);
    final doc = await userRef.get();

    if (!doc.exists) {
      final newUser = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
        photoUrl: user.photoURL ?? '',
        teams: [],
      );
      await userRef.set(newUser.toMap());
    }
  }

  Future<UserModel?> getUserData(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!);
    }
    return null;
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

  // Task Methods
  Future<void> createTask(TaskDefinitionModel task) async {
    await _db.collection('task_definitions').add(task.toMap());
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

    await _db
        .collection('completions')
        .doc(completionId)
        .set(completion.toMap());

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
    await _db.collection('pipeline_metrics').doc(metric.id).set(metric.toMap());
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
    await _db
        .collection('checklist_templates')
        .doc(template.teamId)
        .set(template.toMap());
  }

  Future<void> saveHandoffChecklist(HandoffChecklistModel checklist) async {
    await _db
        .collection('handoff_checklists')
        .doc(checklist.id)
        .set(checklist.toMap());
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
}
