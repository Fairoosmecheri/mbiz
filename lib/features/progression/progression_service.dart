import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/di/providers.dart';
import '../../data/models/achievement.dart';
import '../../data/models/player_profile.dart';
import '../../features/game_framework/game_result.dart';
import '../../features/game_framework/mini_game.dart';
import '../achievements/achievements_provider.dart';
import '../challenges/challenges_notifier.dart';
import '../daily_rewards/daily_reward_notifier.dart';
import '../profile/profile_notifier.dart';
import '../statistics/stats_notifier.dart';
import 'reward_summary.dart';

final progressionServiceProvider = Provider<ProgressionService>((ref) {
  return ProgressionService(ref);
});

/// The single place that converts a [GameResult] into XP, coins, stat updates,
/// challenge progress, achievement unlocks and a leaderboard submission.
///
/// Centralising this keeps individual games dumb (they only report a result)
/// and guarantees every reward rule is applied consistently, no matter which
/// game — present or future — produced the result.
class ProgressionService {
  ProgressionService(this._ref);

  final Ref _ref;

  /// Process a finished session end-to-end and return a [RewardSummary].
  RewardSummary processGameResult(GameResult result, MiniGame game) {
    // 1. Statistics + high-score detection.
    final bool isHighScore = _ref
        .read(statsProvider.notifier)
        .record(result, game.higherIsBetter)
        .isHighScore;

    // 2. Compute rewards.
    int xp = AppConstants.xpPerPlay;
    int coins = AppConstants.coinsPerPlay;
    if (result.won) {
      xp += AppConstants.xpPerWin;
      coins += AppConstants.coinsPerWin;
    }
    if (isHighScore) {
      xp += AppConstants.xpPerHighScore;
    }

    // 3. Compose the new profile in one atomic update.
    final PlayerProfile before = _ref.read(profileProvider);
    final int previousLevel = before.level;

    final Map<String, int> newHighScores =
        Map<String, int>.of(before.highScores);
    if (isHighScore) {
      newHighScores[result.gameId] = result.score;
    }

    final PlayerProfile after = before.copyWith(
      gamesPlayed: before.gamesPlayed + 1,
      wins: before.wins + (result.won ? 1 : 0),
      xp: before.xp + xp,
      coins: before.coins + coins,
      lifetimeCoinsEarned: before.lifetimeCoinsEarned + coins,
      highScores: newHighScores,
      highScoresBeaten:
          before.highScoresBeaten + (isHighScore ? 1 : 0),
    );
    _ref.read(profileProvider.notifier).set(after);

    // 4. Challenge progress.
    _ref.read(challengesProvider.notifier).applyResult(result);

    // 5. Achievement evaluation (may itself grant coins/XP).
    final List<Achievement> unlocked = _evaluateAchievements();

    // 6. Leaderboard submission (fire and forget; backend is mocked).
    _ref.read(leaderboardRepositoryProvider).submitScore(
          gameId: result.gameId,
          profile: _ref.read(profileProvider),
          score: result.score,
        );

    final PlayerProfile finalProfile = _ref.read(profileProvider);

    return RewardSummary(
      gameId: result.gameId,
      score: result.score,
      scoreLabel: game.formatScore(result.score),
      won: result.won,
      isHighScore: isHighScore,
      xpEarned: xp,
      coinsEarned: coins,
      previousLevel: previousLevel,
      newLevel: finalProfile.level,
      unlockedAchievements: unlocked,
    );
  }

  static const String _lastLoginKey = 'last_login_day';

  /// Award the daily-login bonus the first time the app is opened on a given
  /// calendar day. Returns the XP granted (0 if already granted today). Called
  /// once on app start.
  int grantDailyLoginIfDue() {
    final box = _ref.read(storageServiceProvider).settingsBox;
    final DateTime now = DateTime.now();
    final String today = '${now.year}-${now.month}-${now.day}';
    if (box.get(_lastLoginKey) == today) return 0;
    box.put(_lastLoginKey, today);

    final PlayerProfile before = _ref.read(profileProvider);
    _ref.read(profileProvider.notifier).set(
          before.copyWith(xp: before.xp + AppConstants.xpPerDailyLogin),
        );
    _evaluateAchievements();
    return AppConstants.xpPerDailyLogin;
  }

  /// Evaluate achievements against current state, persist unlocks and grant
  /// their rewards. Returns the list of newly-unlocked achievements.
  List<Achievement> _evaluateAchievements() {
    final repo = _ref.read(achievementRepositoryProvider);
    final int loginStreak = _ref.read(dailyRewardProvider).currentStreak;

    // Loop because granting one achievement's coins/XP can satisfy another.
    final List<Achievement> allUnlocked = <Achievement>[];
    while (true) {
      final PlayerProfile profile = _ref.read(profileProvider);
      final List<Achievement> batch = repo.evaluate(
        profile,
        lifetimeCoinsEarned: profile.lifetimeCoinsEarned,
        highScoresBeaten: profile.highScoresBeaten,
        loginStreak: loginStreak,
      );
      if (batch.isEmpty) break;

      PlayerProfile updated = profile;
      for (final Achievement a in batch) {
        updated = updated.copyWith(
          unlockedAchievements: <String>{
            ...updated.unlockedAchievements,
            a.id,
          },
          coins: updated.coins + a.coinReward,
          lifetimeCoinsEarned: updated.lifetimeCoinsEarned + a.coinReward,
          xp: updated.xp + a.xpReward,
        );
      }
      _ref.read(profileProvider.notifier).set(updated);
      allUnlocked.addAll(batch);
    }

    // Refresh the derived achievements provider consumers.
    _ref.invalidate(achievementsProvider);
    return allUnlocked;
  }
}
