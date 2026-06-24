import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/di/providers.dart';
import '../../data/models/leaderboard_entry.dart';
import '../../shared/widgets/avatar_view.dart';
import '../game_framework/mini_game.dart';

/// Leaderboard screen with Global / Friends / Weekly scopes and a game picker.
///
/// Backed by the [FirebaseService] abstraction (currently mocked), so the UI is
/// fully functional offline and ready for a live Firestore backend.
class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key, required this.gameId});

  final String gameId;

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late String _gameId = widget.gameId;
  late final TabController _tabs = TabController(length: 3, vsync: this);

  static const List<LeaderboardScope> _scopes = <LeaderboardScope>[
    LeaderboardScope.global,
    LeaderboardScope.friends,
    LeaderboardScope.weekly,
  ];

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<MiniGame> games = ref.watch(gameRegistryProvider).games;
    final MiniGame? game = ref.watch(gameRegistryProvider).byId(_gameId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const <Tab>[
            Tab(text: 'Global'),
            Tab(text: 'Friends'),
            Tab(text: 'Weekly'),
          ],
        ),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              value: _gameId,
              decoration: const InputDecoration(
                labelText: 'Game',
                border: OutlineInputBorder(),
              ),
              items: <DropdownMenuItem<String>>[
                for (final MiniGame g in games)
                  DropdownMenuItem<String>(value: g.id, child: Text(g.name)),
              ],
              onChanged: (String? v) => setState(() => _gameId = v ?? _gameId),
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: <Widget>[
                for (final LeaderboardScope scope in _scopes)
                  _ScopeView(gameId: _gameId, scope: scope, game: game),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScopeView extends ConsumerWidget {
  const _ScopeView({
    required this.gameId,
    required this.scope,
    required this.game,
  });

  final String gameId;
  final LeaderboardScope scope;
  final MiniGame? game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(leaderboardRepositoryProvider);

    return FutureBuilder<List<LeaderboardEntry>>(
      future: repo.fetch(gameId: gameId, scope: scope),
      builder: (BuildContext context,
          AsyncSnapshot<List<LeaderboardEntry>> snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final List<LeaderboardEntry> entries = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: entries.length,
          itemBuilder: (BuildContext context, int i) {
            final LeaderboardEntry e = entries[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: e.isCurrentPlayer
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : null,
              child: ListTile(
                leading: SizedBox(
                  width: 40,
                  child: Row(
                    children: <Widget>[
                      Text('${e.rank}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                title: Row(
                  children: <Widget>[
                    AvatarView(avatarId: e.avatarId, size: 28),
                    const SizedBox(width: 8),
                    Text(e.username,
                        style: TextStyle(
                            fontWeight: e.isCurrentPlayer
                                ? FontWeight.bold
                                : FontWeight.normal)),
                  ],
                ),
                trailing: Text(
                  game?.formatScore(e.score) ?? '${e.score}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
