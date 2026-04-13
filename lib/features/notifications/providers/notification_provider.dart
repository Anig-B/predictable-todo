import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:flutter/foundation.dart';

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, List<NotificationModel>>(
  (ref) {
    final userId = ref.watch(currentUserProvider)?.id;
    final notifier = NotificationNotifier(userId);
    if (userId != null) {
      notifier.fetchNotifications();
      notifier.listenToNotifications();
    }
    return notifier;
  },
);

final unreadCountProvider = Provider<int>((ref) {
  return ref.watch(notificationProvider).where((n) => !n.read).length;
});

class NotificationNotifier extends StateNotifier<List<NotificationModel>> {
  final String? userId;
  final _supabase = Supabase.instance.client;
  RealtimeChannel? _subscription;

  NotificationNotifier(this.userId) : super([]);

  @override
  void dispose() {
    _subscription?.unsubscribe();
    super.dispose();
  }

  Future<void> fetchNotifications() async {
    if (userId == null) return;
    try {
      debugPrint('DEBUG: Fetching notifications for user: $userId');
      final data = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId!)
          .order('created_at', ascending: false);

      debugPrint('DEBUG: Found ${data.length} notifications');
      state = data.map((map) => NotificationModel.fromMap(map)).toList();
    } catch (e) {
      // Handle error gracefully

      debugPrint('Error fetching notifications: $e');
    }
  }

  void listenToNotifications() {
    if (userId == null) return;

    _subscription = _supabase
        .channel('public:notifications:user_id=eq.$userId')
        .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'notifications',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (payload) {
              fetchNotifications();
            })
        .subscribe();
  }

  int get unreadCount => state.where((n) => !n.read).length;

  Future<void> markAllRead() async {
    if (userId == null) return;

    // Update local state immediately for fast UI
    state = state.map((n) => n.copyWith(read: true)).toList();

    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId!)
          .eq('is_read', false);
    } catch (e) {
      debugPrint('Error marking all read: $e');
    }
  }

  Future<void> markRead(String id) async {
    state = state.map((n) => n.id == id ? n.copyWith(read: true) : n).toList();

    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true}).eq('id', id);
    } catch (e) {
      debugPrint('Error marking read: $e');
    }
  }

  Future<void> deleteNotification(String id) async {
    state = state.where((n) => n.id != id).toList();
    try {
      await _supabase.from('notifications').delete().eq('id', id);
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  Future<void> acceptChallenge(
      String notificationId, String challengeId) async {
    // Optimistic UI: remove from list
    state = state.where((n) => n.id != notificationId).toList();

    try {
      await _supabase
          .rpc('accept_challenge', params: {'challenge_id': challengeId});
      // Delete notification record after action
      await _supabase.from('notifications').delete().eq('id', notificationId);
    } catch (e) {
      debugPrint('Error accepting challenge: $e');
      fetchNotifications(); // Recover on error
    }
  }

  Future<void> declineChallenge(
      String notificationId, String challengeId) async {
    // Optimistic UI: remove from list
    state = state.where((n) => n.id != notificationId).toList();

    try {
      await _supabase
          .from('social_challenges')
          .update({'status': 'rejected'}).eq('id', challengeId);

      await _supabase.from('notifications').delete().eq('id', notificationId);
    } catch (e) {
      debugPrint('Error declining challenge: $e');
      fetchNotifications(); // Recover on error
    }
  }

  Future<void> clearAllSimpleNotifications() async {
    if (userId == null) return;

    // Filter out challenge requests which need input
    state = state.where((n) => n.type == 'challenge_received').toList();

    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('user_id', userId!)
          .neq('type', 'challenge_received');
    } catch (e) {
      debugPrint('Error clearing notifications: $e');
      fetchNotifications();
    }
  }
}
