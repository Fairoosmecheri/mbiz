import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../data/models/game_stats.dart';
import '../../features/game_framework/game_result.dart';

final statsProvider =
    NotifierProvider<StatsNotifier, List<GameStats>>(StatsNotifier.new);

/// Reactive view of per-game statistics. Mutated by the progression service
/// when a game result is processed.
class StatsNotifier extends Notifier<List<GameStats>> {
  @override
  List<GameStats> build() => ref.read(statsRepositoryProvider).all();

  GameStats statsFor(String gameId) =>
      ref.read(statsRepositoryProvider).statsFor(gameId);

  /// Fold a finished session into the stored stats and return the updated
  /// record together with whether it set a new high score.
  ({GameStats stats, bool isHighScore}) record(
    GameResult result,
    bool higherIsBetter,
  ) {
    final repo = ref.read(statsRepositoryProvider);
    final GameStats current = repo.statsFor(result.gameId);

    final bool isHighScore = current.timesPlayed == 0 ||
        (higherIsBetter
            ? result.score > current.highScore
            : result.score < current.highScore);

    final GameStats updated = current.copyWith(
      timesPlayed: current.timesPlayed + 1,
      highScore: isHighScore ? result.score : current.highScore,
      totalScore: current.totalScore + result.score,
      totalPlayTimeSeconds:
          current.totalPlayTimeSeconds + result.durationSeconds,
      wins: current.wins + (result.won ? 1 : 0),
      lastPlayedEpoch: DateTime.now().millisecondsSinceEpoch,
    );

    repo.save(updated);
    state = repo.all();
    return (stats: updated, isHighScore: isHighScore);
  }
}
