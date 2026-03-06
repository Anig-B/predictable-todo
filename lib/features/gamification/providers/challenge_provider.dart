import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/challenge_model.dart';
import '../../tasks/models/task_model.dart';
import '../../../core/data/seed_data.dart';

class ChallengeNotifier extends StateNotifier<List<ChallengeModel>> {
  ChallengeNotifier() : super(SeedData.challenges);

  int get doneCount => state.where((c) => c.done).length;
  bool get allDone => state.every((c) => c.done);

  void onTaskCompleted(TaskModel task, int completedInRow) {
    state = state.map((ch) {
      if (ch.done) return ch;
      // Health Hero: 2 health tasks
      if (ch.id == 3 && task.category == TaskCategory.health) {
        return ch.copyWith(done: true);
      }
      // Triple Threat: 3 in a row (combo)
      if (ch.id == 2 && completedInRow >= 3) {
        return ch.copyWith(done: true);
      }
      return ch;
    }).toList();
  }

  void reset() {
    state = SeedData.challenges;
  }
}

final challengeProvider =
    StateNotifierProvider<ChallengeNotifier, List<ChallengeModel>>(
  (ref) => ChallengeNotifier(),
);
