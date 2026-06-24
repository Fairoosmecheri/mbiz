import 'package:flutter/material.dart';

import '../../game_framework/game_difficulty.dart';
import '../../game_framework/mini_game.dart';

/// Tappable card representing a game in the grid.
///
/// Driven entirely by the [MiniGame] contract, so every registered game — now
/// or in future — renders here automatically with its own icon, accent colour,
/// difficulty and high score.
class GameCard extends StatelessWidget {
  const GameCard({
    super.key,
    required this.game,
    required this.highScore,
    required this.onTap,
  });

  final MiniGame game;
  final int highScore;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              game.accentColor.withValues(alpha: 0.85),
              game.accentColor.withValues(alpha: 0.55),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Icon(game.icon, color: Colors.white, size: 34),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    game.difficulty.label,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              game.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: <Widget>[
                const Icon(Icons.emoji_events_rounded,
                    color: Colors.white70, size: 15),
                const SizedBox(width: 4),
                Text(
                  highScore == 0 ? 'No score yet' : game.formatScore(highScore),
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
