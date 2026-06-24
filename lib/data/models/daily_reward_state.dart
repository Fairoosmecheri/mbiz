import 'package:equatable/equatable.dart';

/// Persistent state backing the 7-day daily-reward streak.
class DailyRewardState extends Equatable {
  const DailyRewardState({
    required this.currentStreak,
    required this.lastClaimedIso,
  });

  /// 0 when nothing has been claimed yet, otherwise 1..7 (wraps back to 1).
  final int currentStreak;

  /// ISO-8601 timestamp of the last successful claim, or `null`.
  final String? lastClaimedIso;

  DateTime? get lastClaimed =>
      lastClaimedIso == null ? null : DateTime.tryParse(lastClaimedIso!);

  factory DailyRewardState.initial() =>
      const DailyRewardState(currentStreak: 0, lastClaimedIso: null);

  DailyRewardState copyWith({int? currentStreak, String? lastClaimedIso}) =>
      DailyRewardState(
        currentStreak: currentStreak ?? this.currentStreak,
        lastClaimedIso: lastClaimedIso ?? this.lastClaimedIso,
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'currentStreak': currentStreak,
        'lastClaimedIso': lastClaimedIso,
      };

  factory DailyRewardState.fromJson(Map<dynamic, dynamic> json) =>
      DailyRewardState(
        currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
        lastClaimedIso: json['lastClaimedIso'] as String?,
      );

  @override
  List<Object?> get props => <Object?>[currentStreak, lastClaimedIso];
}
