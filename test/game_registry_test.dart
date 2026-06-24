import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pocket_arcade/features/game_framework/game_difficulty.dart';
import 'package:pocket_arcade/features/game_framework/game_registry.dart';
import 'package:pocket_arcade/features/game_framework/mini_game.dart';
import 'package:pocket_arcade/features/games/built_in_games.dart';

/// A throwaway game used to verify the registry's extensibility contract.
class _FakeGame extends MiniGame {
  @override
  String get id => 'fake_game';
  @override
  String get name => 'Fake';
  @override
  String get description => 'test';
  @override
  IconData get icon => Icons.bug_report;
  @override
  Color get accentColor => const Color(0xFF000000);
  @override
  GameDifficulty get difficulty => GameDifficulty.easy;
  @override
  Widget build(BuildContext context, GameController controller) =>
      const SizedBox.shrink();
}

void main() {
  group('GameRegistry', () {
    test('registers the five built-in games', () {
      final GameRegistry registry = GameRegistry();
      registerBuiltInGames(registry);

      expect(registry.length, 5);
      expect(registry.byId('reaction_test'), isNotNull);
      expect(registry.byId('speed_tap'), isNotNull);
      expect(registry.byId('stack_tower'), isNotNull);
      expect(registry.byId('ball_dodge'), isNotNull);
      expect(registry.byId('memory_match'), isNotNull);
    });

    test('ignores duplicate registrations by id', () {
      final GameRegistry registry = GameRegistry()
        ..register(_FakeGame())
        ..register(_FakeGame());
      expect(registry.length, 1);
    });

    test('a new game appears automatically once registered', () {
      final GameRegistry registry = GameRegistry();
      registerBuiltInGames(registry);
      final int before = registry.length;

      registry.register(_FakeGame());

      expect(registry.length, before + 1);
      expect(registry.byId('fake_game'), isNotNull);
    });
  });

  group('MiniGame scoring contract', () {
    test('higher-is-better games rank larger scores first', () {
      final _FakeGame game = _FakeGame();
      expect(game.beats(10, 5), isTrue);
      expect(game.beats(5, 10), isFalse);
    });
  });
}
