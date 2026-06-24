import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/providers.dart';
import '../../data/models/player_profile.dart';

final profileProvider =
    NotifierProvider<ProfileNotifier, PlayerProfile>(ProfileNotifier.new);

/// Reactive owner of the [PlayerProfile]. Every mutation persists immediately
/// and keeps the [AdService] in sync with the "ads removed" flag.
class ProfileNotifier extends Notifier<PlayerProfile> {
  @override
  PlayerProfile build() {
    final PlayerProfile profile = ref.read(profileRepositoryProvider).load();
    ref.read(adServiceProvider).adsRemoved = profile.adsRemoved;
    return profile;
  }

  /// Replace the whole profile (used by the progression service after it has
  /// composed all reward mutations into one new state).
  void set(PlayerProfile profile) {
    state = profile;
    ref.read(profileRepositoryProvider).save(profile);
    ref.read(adServiceProvider).adsRemoved = profile.adsRemoved;
  }

  void setUsername(String username) =>
      set(state.copyWith(username: username.trim().isEmpty ? 'Player' : username.trim()));

  void setAvatar(String avatarId) => set(state.copyWith(avatarId: avatarId));

  /// Credit coins and keep the lifetime counter in sync.
  void addCoins(int amount) {
    if (amount <= 0) return;
    set(state.copyWith(
      coins: state.coins + amount,
      lifetimeCoinsEarned: state.lifetimeCoinsEarned + amount,
    ));
  }

  /// Attempt to spend coins. Returns `false` (and changes nothing) if the
  /// player can't afford it.
  bool spendCoins(int amount) {
    if (amount <= 0 || state.coins < amount) return false;
    set(state.copyWith(coins: state.coins - amount));
    return true;
  }

  void unlockAvatar(String avatarId) => set(state.copyWith(
        ownedAvatars: <String>{...state.ownedAvatars, avatarId},
      ));

  void unlockTheme(String themeId) => set(state.copyWith(
        ownedThemes: <String>{...state.ownedThemes, themeId},
      ));

  void removeAds() => set(state.copyWith(adsRemoved: true));
}
