import 'package:equatable/equatable.dart';

import '../../core/utils/xp_calculator.dart';

/// The single source of truth for a player's persistent identity and economy.
///
/// Persisted as JSON inside a Hive box (see `StorageService`), which keeps the
/// model free of generated Hive adapters and trivially serialisable for a
/// future Firebase sync layer.
class PlayerProfile extends Equatable {
  const PlayerProfile({
    required this.username,
    required this.avatarId,
    required this.coins,
    required this.xp,
    required this.gamesPlayed,
    required this.wins,
    required this.highScores,
    required this.unlockedAchievements,
    required this.ownedAvatars,
    required this.ownedThemes,
    required this.adsRemoved,
    required this.lifetimeCoinsEarned,
    required this.highScoresBeaten,
  });

  final String username;
  final String avatarId;
  final int coins;
  final int xp;
  final int gamesPlayed;
  final int wins;

  /// Highest score per game id, e.g. `{'speed_tap': 84}`.
  final Map<String, int> highScores;

  /// Ids of achievements the player has unlocked.
  final Set<String> unlockedAchievements;

  /// Cosmetic ids purchased from the shop.
  final Set<String> ownedAvatars;
  final Set<String> ownedThemes;

  /// Whether the one-time "Remove Ads" upgrade has been purchased.
  final bool adsRemoved;

  /// Running total of all coins ever earned (never decreases on spend). Drives
  /// the "Coin Collector" achievement family.
  final int lifetimeCoinsEarned;

  /// How many times the player has set a new personal high score. Drives the
  /// "Record Breaker" achievement.
  final int highScoresBeaten;

  /// Current level derived from total XP (never stored directly so the two can
  /// never drift out of sync).
  int get level => XpCalculator.levelForXp(xp);

  /// XP accumulated within the current level.
  int get xpIntoLevel => XpCalculator.xpIntoLevel(xp);

  /// Total XP required to advance from the current level to the next.
  int get xpForNextLevel => XpCalculator.xpForLevel(level + 1);

  /// 0.0 – 1.0 progress towards the next level, for the XP bar.
  double get levelProgress => XpCalculator.levelProgress(xp);

  /// Win rate as a fraction (0.0 – 1.0).
  double get winRate => gamesPlayed == 0 ? 0 : wins / gamesPlayed;

  factory PlayerProfile.initial({String username = 'Player'}) {
    return PlayerProfile(
      username: username,
      avatarId: 'avatar_01',
      coins: 100,
      xp: 0,
      gamesPlayed: 0,
      wins: 0,
      highScores: const <String, int>{},
      unlockedAchievements: const <String>{},
      ownedAvatars: const <String>{'avatar_01'},
      ownedThemes: const <String>{'default'},
      adsRemoved: false,
      lifetimeCoinsEarned: 100,
      highScoresBeaten: 0,
    );
  }

  PlayerProfile copyWith({
    String? username,
    String? avatarId,
    int? coins,
    int? xp,
    int? gamesPlayed,
    int? wins,
    Map<String, int>? highScores,
    Set<String>? unlockedAchievements,
    Set<String>? ownedAvatars,
    Set<String>? ownedThemes,
    bool? adsRemoved,
    int? lifetimeCoinsEarned,
    int? highScoresBeaten,
  }) {
    return PlayerProfile(
      username: username ?? this.username,
      avatarId: avatarId ?? this.avatarId,
      coins: coins ?? this.coins,
      xp: xp ?? this.xp,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      wins: wins ?? this.wins,
      highScores: highScores ?? this.highScores,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      ownedAvatars: ownedAvatars ?? this.ownedAvatars,
      ownedThemes: ownedThemes ?? this.ownedThemes,
      adsRemoved: adsRemoved ?? this.adsRemoved,
      lifetimeCoinsEarned: lifetimeCoinsEarned ?? this.lifetimeCoinsEarned,
      highScoresBeaten: highScoresBeaten ?? this.highScoresBeaten,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'username': username,
        'avatarId': avatarId,
        'coins': coins,
        'xp': xp,
        'gamesPlayed': gamesPlayed,
        'wins': wins,
        'highScores': highScores,
        'unlockedAchievements': unlockedAchievements.toList(),
        'ownedAvatars': ownedAvatars.toList(),
        'ownedThemes': ownedThemes.toList(),
        'adsRemoved': adsRemoved,
        'lifetimeCoinsEarned': lifetimeCoinsEarned,
        'highScoresBeaten': highScoresBeaten,
      };

  factory PlayerProfile.fromJson(Map<dynamic, dynamic> json) {
    return PlayerProfile(
      username: json['username'] as String? ?? 'Player',
      avatarId: json['avatarId'] as String? ?? 'avatar_01',
      coins: (json['coins'] as num?)?.toInt() ?? 0,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      gamesPlayed: (json['gamesPlayed'] as num?)?.toInt() ?? 0,
      wins: (json['wins'] as num?)?.toInt() ?? 0,
      highScores: <String, int>{
        for (final MapEntry<dynamic, dynamic> e
            in (json['highScores'] as Map?)?.entries ?? const <MapEntry>[])
          e.key as String: (e.value as num).toInt(),
      },
      unlockedAchievements: <String>{
        ...?(json['unlockedAchievements'] as List?)?.map((e) => e as String),
      },
      ownedAvatars: <String>{
        ...?(json['ownedAvatars'] as List?)?.map((e) => e as String),
        'avatar_01',
      },
      ownedThemes: <String>{
        ...?(json['ownedThemes'] as List?)?.map((e) => e as String),
        'default',
      },
      adsRemoved: json['adsRemoved'] as bool? ?? false,
      lifetimeCoinsEarned: (json['lifetimeCoinsEarned'] as num?)?.toInt() ?? 0,
      highScoresBeaten: (json['highScoresBeaten'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        username,
        avatarId,
        coins,
        xp,
        gamesPlayed,
        wins,
        highScores,
        unlockedAchievements,
        ownedAvatars,
        ownedThemes,
        adsRemoved,
        lifetimeCoinsEarned,
        highScoresBeaten,
      ];
}
