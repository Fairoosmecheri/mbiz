import 'dart:async';

import '../../data/models/leaderboard_entry.dart';
import '../../data/models/player_profile.dart';

/// Abstraction over the (future) Firebase backend.
///
/// The app talks to this interface only, so swapping the mock for a real
/// `cloud_firestore` + `firebase_auth` implementation is a one-file change with
/// zero impact on the UI or domain layers. Method shapes intentionally mirror
/// Firestore operations (submit a score, page a collection, sync a document).
abstract class FirebaseService {
  /// Whether a real backend is connected. The mock reports `false` so the UI
  /// can show "offline / demo data" affordances where appropriate.
  bool get isConnected;

  /// Push the local profile to the remote `users/{uid}` document.
  Future<void> syncProfile(PlayerProfile profile);

  /// Submit a score for a game's leaderboard collection.
  Future<void> submitScore({
    required String gameId,
    required String username,
    required String avatarId,
    required int score,
  });

  /// Fetch a leaderboard page for the given game and scope.
  Future<List<LeaderboardEntry>> fetchLeaderboard({
    required String gameId,
    required LeaderboardScope scope,
    int limit = 50,
  });
}

/// An in-memory, deterministic mock used until Firebase credentials are wired
/// up. It fabricates believable rival scores so the leaderboard UI is fully
/// functional offline.
class MockFirebaseService implements FirebaseService {
  final Map<String, List<LeaderboardEntry>> _byGame =
      <String, List<LeaderboardEntry>>{};

  @override
  bool get isConnected => false;

  @override
  Future<void> syncProfile(PlayerProfile profile) async {
    // No-op for the mock; a real implementation would write to Firestore.
  }

  @override
  Future<void> submitScore({
    required String gameId,
    required String username,
    required String avatarId,
    required int score,
  }) async {
    final List<LeaderboardEntry> list =
        _byGame.putIfAbsent(gameId, () => _seed(gameId));
    list.add(
      LeaderboardEntry(
        playerId: 'me',
        username: username,
        avatarId: avatarId,
        score: score,
        rank: 0,
        isCurrentPlayer: true,
      ),
    );
  }

  @override
  Future<List<LeaderboardEntry>> fetchLeaderboard({
    required String gameId,
    required LeaderboardScope scope,
    int limit = 50,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final List<LeaderboardEntry> base =
        List<LeaderboardEntry>.of(_byGame.putIfAbsent(gameId, () => _seed(gameId)));

    // Weekly trims the pool to simulate a shorter window; friends shows a few.
    List<LeaderboardEntry> scoped;
    switch (scope) {
      case LeaderboardScope.global:
        scoped = base;
        break;
      case LeaderboardScope.weekly:
        scoped = base.take(20).toList();
        break;
      case LeaderboardScope.friends:
        scoped = base.where((LeaderboardEntry e) =>
            e.isCurrentPlayer || e.playerId.hashCode.isEven).toList();
        break;
    }

    scoped.sort((LeaderboardEntry a, LeaderboardEntry b) =>
        b.score.compareTo(a.score));
    return <LeaderboardEntry>[
      for (int i = 0; i < scoped.length && i < limit; i++)
        scoped[i].copyWith(rank: i + 1),
    ];
  }

  /// Deterministic fake rivals so the board looks alive without a backend.
  List<LeaderboardEntry> _seed(String gameId) {
    final int salt = gameId.hashCode;
    const List<String> names = <String>[
      'Nova', 'Blaze', 'Echo', 'Pixel', 'Zephyr', 'Mochi', 'Quark', 'Lumi',
      'Riff', 'Tango', 'Vega', 'Orbit', 'Juno', 'Sable', 'Wisp',
    ];
    return <LeaderboardEntry>[
      for (int i = 0; i < names.length; i++)
        LeaderboardEntry(
          playerId: 'bot_$i',
          username: names[i],
          avatarId: 'avatar_0${(i % 6) + 1}',
          score: 1500 - i * 70 + (salt % 40),
          rank: 0,
          isCurrentPlayer: false,
        ),
    ];
  }
}
