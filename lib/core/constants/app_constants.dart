/// Global, compile-time application constants.
///
/// Anything that is a tunable game-design value (XP curve, coin rewards, daily
/// reward table, etc.) lives here so balancing changes never require touching
/// business logic.
class AppConstants {
  const AppConstants._();

  static const String appName = 'Pocket Arcade';
  static const String appVersion = '1.0.0';

  // ---------------------------------------------------------------------------
  // Hive box names
  // ---------------------------------------------------------------------------
  static const String profileBox = 'profile_box';
  static const String statsBox = 'stats_box';
  static const String achievementsBox = 'achievements_box';
  static const String challengesBox = 'challenges_box';
  static const String dailyRewardBox = 'daily_reward_box';
  static const String settingsBox = 'settings_box';
  static const String leaderboardBox = 'leaderboard_box';

  // Single-entry keys inside boxes.
  static const String profileKey = 'player_profile';
  static const String settingsKey = 'app_settings';
  static const String dailyRewardKey = 'daily_reward_state';

  // ---------------------------------------------------------------------------
  // Progression / economy tuning
  // ---------------------------------------------------------------------------

  /// Base XP required to go from level 1 to level 2.
  static const int baseXpPerLevel = 100;

  /// Growth factor applied per level. Each level needs ~35% more XP than the
  /// previous, giving "easy early levels, increasing requirements".
  static const double xpGrowthFactor = 1.35;

  /// XP awarded simply for completing a game session.
  static const int xpPerPlay = 10;

  /// XP awarded for winning / completing a game objective.
  static const int xpPerWin = 25;

  /// XP awarded the first time a new personal high score is set.
  static const int xpPerHighScore = 40;

  /// XP awarded for the daily login.
  static const int xpPerDailyLogin = 20;

  /// Coins awarded simply for playing a game.
  static const int coinsPerPlay = 5;

  /// Coins awarded for winning.
  static const int coinsPerWin = 15;

  // ---------------------------------------------------------------------------
  // Daily rewards table (Day 1..7). Day 7 is a "special" larger reward.
  // ---------------------------------------------------------------------------
  static const List<int> dailyRewardCoins = <int>[50, 75, 100, 150, 200, 300, 500];

  /// Number of consecutive hours of inactivity after which a streak resets.
  static const int streakResetHours = 48;
}
