import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/achievement_repository.dart';
import '../../data/repositories/challenge_repository.dart';
import '../../data/repositories/daily_reward_repository.dart';
import '../../data/repositories/leaderboard_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/stats_repository.dart';
import '../../features/games/built_in_games.dart';
import '../../features/game_framework/game_registry.dart';
import '../services/ad_service.dart';
import '../services/audio_service.dart';
import '../services/firebase_service.dart';
import '../services/purchase_service.dart';
import '../services/storage_service.dart';

/// Root composition file. Every dependency the app uses is wired here, so the
/// object graph is described in one place (Dependency Injection via Riverpod).

// -----------------------------------------------------------------------------
// Core services (singletons)
// -----------------------------------------------------------------------------

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService.instance;
});

final adServiceProvider = Provider<AdService>((ref) {
  return AdService.instance;
});

final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService.instance;
});

final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  // Swap MockFirebaseService for a real FirestoreFirebaseService once the
  // backend is provisioned — nothing else changes.
  return MockFirebaseService();
});

final purchaseServiceProvider = Provider<PurchaseService>((ref) {
  // Swap MockPurchaseService for a real in_app_purchase-backed implementation
  // once products are configured in the store consoles.
  return MockPurchaseService();
});

/// The catalogue of mini-games. Built-in games register themselves here; adding
/// a game means adding one line in [registerBuiltInGames].
final gameRegistryProvider = Provider<GameRegistry>((ref) {
  final GameRegistry registry = GameRegistry();
  registerBuiltInGames(registry);
  return registry;
});

// -----------------------------------------------------------------------------
// Repositories
// -----------------------------------------------------------------------------

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(storageServiceProvider));
});

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  return StatsRepository(ref.watch(storageServiceProvider));
});

final achievementRepositoryProvider = Provider<AchievementRepository>((ref) {
  return AchievementRepository(ref.watch(statsRepositoryProvider));
});

final challengeRepositoryProvider = Provider<ChallengeRepository>((ref) {
  return ChallengeRepository(
    ref.watch(storageServiceProvider),
    ref.watch(gameRegistryProvider),
  );
});

final dailyRewardRepositoryProvider = Provider<DailyRewardRepository>((ref) {
  return DailyRewardRepository(ref.watch(storageServiceProvider));
});

final leaderboardRepositoryProvider = Provider<LeaderboardRepository>((ref) {
  return LeaderboardRepository(ref.watch(firebaseServiceProvider));
});
