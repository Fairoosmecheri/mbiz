import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_colors.dart';
import '../daily_reward_notifier.dart';

/// Home-screen card for the 7-day daily reward. Shows the streak track and a
/// claim button when a reward is available.
class DailyRewardCard extends ConsumerWidget {
  const DailyRewardCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(dailyRewardProvider); // rebuild after a claim
    final notifier = ref.read(dailyRewardProvider.notifier);
    final bool canClaim = notifier.canClaim;
    final int nextDay = notifier.nextDay;
    // Days already claimed in the current streak (0 when the streak is fresh).
    final int claimedThrough = canClaim ? nextDay - 1 : state.currentStreak;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(Icons.card_giftcard_rounded, color: AppColors.accent),
                const SizedBox(width: 8),
                Text('Daily Reward',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                for (int day = 1; day <= 7; day++)
                  _DayChip(
                    day: day,
                    coins: AppConstants.dailyRewardCoins[day - 1],
                    isNext: canClaim && day == nextDay,
                    isClaimed: day <= claimedThrough,
                    isSpecial: day == 7,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: canClaim
                    ? () async {
                        final result = await notifier.claim();
                        if (result.success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result.isSpecial
                                  ? 'Day 7 special! +${result.coins} coins 🎉'
                                  : 'Day ${result.day}: +${result.coins} coins!'),
                            ),
                          );
                        }
                      }
                    : null,
                icon: const Icon(Icons.redeem_rounded),
                label: Text(canClaim ? 'Claim Day $nextDay' : 'Claimed today'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.day,
    required this.coins,
    required this.isNext,
    required this.isClaimed,
    required this.isSpecial,
  });

  final int day;
  final int coins;
  final bool isNext;
  final bool isClaimed;
  final bool isSpecial;

  @override
  Widget build(BuildContext context) {
    final Color color = isNext
        ? AppColors.primary
        : isClaimed
            ? AppColors.success
            : Theme.of(context).colorScheme.surfaceContainerHighest;
    return Column(
      children: <Widget>[
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: isNext || isClaimed ? 1 : 0.5),
            shape: BoxShape.circle,
            border: isNext
                ? Border.all(color: AppColors.primary, width: 2)
                : null,
          ),
          alignment: Alignment.center,
          child: isClaimed
              ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
              : Icon(isSpecial ? Icons.star_rounded : Icons.circle,
                  color: Colors.white, size: isSpecial ? 18 : 8),
        ),
        const SizedBox(height: 4),
        Text('$coins',
            style: const TextStyle(fontSize: 10, color: AppColors.coin)),
      ],
    );
  }
}
