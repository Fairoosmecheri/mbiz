import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../data/models/daily_challenge.dart';

/// Displays a single daily challenge with progress and a claim affordance.
class ChallengeTile extends StatelessWidget {
  const ChallengeTile({
    super.key,
    required this.challenge,
    required this.onClaim,
  });

  final DailyChallenge challenge;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final bool claimable = challenge.isComplete && !challenge.claimed;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    challenge.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
                if (challenge.claimed)
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.success),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: challenge.progressFraction,
                minHeight: 8,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.primary),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('${challenge.progress} / ${challenge.target}',
                    style: Theme.of(context).textTheme.bodySmall),
                Row(
                  children: <Widget>[
                    const Icon(Icons.bolt_rounded,
                        size: 14, color: AppColors.xp),
                    Text(' ${challenge.xpReward}  ',
                        style: const TextStyle(fontSize: 12)),
                    const Icon(Icons.monetization_on_rounded,
                        size: 14, color: AppColors.coin),
                    Text(' ${challenge.coinReward}',
                        style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
            if (claimable) ...<Widget>[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onClaim,
                  child: const Text('Claim reward'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
