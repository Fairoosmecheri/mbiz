import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../data/models/achievement.dart';
import '../profile/profile_notifier.dart';

/// Derived, read-only view of all achievements with their unlock state resolved
/// against the current profile. Rebuilds automatically whenever the profile
/// changes (e.g. after an unlock), so the achievements screen is always live.
final achievementsProvider = Provider<List<Achievement>>((ref) {
  final profile = ref.watch(profileProvider);
  return ref.read(achievementRepositoryProvider).all(profile);
});

/// Convenience provider for the "X / Y unlocked" summary on the profile screen.
final achievementSummaryProvider = Provider<({int unlocked, int total})>((ref) {
  final profile = ref.watch(profileProvider);
  final repo = ref.read(achievementRepositoryProvider);
  return (unlocked: repo.unlockedCount(profile), total: repo.total);
});
