import '../../core/services/firebase_service.dart';
import '../models/leaderboard_entry.dart';
import '../models/player_profile.dart';

/// Bridges the UI to the (currently mocked) backend leaderboard.
///
/// Because it depends only on the [FirebaseService] abstraction, switching to a
/// live Firestore backend requires no changes here or above.
class LeaderboardRepository {
  LeaderboardRepository(this._backend);

  final FirebaseService _backend;

  bool get isLiveBackend => _backend.isConnected;

  Future<void> submitScore({
    required String gameId,
    required PlayerProfile profile,
    required int score,
  }) {
    return _backend.submitScore(
      gameId: gameId,
      username: profile.username,
      avatarId: profile.avatarId,
      score: score,
    );
  }

  Future<List<LeaderboardEntry>> fetch({
    required String gameId,
    required LeaderboardScope scope,
  }) {
    return _backend.fetchLeaderboard(gameId: gameId, scope: scope);
  }
}
