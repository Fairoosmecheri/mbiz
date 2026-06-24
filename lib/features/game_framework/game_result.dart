/// The immutable outcome a [MiniGame] reports when a session ends.
///
/// Crucially this carries *no* knowledge of XP, coins, or achievements — those
/// are derived by the progression layer when the result is processed. That
/// keeps every game decoupled from the reward economy.
class GameResult {
  const GameResult({
    required this.gameId,
    required this.score,
    required this.won,
    required this.durationSeconds,
    this.metrics = const <String, int>{},
  });

  final String gameId;

  /// The raw score. Interpretation (higher vs. lower is better, units) is
  /// owned by the originating [MiniGame].
  final int score;

  /// Whether the player met the game's win/objective condition. Endless games
  /// can simply report `true` for "completed a run".
  final bool won;

  final int durationSeconds;

  /// Optional extra signals a game can expose for challenges/achievements,
  /// e.g. `{'survivedSeconds': 63}` for Ball Dodge.
  final Map<String, int> metrics;
}
