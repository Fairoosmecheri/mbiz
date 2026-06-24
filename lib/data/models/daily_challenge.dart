import 'package:equatable/equatable.dart';

/// The kind of progress a challenge measures.
enum ChallengeMetric {
  /// Number of game sessions played (any game, or a specific [gameId]).
  gamesPlayed,

  /// Reach a target score in a specific game.
  scoreInGame,

  /// Survive / last a number of seconds in a specific game.
  surviveSeconds,

  /// Finish a game under a time threshold (lower is better).
  completeUnderSeconds,
}

/// A single auto-generated daily challenge with its own progress and reward.
///
/// Challenges are regenerated each calendar day by `ChallengeRepository`.
class DailyChallenge extends Equatable {
  const DailyChallenge({
    required this.id,
    required this.title,
    required this.metric,
    required this.target,
    required this.gameId,
    required this.coinReward,
    required this.xpReward,
    required this.progress,
    required this.claimed,
  });

  final String id;
  final String title;
  final ChallengeMetric metric;
  final int target;

  /// Game this challenge is scoped to, or `null` for "any game".
  final String? gameId;

  final int coinReward;
  final int xpReward;

  /// Current progress toward [target].
  final int progress;

  /// Whether the reward has already been claimed.
  final bool claimed;

  bool get isComplete => progress >= target;

  double get progressFraction =>
      target == 0 ? 0 : (progress / target).clamp(0.0, 1.0);

  DailyChallenge copyWith({int? progress, bool? claimed}) => DailyChallenge(
        id: id,
        title: title,
        metric: metric,
        target: target,
        gameId: gameId,
        coinReward: coinReward,
        xpReward: xpReward,
        progress: progress ?? this.progress,
        claimed: claimed ?? this.claimed,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'metric': metric.name,
        'target': target,
        'gameId': gameId,
        'coinReward': coinReward,
        'xpReward': xpReward,
        'progress': progress,
        'claimed': claimed,
      };

  factory DailyChallenge.fromJson(Map<dynamic, dynamic> json) => DailyChallenge(
        id: json['id'] as String,
        title: json['title'] as String,
        metric: ChallengeMetric.values.firstWhere(
          (ChallengeMetric m) => m.name == json['metric'],
          orElse: () => ChallengeMetric.gamesPlayed,
        ),
        target: (json['target'] as num).toInt(),
        gameId: json['gameId'] as String?,
        coinReward: (json['coinReward'] as num).toInt(),
        xpReward: (json['xpReward'] as num).toInt(),
        progress: (json['progress'] as num?)?.toInt() ?? 0,
        claimed: json['claimed'] as bool? ?? false,
      );

  @override
  List<Object?> get props => <Object?>[
        id,
        title,
        metric,
        target,
        gameId,
        coinReward,
        xpReward,
        progress,
        claimed,
      ];
}
