import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../data/models/achievement.dart';
import 'achievements_provider.dart';

/// The Achievements tab: a scrollable list of every achievement with its locked
/// / unlocked state and reward.
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Achievement> achievements = ref.watch(achievementsProvider);
    final summary = ref.watch(achievementSummaryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: summary.total == 0
                          ? 0
                          : summary.unlocked / summary.total,
                      minHeight: 10,
                      backgroundColor:
                          AppColors.accent.withValues(alpha: 0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.accent),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('${summary.unlocked} / ${summary.total}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: achievements.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (BuildContext context, int i) =>
                  _AchievementTile(achievements[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile(this.achievement);

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final bool unlocked = achievement.unlocked;
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: unlocked
              ? AppColors.accent.withValues(alpha: 0.2)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Icon(
            unlocked
                ? Icons.workspace_premium_rounded
                : Icons.lock_outline_rounded,
            color: unlocked ? AppColors.accent : Colors.grey,
          ),
        ),
        title: Text(achievement.title,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(achievement.description),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.monetization_on_rounded,
                    size: 14, color: AppColors.coin),
                Text(' ${achievement.coinReward}',
                    style: const TextStyle(fontSize: 12)),
              ],
            ),
            if (achievement.xpReward > 0)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(Icons.bolt_rounded, size: 14, color: AppColors.xp),
                  Text(' ${achievement.xpReward}',
                      style: const TextStyle(fontSize: 12)),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
