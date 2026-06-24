import '../models/achievement.dart';
import '../models/player_profile.dart';
import 'stats_repository.dart';

/// Data-driven achievement catalogue + evaluation.
///
/// New achievements are added by appending to [_catalog]; no other code needs
/// to change. Evaluation reads only from the [PlayerProfile] and aggregate
/// stats, so any system that mutates those automatically drives unlocks.
class AchievementRepository {
  AchievementRepository(this._stats);

  final StatsRepository _stats;

  /// Tracks how many times the player has beaten a high score across all games,
  /// surfaced for the `highScoreBeaten` achievement type. Stored on the profile
  /// would couple the model to achievements, so it is derived/incremented by the
  /// progression service and passed in via [evaluate].
  static const List<Achievement> _catalog = <Achievement>[
    Achievement(
      id: 'first_game',
      title: 'First Game',
      description: 'Play your very first game.',
      type: AchievementType.gamesPlayed,
      threshold: 1,
      coinReward: 50,
      xpReward: 25,
    ),
    Achievement(
      id: 'play_10',
      title: 'Getting Warmed Up',
      description: 'Play 10 games.',
      type: AchievementType.gamesPlayed,
      threshold: 10,
      coinReward: 100,
      xpReward: 50,
    ),
    Achievement(
      id: 'play_100',
      title: 'Arcade Regular',
      description: 'Play 100 games.',
      type: AchievementType.gamesPlayed,
      threshold: 100,
      coinReward: 500,
      xpReward: 200,
    ),
    Achievement(
      id: 'level_5',
      title: 'Rising Star',
      description: 'Reach level 5.',
      type: AchievementType.level,
      threshold: 5,
      coinReward: 150,
      xpReward: 0,
    ),
    Achievement(
      id: 'level_10',
      title: 'Arcade Veteran',
      description: 'Reach level 10.',
      type: AchievementType.level,
      threshold: 10,
      coinReward: 400,
      xpReward: 0,
    ),
    Achievement(
      id: 'coins_1000',
      title: 'Coin Collector',
      description: 'Earn 1,000 coins in total.',
      type: AchievementType.coinsEarned,
      threshold: 1000,
      coinReward: 200,
      xpReward: 100,
    ),
    Achievement(
      id: 'beat_high_score_10',
      title: 'Record Breaker',
      description: 'Beat a high score 10 times.',
      type: AchievementType.highScoreBeaten,
      threshold: 10,
      coinReward: 300,
      xpReward: 150,
    ),
    Achievement(
      id: 'streak_7',
      title: 'Dedicated',
      description: 'Log in 7 days in a row.',
      type: AchievementType.loginStreak,
      threshold: 7,
      coinReward: 500,
      xpReward: 250,
    ),
    Achievement(
      id: 'wins_25',
      title: 'On a Roll',
      description: 'Win 25 games.',
      type: AchievementType.winsTotal,
      threshold: 25,
      coinReward: 250,
      xpReward: 120,
    ),
  ];

  /// All achievements with their unlocked flag resolved for [profile].
  List<Achievement> all(PlayerProfile profile) => <Achievement>[
        for (final Achievement a in _catalog)
          a.copyWith(unlocked: profile.unlockedAchievements.contains(a.id)),
      ];

  int unlockedCount(PlayerProfile profile) => profile.unlockedAchievements
      .where((String id) => _catalog.any((Achievement a) => a.id == id))
      .length;

  int get total => _catalog.length;

  /// Returns achievements that are *now* satisfied but not yet recorded as
  /// unlocked on [profile]. The caller persists the unlocks and grants rewards.
  ///
  /// [lifetimeCoinsEarned] and [highScoresBeaten] are counters the progression
  /// service maintains and supplies, keeping the profile model decoupled.
  List<Achievement> evaluate(
    PlayerProfile profile, {
    required int lifetimeCoinsEarned,
    required int highScoresBeaten,
    required int loginStreak,
  }) {
    final List<Achievement> newlyUnlocked = <Achievement>[];
    for (final Achievement a in _catalog) {
      if (profile.unlockedAchievements.contains(a.id)) continue;
      if (_meets(a, profile,
          lifetimeCoinsEarned: lifetimeCoinsEarned,
          highScoresBeaten: highScoresBeaten,
          loginStreak: loginStreak)) {
        newlyUnlocked.add(a);
      }
    }
    return newlyUnlocked;
  }

  bool _meets(
    Achievement a,
    PlayerProfile profile, {
    required int lifetimeCoinsEarned,
    required int highScoresBeaten,
    required int loginStreak,
  }) {
    switch (a.type) {
      case AchievementType.gamesPlayed:
        return profile.gamesPlayed >= a.threshold;
      case AchievementType.level:
        return profile.level >= a.threshold;
      case AchievementType.coinsEarned:
        return lifetimeCoinsEarned >= a.threshold;
      case AchievementType.highScoreBeaten:
        return highScoresBeaten >= a.threshold;
      case AchievementType.loginStreak:
        return loginStreak >= a.threshold;
      case AchievementType.winsTotal:
        return profile.wins >= a.threshold;
    }
  }
}
