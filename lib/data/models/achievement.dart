import 'package:equatable/equatable.dart';

/// The measurable quantity an achievement is evaluated against.
///
/// Adding a new condition type here is the only change required to support a
/// brand new family of achievements — the evaluation switch lives in
/// `AchievementRepository`.
enum AchievementType {
  gamesPlayed,
  level,
  coinsEarned,
  highScoreBeaten,
  loginStreak,
  winsTotal,
}

/// A data-driven achievement definition + unlock state.
///
/// Definitions are declared once in `AchievementCatalog`; whether a given
/// player has unlocked one is tracked on [PlayerProfile.unlockedAchievements].
class Achievement extends Equatable {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.threshold,
    required this.coinReward,
    required this.xpReward,
    this.unlocked = false,
  });

  final String id;
  final String title;
  final String description;
  final AchievementType type;

  /// The value the tracked quantity must reach to unlock this achievement.
  final int threshold;

  final int coinReward;
  final int xpReward;

  /// Runtime-only flag describing whether the current player has unlocked it.
  final bool unlocked;

  Achievement copyWith({bool? unlocked}) => Achievement(
        id: id,
        title: title,
        description: description,
        type: type,
        threshold: threshold,
        coinReward: coinReward,
        xpReward: xpReward,
        unlocked: unlocked ?? this.unlocked,
      );

  @override
  List<Object?> get props => <Object?>[
        id,
        title,
        description,
        type,
        threshold,
        coinReward,
        xpReward,
        unlocked,
      ];
}
