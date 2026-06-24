import 'package:flutter/material.dart';

import 'game_difficulty.dart';
import 'game_result.dart';

/// Handed to a running game so it can report its outcome.
///
/// A game calls [submit] exactly once when the session ends. The host page
/// listens and drives the result/reward flow. Passing a controller (rather than
/// a bare callback) leaves room to add pause/quit hooks later without changing
/// every game signature.
class GameController {
  GameController({required void Function(GameResult result) onResult})
      : _onResult = onResult;

  final void Function(GameResult result) _onResult;
  bool _submitted = false;

  /// Report the final result. Subsequent calls are ignored so a game can never
  /// double-award rewards.
  void submit(GameResult result) {
    if (_submitted) return;
    _submitted = true;
    _onResult(result);
  }
}

/// The contract every mini-game implements.
///
/// This is the cornerstone of the "unlimited future games" requirement: a new
/// game only has to implement this interface and register itself with the
/// [GameRegistry]. It then appears automatically in the games grid, statistics,
/// challenges, achievements and leaderboards — no existing code is touched.
abstract class MiniGame {
  /// Stable, unique identifier (snake_case). Used as the storage/leaderboard
  /// key, so it must never change once shipped.
  String get id;

  /// Display name shown on cards and the in-game header.
  String get name;

  /// One-line description for the game card / details.
  String get description;

  /// Icon shown on the game card.
  IconData get icon;

  /// Accent colour used to theme the card and in-game chrome.
  Color get accentColor;

  GameDifficulty get difficulty;

  /// Whether a *higher* raw score is better. Reaction Test overrides this to
  /// `false` because it measures milliseconds (lower = better).
  bool get higherIsBetter => true;

  /// Short unit label appended to scores in the UI (e.g. 'ms', 'pts').
  String get scoreUnit => 'pts';

  /// Format a raw score for display. Defaults to "<n> <unit>".
  String formatScore(int score) => '$score $scoreUnit';

  /// Compare two scores honouring [higherIsBetter]. Returns `true` if
  /// [candidate] beats [current].
  bool beats(int candidate, int current) =>
      higherIsBetter ? candidate > current : candidate < current;

  /// Build the playable widget. The game must call [GameController.submit] once
  /// the session concludes.
  Widget build(BuildContext context, GameController controller);
}
