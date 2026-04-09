import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../leaderboard/data/leaderboard_repository.dart';

class SocialState {
  final Set<String> sentChallenges;
  final Set<String> receivedChallenges;
  final Set<String> friends;

  SocialState({
    this.sentChallenges = const {},
    this.receivedChallenges = const {},
    this.friends = const {},
  });

  SocialState copyWith({
    Set<String>? sentChallenges,
    Set<String>? receivedChallenges,
    Set<String>? friends,
  }) {
    return SocialState(
      sentChallenges: sentChallenges ?? this.sentChallenges,
      receivedChallenges: receivedChallenges ?? this.receivedChallenges,
      friends: friends ?? this.friends,
    );
  }
}

class SocialNotifier extends StateNotifier<SocialState> {
  final Ref ref;
  final _supabase = Supabase.instance.client;
  RealtimeChannel? _subscription;

  SocialNotifier(this.ref) : super(SocialState()) {
    _init();
  }

  void _init() {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      refresh(user.id);
      _subscribe(user.id);
    }

    ref.listen(currentUserProvider, (prev, next) {
      if (next != null) {
        refresh(next.id);
        _subscribe(next.id);
      } else {
        _unsubscribe();
        state = SocialState();
      }
    });
  }

  void _subscribe(String userId) {
    _unsubscribe();
    _subscription = _supabase.channel('public:social:$userId')
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'social_challenges',
        callback: (payload) => refresh(userId)
      )
      .onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'friends',
        callback: (payload) => refresh(userId)
      )
      .subscribe();
  }

  void _unsubscribe() {
    _subscription?.unsubscribe();
    _subscription = null;
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  Future<void> refresh(String userId) async {
    final repo = ref.read(leaderboardRepositoryProvider);
    
    // Fetch pending challenges
    final challenges = await repo.fetchPendingChallenges(userId);
    final sent = <String>{};
    final received = <String>{};
    
    for (var c in challenges) {
      if (c['challenger_id'] == userId) {
        sent.add(c['challenged_id']);
      } else {
        received.add(c['challenger_id']);
      }
    }

    // Fetch friend IDs
    final friends = await repo.fetchFriendIds(userId);

    state = state.copyWith(
      sentChallenges: sent,
      receivedChallenges: received,
      friends: friends,
    );
  }

  Future<void> sendChallenge(String targetId) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    await ref.read(leaderboardRepositoryProvider).sendChallenge(user.id, targetId);
    // Real-time listener will trigger the refresh automatically
  }
}

final socialProvider = StateNotifierProvider<SocialNotifier, SocialState>((ref) {
  return SocialNotifier(ref);
});
