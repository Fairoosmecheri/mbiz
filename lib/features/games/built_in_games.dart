import '../game_framework/game_registry.dart';
import '../game_framework/mini_game.dart';
import 'ball_dodge/ball_dodge_game.dart';
import 'memory_match/memory_match_game.dart';
import 'reaction_test/reaction_test_game.dart';
import 'speed_tap/speed_tap_game.dart';
import 'stack_tower/stack_tower_game.dart';

/// Registers every game that ships with the app.
///
/// This is the *single* line that grows when a new game is added. The new game
/// then appears automatically across the games grid, statistics, challenges,
/// achievements and leaderboards because every one of those systems iterates
/// the [GameRegistry] rather than a hard-coded list.
void registerBuiltInGames(GameRegistry registry) {
  registry.registerAll(<MiniGame>[
    ReactionTestGame(),
    SpeedTapGame(),
    StackTowerGame(),
    BallDodgeGame(),
    MemoryMatchGame(),
  ]);
}
