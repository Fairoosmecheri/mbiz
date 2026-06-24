import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/providers.dart';
import '../game_framework/game_result.dart';
import '../game_framework/mini_game.dart';
import '../profile/profile_notifier.dart';
import '../progression/progression_service.dart';
import '../progression/reward_summary.dart';
import 'widgets/game_result_overlay.dart';

/// Full-screen host for a single [MiniGame].
///
/// It is game-agnostic: it resolves the game from the [GameRegistry] by id,
/// hands it a [GameController], and on completion routes the result through the
/// [ProgressionService] and shows the reward overlay. No per-game code lives
/// here, which is what lets new games slot in with zero host changes.
class GameHostPage extends ConsumerStatefulWidget {
  const GameHostPage({super.key, required this.gameId});

  final String gameId;

  @override
  ConsumerState<GameHostPage> createState() => _GameHostPageState();
}

class _GameHostPageState extends ConsumerState<GameHostPage> {
  RewardSummary? _summary;
  int _attempt = 0;
  late GameController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GameController(onResult: _onResult);
  }

  void _onResult(GameResult result) {
    final MiniGame? game = ref.read(gameRegistryProvider).byId(widget.gameId);
    if (game == null) return;
    final RewardSummary summary =
        ref.read(progressionServiceProvider).processGameResult(result, game);
    setState(() => _summary = summary);
  }

  void _retry() {
    setState(() {
      _summary = null;
      _attempt++;
      _controller = GameController(onResult: _onResult);
    });
  }

  @override
  Widget build(BuildContext context) {
    final MiniGame? game = ref.watch(gameRegistryProvider).byId(widget.gameId);
    if (game == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Game not found')),
      );
    }

    final int highScore =
        ref.watch(profileProvider).highScores[game.id] ?? 0;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            // The game fills the available space below a slim header.
            Column(
              children: <Widget>[
                _Header(
                  game: game,
                  highScore: highScore,
                  onClose: () => context.pop(),
                ),
                Expanded(
                  child: KeyedSubtree(
                    key: ValueKey<int>(_attempt),
                    child: game.build(context, _controller),
                  ),
                ),
              ],
            ),
            if (_summary != null)
              GameResultOverlay(
                game: game,
                summary: _summary!,
                onRetry: _retry,
                onHome: () => context.pop(),
              ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.game,
    required this.highScore,
    required this.onClose,
  });

  final MiniGame game;
  final int highScore;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: onClose,
          ),
          Expanded(
            child: Text(
              game.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.emoji_events_rounded,
                    color: Colors.amber, size: 18),
                const SizedBox(width: 4),
                Text(
                  highScore == 0 ? '—' : game.formatScore(highScore),
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
