import 'mini_game.dart';

/// Runtime catalogue of every available [MiniGame].
///
/// This registry is what makes the platform open-ended: games register
/// themselves here at startup and every consumer (games grid, statistics,
/// challenge generator, achievement evaluator, leaderboards) iterates the
/// registry instead of hard-coding a game list. Adding a game therefore never
/// requires editing those consumers.
class GameRegistry {
  GameRegistry();

  final List<MiniGame> _games = <MiniGame>[];

  /// All registered games, in registration order.
  List<MiniGame> get games => List<MiniGame>.unmodifiable(_games);

  /// Register a game. Ignores duplicate ids so hot-reload can't double-add.
  void register(MiniGame game) {
    if (_games.any((MiniGame g) => g.id == game.id)) return;
    _games.add(game);
  }

  /// Register many at once.
  void registerAll(Iterable<MiniGame> games) => games.forEach(register);

  /// Look up a game by id, or `null` if not registered.
  MiniGame? byId(String id) {
    for (final MiniGame g in _games) {
      if (g.id == id) return g;
    }
    return null;
  }

  bool get isEmpty => _games.isEmpty;
  int get length => _games.length;
}
