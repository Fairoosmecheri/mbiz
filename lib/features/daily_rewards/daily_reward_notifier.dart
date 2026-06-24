import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../data/models/daily_reward_state.dart';
import '../../data/repositories/daily_reward_repository.dart';
import '../profile/profile_notifier.dart';

final dailyRewardProvider =
    NotifierProvider<DailyRewardNotifier, DailyRewardState>(
        DailyRewardNotifier.new);

/// Drives the 7-day daily-reward UI and grants the coins on a successful claim.
class DailyRewardNotifier extends Notifier<DailyRewardState> {
  @override
  DailyRewardState build() => ref.read(dailyRewardRepositoryProvider).load();

  bool get canClaim => ref.read(dailyRewardRepositoryProvider).canClaim();

  int get nextDay => ref.read(dailyRewardRepositoryProvider).nextDay();

  /// Claims today's reward, credits coins to the profile, and refreshes state.
  Future<DailyClaimResult> claim() async {
    final DailyClaimResult result =
        await ref.read(dailyRewardRepositoryProvider).claim();
    if (result.success) {
      ref.read(profileProvider.notifier).addCoins(result.coins);
      state = result.state;
    }
    return result;
  }
}
