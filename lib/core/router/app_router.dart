import 'package:go_router/go_router.dart';

import '../../features/games/game_host_page.dart';
import '../../features/leaderboard/leaderboard_screen.dart';
import '../../features/navigation/root_shell.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/shop/shop_screen.dart';

/// Central route table. Primary tabs live inside [RootShell]; full-screen flows
/// (gameplay, settings, shop, leaderboards) are pushed on top.
class AppRouter {
  const AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        builder: (context, state) => const RootShell(),
      ),
      GoRoute(
        path: '/game/:id',
        builder: (context, state) =>
            GameHostPage(gameId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/leaderboard/:id',
        builder: (context, state) =>
            LeaderboardScreen(gameId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/shop',
        builder: (context, state) => const ShopScreen(),
      ),
    ],
  );
}
