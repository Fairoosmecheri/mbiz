import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../data/models/daily_challenge.dart';
import '../../features/game_framework/game_result.dart';

final challengesProvider =
    NotifierProvider<ChallengesNotifier, List<DailyChallenge>>(
        ChallengesNotifier.new);

/// Owns the daily challenge list: generation, progress tracking and claiming.
class ChallengesNotifier extends Notifier<List<DailyChallenge>> {
  @override
  List<DailyChallenge> build() =>
      ref.read(challengeRepositoryProvider).loadOrGenerate();

  /// Advance progress on every challenge a finished session contributes to.
  void applyResult(GameResult result) {
    final List<DailyChallenge> updated = <DailyChallenge>[
      for (final DailyChallenge c in state) _advance(c, result),
    ];
    _persist(updated);
  }

  DailyChallenge _advance(DailyChallenge c, GameResult result) {
    if (c.claimed || c.isComplete) return c;

    final bool gameMatches = c.gameId == null || c.gameId == result.gameId;
    if (!gameMatches) return c;

    switch (c.metric) {
      case ChallengeMetric.gamesPlayed:
        return c.copyWith(progress: c.progress + 1);
      case ChallengeMetric.scoreInGame:
        // Track best score reached toward the target.
        return c.copyWith(progress: result.score > c.progress
            ? result.score
            : c.progress);
      case ChallengeMetric.surviveSeconds:
        final int survived =
            result.metrics['survivedSeconds'] ?? result.durationSeconds;
        return c.copyWith(
            progress: survived > c.progress ? survived : c.progress);
      case ChallengeMetric.completeUnderSeconds:
        // Completing under the threshold marks it done in one shot.
        if (result.won && result.durationSeconds <= c.target) {
          return c.copyWith(progress: c.target);
        }
        return c;
    }
  }

  /// Claim a completed challenge's reward. Returns the claimed challenge so the
  /// caller can grant coins/XP, or `null` if it can't be claimed.
  DailyChallenge? claim(String challengeId) {
    final int index =
        state.indexWhere((DailyChallenge c) => c.id == challengeId);
    if (index == -1) return null;
    final DailyChallenge c = state[index];
    if (!c.isComplete || c.claimed) return null;

    final DailyChallenge claimed = c.copyWith(claimed: true);
    final List<DailyChallenge> updated = List<DailyChallenge>.of(state)
      ..[index] = claimed;
    _persist(updated);
    return claimed;
  }

  void _persist(List<DailyChallenge> challenges) {
    state = challenges;
    ref.read(challengeRepositoryProvider).save(challenges);
  }
}
