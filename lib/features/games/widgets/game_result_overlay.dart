import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/di/providers.dart';
import '../../../core/services/ad_service.dart';
import '../../game_framework/mini_game.dart';
import '../../profile/profile_notifier.dart';
import '../../progression/reward_summary.dart';

/// The post-game results card: score, rewards, level-ups, unlocked
/// achievements and the rewarded-ad "double rewards" upsell.
class GameResultOverlay extends ConsumerStatefulWidget {
  const GameResultOverlay({
    super.key,
    required this.game,
    required this.summary,
    required this.onRetry,
    required this.onHome,
  });

  final MiniGame game;
  final RewardSummary summary;
  final VoidCallback onRetry;
  final VoidCallback onHome;

  @override
  ConsumerState<GameResultOverlay> createState() => _GameResultOverlayState();
}

class _GameResultOverlayState extends ConsumerState<GameResultOverlay> {
  bool _doubled = false;
  bool _working = false;

  Future<void> _doubleRewards() async {
    setState(() => _working = true);
    final RewardedAdResult result =
        await ref.read(adServiceProvider).showRewarded();
    if (!mounted) return;
    setState(() => _working = false);

    if (result == RewardedAdResult.earned ||
        result == RewardedAdResult.adsRemoved) {
      // Grant the bonus copy of the earned rewards.
      final notifier = ref.read(profileProvider.notifier);
      notifier.addCoins(widget.summary.coinsEarned);
      final current = ref.read(profileProvider);
      notifier.set(current.copyWith(xp: current.xp + widget.summary.xpEarned));
      setState(() => _doubled = true);
      _toast('Rewards doubled! 🎉');
    } else if (result == RewardedAdResult.failed) {
      _toast('No ad available right now. Try again soon.');
    }
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final RewardSummary s = widget.summary;
    final int coins = _doubled ? s.coinsEarned * 2 : s.coinsEarned;
    final int xp = _doubled ? s.xpEarned * 2 : s.xpEarned;

    return Container(
      color: Colors.black.withValues(alpha: 0.82),
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                if (s.isHighScore)
                  const _Tag(
                      icon: Icons.emoji_events_rounded,
                      label: 'New High Score!',
                      color: AppColors.coin),
                const SizedBox(height: 8),
                Text(
                  s.won ? 'Nice run!' : 'Game Over',
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  s.scoreLabel,
                  style: TextStyle(
                    fontSize: 20,
                    color: widget.game.accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _Reward(
                        icon: Icons.bolt_rounded,
                        value: '+$xp',
                        label: 'XP',
                        color: AppColors.xp),
                    const SizedBox(width: 24),
                    _Reward(
                        icon: Icons.monetization_on_rounded,
                        value: '+$coins',
                        label: 'Coins',
                        color: AppColors.coin),
                  ],
                ),
                if (s.leveledUp) ...<Widget>[
                  const SizedBox(height: 16),
                  _Tag(
                      icon: Icons.trending_up_rounded,
                      label: 'Level Up! You reached level ${s.newLevel}',
                      color: AppColors.success),
                ],
                if (s.unlockedAchievements.isNotEmpty) ...<Widget>[
                  const SizedBox(height: 12),
                  for (final a in s.unlockedAchievements)
                    _Tag(
                        icon: Icons.workspace_premium_rounded,
                        label: 'Achievement: ${a.title}',
                        color: AppColors.accent),
                ],
                const SizedBox(height: 24),
                if (!_doubled)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _working ? null : _doubleRewards,
                      icon: _working
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.play_circle_fill_rounded),
                      label: const Text('Watch ad — Double rewards'),
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.onHome,
                        child: const Text('Home'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: widget.onRetry,
                        child: const Text('Retry'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Reward extends StatelessWidget {
  const _Reward({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        Text(label,
            style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Flexible(
            child: Text(label,
                style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
