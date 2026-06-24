import '../../core/constants/app_constants.dart';
import '../../core/services/storage_service.dart';
import '../models/player_profile.dart';

/// Persistence gateway for the single [PlayerProfile] document.
class ProfileRepository {
  ProfileRepository(this._storage);

  final StorageService _storage;

  /// Loads the stored profile, creating a fresh one on first launch.
  PlayerProfile load() {
    final dynamic raw = _storage.profileBox.get(AppConstants.profileKey);
    if (raw is Map) {
      return PlayerProfile.fromJson(raw);
    }
    final PlayerProfile fresh = PlayerProfile.initial();
    _persist(fresh);
    return fresh;
  }

  Future<void> save(PlayerProfile profile) => _persist(profile);

  Future<void> _persist(PlayerProfile profile) =>
      _storage.profileBox.put(AppConstants.profileKey, profile.toJson());
}
