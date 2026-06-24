import 'package:equatable/equatable.dart';

/// Aggregated statistics for a single game, keyed by game id.
///
/// Updated every time a session finishes and surfaced on the statistics
/// dashboard and per-game cards.
class GameStats extends Equatable {
  const GameStats({
    required this.gameId,
    required this.timesPlayed,
    required this.highScore,
    required this.totalScore,
    required this.totalPlayTimeSeconds,
    required this.wins,
    required this.lastPlayedEpoch,
  });

  final String gameId;
  final int timesPlayed;
  final int highScore;
  final int totalScore;
  final int totalPlayTimeSeconds;
  final int wins;

  /// Milliseconds-since-epoch of the most recent session, for "recently played"
  /// ordering. 0 means never played.
  final int lastPlayedEpoch;

  double get averageScore => timesPlayed == 0 ? 0 : totalScore / timesPlayed;

  double get winRate => timesPlayed == 0 ? 0 : wins / timesPlayed;

  factory GameStats.empty(String gameId) => GameStats(
        gameId: gameId,
        timesPlayed: 0,
        highScore: 0,
        totalScore: 0,
        totalPlayTimeSeconds: 0,
        wins: 0,
        lastPlayedEpoch: 0,
      );

  GameStats copyWith({
    int? timesPlayed,
    int? highScore,
    int? totalScore,
    int? totalPlayTimeSeconds,
    int? wins,
    int? lastPlayedEpoch,
  }) {
    return GameStats(
      gameId: gameId,
      timesPlayed: timesPlayed ?? this.timesPlayed,
      highScore: highScore ?? this.highScore,
      totalScore: totalScore ?? this.totalScore,
      totalPlayTimeSeconds: totalPlayTimeSeconds ?? this.totalPlayTimeSeconds,
      wins: wins ?? this.wins,
      lastPlayedEpoch: lastPlayedEpoch ?? this.lastPlayedEpoch,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'gameId': gameId,
        'timesPlayed': timesPlayed,
        'highScore': highScore,
        'totalScore': totalScore,
        'totalPlayTimeSeconds': totalPlayTimeSeconds,
        'wins': wins,
        'lastPlayedEpoch': lastPlayedEpoch,
      };

  factory GameStats.fromJson(Map<dynamic, dynamic> json) => GameStats(
        gameId: json['gameId'] as String,
        timesPlayed: (json['timesPlayed'] as num?)?.toInt() ?? 0,
        highScore: (json['highScore'] as num?)?.toInt() ?? 0,
        totalScore: (json['totalScore'] as num?)?.toInt() ?? 0,
        totalPlayTimeSeconds:
            (json['totalPlayTimeSeconds'] as num?)?.toInt() ?? 0,
        wins: (json['wins'] as num?)?.toInt() ?? 0,
        lastPlayedEpoch: (json['lastPlayedEpoch'] as num?)?.toInt() ?? 0,
      );

  @override
  List<Object?> get props => <Object?>[
        gameId,
        timesPlayed,
        highScore,
        totalScore,
        totalPlayTimeSeconds,
        wins,
        lastPlayedEpoch,
      ];
}
