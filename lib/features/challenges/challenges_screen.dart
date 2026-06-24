import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../profile/profile_notifier.dart';
import 'challenges_notifier.dart';
import 'widgets/challenge_tile.dart';

/// The Challenges tab: today's auto-generated challenges with claim buttons.
class ChallengesScreen extends ConsumerWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challenges = ref.watch(challengesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Challenges')),
      body: challenges.isEmpty
          ? const Center(child: Text('No challenges today. Check back soon!'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: challenges.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (BuildContext context, int i) {
                final c = challenges[i];
                return ChallengeTile(
                  challenge: c,
                  onClaim: () => _claim(ref, context, c.id),
                );
              },
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
                '+${claimed.coinReward} coins, +${claimed.xpReward} XP claimed!')),
      );
    }
  }
}
