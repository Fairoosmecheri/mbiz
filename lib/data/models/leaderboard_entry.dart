import 'package:equatable/equatable.dart';

/// Scope a leaderboard query can target. The UI exposes all three; the mock
/// backend returns plausible data for each.
enum LeaderboardScope { global, friends, weekly }

/// A single row in a leaderboard.
///
/// Field shapes mirror a Firestore document so the mock repository can be
/// swapped for a real `cloud_firestore` implementation without UI changes.
class LeaderboardEntry extends Equatable {
  const LeaderboardEntry({
    required this.playerId,
    required this.username,
    required this.avatarId,
    required this.score,
    required this.rank,
    required this.isCurrentPlayer,
  });

  final String playerId;
  final String username;
  final String avatarId;
  final int score;
  final int rank;
  final bool isCurrentPlayer;

  LeaderboardEntry copyWith({int? rank, bool? isCurrentPlayer}) =>
      LeaderboardEntry(
        playerId: playerId,
        username: username,
        avatarId: avatarId,
        score: score,
        rank: rank ?? this.rank,
        isCurrentPlayer: isCurrentPlayer ?? this.isCurrentPlayer,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'playerId': playerId,
        'username': username,
        'avatarId': avatarId,
        'score': score,
      };

  factory LeaderboardEntry.fromJson(Map<dynamic, dynamic> json, int rank) =>
      LeaderboardEntry(
        playerId: json['playerId'] as String,
        username: json['username'] as String,
        avatarId: json['avatarId'] as String? ?? 'avatar_01',
        score: (json['score'] as num).toInt(),
        rank: rank,
        isCurrentPlayer: false,
      );

  @override
  List<Object?> get props =>
      <Object?>[playerId, username, avatarId, score, rank, isCurrentPlayer];
}
