import '../../data/models/achievement.dart';

/// Everything that happened as a result of finishing a game, surfaced on the
/// result screen so the player sees exactly what they earned.
class RewardSummary {
  const RewardSummary({
    required this.gameId,
    required this.score,
    required this.scoreLabel,
    required this.won,
    required this.isHighScore,
    required this.xpEarned,
    required this.coinsEarned,
    required this.previousLevel,
    required this.newLevel,
    required this.unlockedAchievements,
  });

  final String gameId;
  final int score;

  /// Pre-formatted score (e.g. "284 ms") from the game's own formatter.
  final String scoreLabel;

  final bool won;
  final bool isHighScore;
  final int xpEarned;
  final int coinsEarned;
  final int previousLevel;
  final int newLevel;
  final List<Achievement> unlockedAchievements;

  bool get leveledUp => newLevel > previousLevel;
}
