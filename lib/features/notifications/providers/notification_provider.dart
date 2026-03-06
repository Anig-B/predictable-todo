import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../../../core/data/seed_data.dart';

class NotificationNotifier extends StateNotifier<List<NotificationModel>> {
  NotificationNotifier() : super(SeedData.notifications);

  int get unreadCount => state.where((n) => !n.read).length;

  void markAllRead() {
    state = state.map((n) => n.copyWith(read: true)).toList();
  }

  void markRead(int id) {
    state = state.map((n) => n.id == id ? n.copyWith(read: true) : n).toList();
  }

  void add(NotificationModel notification) {
    state = [notification, ...state];
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, List<NotificationModel>>(
  (ref) => NotificationNotifier(),
);

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationProvider).where((n) => !n.read).length;
});
