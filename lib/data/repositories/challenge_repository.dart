import 'dart:math';

import '../../core/services/storage_service.dart';
import '../../features/game_framework/game_registry.dart';
import '../../features/game_framework/mini_game.dart';
import '../models/daily_challenge.dart';

/// Generates and persists the set of daily challenges.
///
/// Challenges are regenerated whenever the stored "day stamp" no longer matches
/// today. Generation is seeded by the date so every device produces the same
/// challenge set for a given day (handy for a future shared-challenges backend)
/// while still pulling targets from whatever games are registered.
class ChallengeRepository {
  ChallengeRepository(this._storage, this._registry);

  final StorageService _storage;
  final GameRegistry _registry;

  static const String _dayStampKey = 'day_stamp';
  static const String _challengesKey = 'challenges';

  /// Returns today's challenges, regenerating them if the day has rolled over.
  List<DailyChallenge> loadOrGenerate() {
    final String today = _todayStamp();
    final String? storedDay = _storage.challengesBox.get(_dayStampKey) as String?;

    if (storedDay == today) {
      final dynamic raw = _storage.challengesBox.get(_challengesKey);
      if (raw is List) {
        return raw
            .whereType<Map>()
            .map(DailyChallenge.fromJson)
            .toList();
      }
    }

    final List<DailyChallenge> generated = _generate(today);
    _save(generated);
    _storage.challengesBox.put(_dayStampKey, today);
    return generated;
  }

  Future<void> save(List<DailyChallenge> challenges) => _save(challenges);

  Future<void> _save(List<DailyChallenge> challenges) =>
      _storage.challengesBox.put(
        _challengesKey,
        challenges.map((DailyChallenge c) => c.toJson()).toList(),
      );

  String _todayStamp() {
    final DateTime now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  /// Builds 3 deterministic challenges for [dayStamp].
  List<DailyChallenge> _generate(String dayStamp) {
    final Random rng = Random(dayStamp.hashCode);
    final List<MiniGame> games = _registry.games;

    final List<DailyChallenge> result = <DailyChallenge>[
      // Always include a generic "play N games" challenge.
      DailyChallenge(
        id: '${dayStamp}_play',
        title: 'Play 5 games',
        metric: ChallengeMetric.gamesPlayed,
        target: 5,
        gameId: null,
        coinReward: 75,
        xpReward: 40,
        progress: 0,
        claimed: false,
      ),
    ];

    if (games.isNotEmpty) {
      final MiniGame g1 = games[rng.nextInt(games.length)];
      result.add(
        DailyChallenge(
          id: '${dayStamp}_score',
          title: 'Score ${_scoreTarget(g1)} in ${g1.name}',
          metric: ChallengeMetric.scoreInGame,
          target: _scoreTarget(g1),
          gameId: g1.id,
          coinReward: 100,
          xpReward: 60,
          progress: 0,
          claimed: false,
        ),
      );

      final MiniGame g2 = games[rng.nextInt(games.length)];
      result.add(
        DailyChallenge(
          id: '${dayStamp}_play_specific',
          title: 'Play ${g2.name} 3 times',
          metric: ChallengeMetric.gamesPlayed,
          target: 3,
          gameId: g2.id,
          coinReward: 80,
          xpReward: 45,
          progress: 0,
          claimed: false,
        ),
      );
    }

    return result;
  }

  /// A reasonable score target per game (higher-is-better games only; for
  /// lower-is-better games we fall back to a play challenge target).
  int _scoreTarget(MiniGame game) => game.higherIsBetter ? 30 : 1;
}
