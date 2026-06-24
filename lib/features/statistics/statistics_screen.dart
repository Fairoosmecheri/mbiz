import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/providers.dart';
import '../../data/models/game_stats.dart';
import '../game_framework/mini_game.dart';
import '../profile/profile_notifier.dart';
import 'stats_notifier.dart';

/// Dedicated statistics dashboard: lifetime aggregates plus a per-game
/// breakdown that is generated from whatever games are registered.
class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<GameStats> stats = ref.watch(statsProvider);
    final profile = ref.watch(profileProvider);
    final registry = ref.watch(gameRegistryProvider);

    final int totalGames =
        stats.fold(0, (int s, GameStats g) => s + g.timesPlayed);
    final int totalSeconds =
        stats.fold(0, (int s, GameStats g) => s + g.totalPlayTimeSeconds);
    final int totalWins =
        stats.fold(0, (int s, GameStats g) => s + g.wins);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: <Widget>[
              _StatBox(
                  label: 'Games Played',
                  value: '$totalGames',
                  icon: Icons.sports_esports_rounded,
                  color: AppColors.primary),
              _StatBox(
                  label: 'Time Played',
                  value: _formatDuration(totalSeconds),
                  icon: Icons.timer_rounded,
                  color: AppColors.info),
              _StatBox(
                  label: 'Total Wins',
                  value: '$totalWins',
                  icon: Icons.emoji_events_rounded,
                  color: AppColors.success),
              _StatBox(
                  label: 'Win Rate',
                  value: '${(profile.winRate * 100).toStringAsFixed(0)}%',
                  icon: Icons.percent_rounded,
                  color: AppColors.accent),
            ],
          ),
          const SizedBox(height: 24),
          Text('Per-Game Breakdown',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          for (final MiniGame game in registry.games)
            _GameStatRow(
              game: game,
              stats: stats.firstWhere(
                (GameStats s) => s.gameId == game.id,
                orElse: () => GameStats.empty(game.id),
              ),
            ),
        ],
      ),
    );
  }

  static String _formatDuration(int seconds) {
    if (seconds < 60) return '${seconds}s';
    final int m = seconds ~/ 60;
    if (m < 60) return '${m}m';
    final int h = m ~/ 60;
    return '${h}h ${m % 60}m';
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, color: color),
            const Spacer(),
            Text(value,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            Text(label, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _GameStatRow extends StatelessWidget {
  const _GameStatRow({required this.game, required this.stats});

  final MiniGame game;
  final GameStats stats;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: game.accentColor.withValues(alpha: 0.18),
          child: Icon(game.icon, color: game.accentColor),
        ),
        title: Text(game.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          'Played ${stats.timesPlayed} • Avg ${stats.averageScore.toStringAsFixed(0)}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            const Text('Best', style: TextStyle(fontSize: 11)),
            Text(
              stats.timesPlayed == 0
                  ? '—'
                  : game.formatScore(stats.highScore),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
