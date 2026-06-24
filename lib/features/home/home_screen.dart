import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/providers.dart';
import '../../data/models/game_stats.dart';
import '../../shared/widgets/avatar_view.dart';
import '../../shared/widgets/banner_ad_widget.dart';
import '../../shared/widgets/coin_badge.dart';
import '../../shared/widgets/section_header.dart';
import '../challenges/challenges_notifier.dart';
import '../challenges/widgets/challenge_tile.dart';
import '../daily_rewards/widgets/daily_reward_card.dart';
import '../game_framework/mini_game.dart';
import '../games_list/widgets/game_card.dart';
import '../profile/profile_notifier.dart';
import '../statistics/stats_notifier.dart';

/// The Home dashboard: identity + level, coins, daily reward, daily challenges,
/// recently played games and the big Quick Play button.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final List<MiniGame> games = ref.watch(gameRegistryProvider).games;
    final List<GameStats> stats = ref.watch(statsProvider);
    final challenges = ref.watch(challengesProvider);

    // Recently played: games with a session, newest first.
    final List<GameStats> recent = stats
        .where((GameStats s) => s.lastPlayedEpoch > 0)
        .toList()
      ..sort((a, b) => b.lastPlayedEpoch.compareTo(a.lastPlayedEpoch));

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: <Widget>[
                    AvatarView(avatarId: profile.avatarId, size: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text('Welcome back,',
                              style: Theme.of(context).textTheme.bodySmall),
                          Text(profile.username,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                    CoinBadge(
                        coins: profile.coins,
                        onTap: () => context.push('/shop')),
                    IconButton(
                      icon: const Icon(Icons.settings_rounded),
                      onPressed: () => context.push('/settings'),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate(<Widget>[
                  _LevelCard(
                    level: profile.level,
                    xpIntoLevel: profile.xpIntoLevel,
                    xpForNext: profile.xpForNextLevel,
                    progress: profile.levelProgress,
                  ),
                  const SizedBox(height: 16),
                  _QuickPlayButton(
                    onTap: () {
                      if (games.isNotEmpty) {
                        final MiniGame g = (recent.isNotEmpty
                                ? ref
                                    .read(gameRegistryProvider)
                                    .byId(recent.first.gameId)
                                : null) ??
                            games.first;
                        context.push('/game/${g.id}');
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                  const DailyRewardCard(),
                  const SizedBox(height: 24),
                  if (challenges.isNotEmpty) ...<Widget>[
                    const SectionHeader(title: 'Daily Challenges'),
                    ChallengeTile(
                      challenge: challenges.first,
                      onClaim: () => _claim(ref, context, challenges.first.id),
                    ),
                    const SizedBox(height: 24),
                  ],
                  SectionHeader(
                    title:
                        recent.isEmpty ? 'Featured Games' : 'Recently Played',
                  ),
                  SizedBox(
                    height: 150,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount:
                          recent.isEmpty ? games.length : recent.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (BuildContext context, int i) {
                        final MiniGame? game = recent.isEmpty
                            ? games[i]
                            : ref
                                .read(gameRegistryProvider)
                                .byId(recent[i].gameId);
                        if (game == null) return const SizedBox.shrink();
                        return SizedBox(
                          width: 150,
                          child: GameCard(
                            game: game,
                            highScore: profile.highScores[game.id] ?? 0,
                            onTap: () => context.push('/game/${game.id}'),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Center(child: BannerAdWidget()),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _claim(WidgetRef ref, BuildContext context, String id) {
    final claimed = ref.read(challengesProvider.notifier).claim(id);
    if (claimed != null) {
      ref.read(profileProvider.notifier).addCoins(claimed.coinReward);
      final p = ref.read(profileProvider);
      ref
          .read(profileProvider.notifier)
          .set(p.copyWith(xp: p.xp + claimed.xpReward));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Challenge complete! +${claimed.coinReward} coins, +${claimed.xpReward} XP')),
      );
    }
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.level,
    required this.xpIntoLevel,
    required this.xpForNext,
    required this.progress,
  });

  final int level;
  final int xpIntoLevel;
  final int xpForNext;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: AppColors.heroGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: XpBarLight(
        level: level,
        xpIntoLevel: xpIntoLevel,
        xpForNextLevel: xpForNext,
        progress: progress,
      ),
    );
  }
}

/// A white-on-gradient variant of [XpBar] for the hero card.
class XpBarLight extends StatelessWidget {
  const XpBarLight({
    super.key,
    required this.level,
    required this.xpIntoLevel,
    required this.xpForNextLevel,
    required this.progress,
  });

  final int level;
  final int xpIntoLevel;
  final int xpForNextLevel;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text('Level $level',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            Text('$xpIntoLevel / $xpForNextLevel XP',
                style: const TextStyle(color: Colors.white70)),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 12,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ],
    );
  }
}

class _QuickPlayButton extends StatelessWidget {
  const _QuickPlayButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
        icon: const Icon(Icons.play_arrow_rounded, size: 28),
        label: const Text('Quick Play',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
