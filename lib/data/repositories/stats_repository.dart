import '../../core/services/storage_service.dart';
import '../models/game_stats.dart';

/// Persistence gateway for per-game [GameStats], keyed by game id.
class StatsRepository {
  StatsRepository(this._storage);

  final StorageService _storage;

  GameStats statsFor(String gameId) {
    final dynamic raw = _storage.statsBox.get(gameId);
    if (raw is Map) return GameStats.fromJson(raw);
    return GameStats.empty(gameId);
  }

  /// All stored stats (one per game that has been played at least once).
  List<GameStats> all() {
    return _storage.statsBox.values
        .whereType<Map>()
        .map(GameStats.fromJson)
        .toList();
  }

  Future<void> save(GameStats stats) =>
      _storage.statsBox.put(stats.gameId, stats.toJson());

  // ---------------------------------------------------------------------------
  // Aggregate, cross-game figures for the statistics dashboard.
  // ---------------------------------------------------------------------------

  int get lifetimeGamesPlayed =>
      all().fold(0, (int sum, GameStats s) => sum + s.timesPlayed);

  int get lifetimePlayTimeSeconds =>
      all().fold(0, (int sum, GameStats s) => sum + s.totalPlayTimeSeconds);

  int get lifetimeWins => all().fold(0, (int sum, GameStats s) => sum + s.wins);
}
