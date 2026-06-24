import 'dart:math' as math;

import '../constants/app_constants.dart';

/// Pure functions describing the level / XP curve.
///
/// Kept side-effect free and dependency-light so it can be unit tested in
/// isolation and reused by both the model layer and the UI.
class XpCalculator {
  const XpCalculator._();

  /// XP required to advance *from* `level` to `level + 1`.
  ///
  /// Level 1 -> 2 costs [AppConstants.baseXpPerLevel]; each subsequent level
  /// scales by [AppConstants.xpGrowthFactor].
  static int xpForLevel(int level) {
    if (level <= 1) return AppConstants.baseXpPerLevel;
    final double cost = AppConstants.baseXpPerLevel *
        math.pow(AppConstants.xpGrowthFactor, level - 1);
    return cost.round();
  }

  /// Total cumulative XP needed to *reach* the start of `level`.
  static int cumulativeXpForLevel(int level) {
    int total = 0;
    for (int l = 1; l < level; l++) {
      total += xpForLevel(l);
    }
    return total;
  }

  /// The level a player with `totalXp` is currently at (levels start at 1).
  static int levelForXp(int totalXp) {
    int level = 1;
    int remaining = totalXp;
    while (remaining >= xpForLevel(level)) {
      remaining -= xpForLevel(level);
      level++;
    }
    return level;
  }

  /// XP accumulated within the current level (i.e. progress toward the next).
  static int xpIntoLevel(int totalXp) {
    final int level = levelForXp(totalXp);
    return totalXp - cumulativeXpForLevel(level);
  }

  /// Fractional progress (0.0 – 1.0) toward the next level.
  static double levelProgress(int totalXp) {
    final int level = levelForXp(totalXp);
    final int into = xpIntoLevel(totalXp);
    final int needed = xpForLevel(level);
    if (needed == 0) return 0;
    return (into / needed).clamp(0.0, 1.0);
  }
}
