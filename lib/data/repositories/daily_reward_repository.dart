import '../../core/constants/app_constants.dart';
import '../../core/services/storage_service.dart';
import '../models/daily_reward_state.dart';

/// Outcome of attempting to claim the daily reward.
class DailyClaimResult {
  const DailyClaimResult({
    required this.success,
    required this.coins,
    required this.day,
    required this.isSpecial,
    required this.state,
  });

  final bool success;
  final int coins;
  final int day; // 1..7
  final bool isSpecial;
  final DailyRewardState state;
}

/// Owns the 7-day daily-reward streak logic and persistence.
class DailyRewardRepository {
  DailyRewardRepository(this._storage);

  final StorageService _storage;

  DailyRewardState load() {
    final dynamic raw = _storage.dailyRewardBox.get(AppConstants.dailyRewardKey);
    if (raw is Map) return DailyRewardState.fromJson(raw);
    return DailyRewardState.initial();
  }

  Future<void> _save(DailyRewardState state) => _storage.dailyRewardBox
      .put(AppConstants.dailyRewardKey, state.toJson());

  /// Whether a reward is available to claim right now (different calendar day
  /// from the last claim).
  bool canClaim() {
    final DateTime? last = load().lastClaimed;
    if (last == null) return true;
    return !_isSameDay(last, DateTime.now());
  }

  /// The day (1..7) the next claim will land on, for previewing the reward.
  int nextDay() {
    final DailyRewardState state = load();
    final DateTime? last = state.lastClaimed;
    if (last == null) return 1;
    final bool streakBroken = DateTime.now().difference(last).inHours >
        AppConstants.streakResetHours;
    if (streakBroken) return 1;
    return (state.currentStreak % 7) + 1;
  }

  /// Attempts to claim today's reward. Idempotent within a calendar day.
  Future<DailyClaimResult> claim() async {
    final DailyRewardState state = load();
    if (!canClaim()) {
      return DailyClaimResult(
        success: false,
        coins: 0,
        day: state.currentStreak == 0 ? 1 : state.currentStreak,
        isSpecial: false,
        state: state,
      );
    }

    final int day = nextDay();
    final int coins = AppConstants.dailyRewardCoins[day - 1];
    final DailyRewardState updated = DailyRewardState(
      currentStreak: day,
      lastClaimedIso: DateTime.now().toIso8601String(),
    );
    await _save(updated);

    return DailyClaimResult(
      success: true,
      coins: coins,
      day: day,
      isSpecial: day == 7,
      state: updated,
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
