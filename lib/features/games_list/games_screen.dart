import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/providers.dart';
import '../../shared/widgets/banner_ad_widget.dart';
import '../game_framework/mini_game.dart';
import '../profile/profile_notifier.dart';
import 'widgets/game_card.dart';

/// The Games tab: a responsive grid of every registered game.
class GamesScreen extends ConsumerWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<MiniGame> games = ref.watch(gameRegistryProvider).games;
    final highScores = ref.watch(profileProvider).highScores;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Games'),
        actions: <Widget>[
          if (games.isNotEmpty)
            IconButton(
              tooltip: 'Leaderboards',
              icon: const Icon(Icons.leaderboard_rounded),
              onPressed: () => context.push('/leaderboard/${games.first.id}'),
            ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.95,
              ),
              itemCount: games.length,
              itemBuilder: (BuildContext context, int i) {
                final MiniGame game = games[i];
                return GameCard(
                  game: game,
                  highScore: highScores[game.id] ?? 0,
                  onTap: () => context.push('/game/${game.id}'),
                );
              },
            ),
          ),
          const SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: BannerAdWidget(),
            ),
          ),
        ],
      ),
    );
  }
}
