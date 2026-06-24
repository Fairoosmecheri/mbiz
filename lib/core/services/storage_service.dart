import 'package:hive_flutter/hive_flutter.dart';

import '../constants/app_constants.dart';

/// Thin, typed wrapper around Hive.
///
/// Every model is persisted as a plain JSON `Map`, which keeps the data layer
/// free of generated `TypeAdapter`s and makes a future Firebase sync trivial
/// (the same maps go straight to Firestore). All boxes are opened once during
/// [init] so repositories can access them synchronously.
class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  late final Box<dynamic> _profileBox;
  late final Box<dynamic> _statsBox;
  late final Box<dynamic> _challengesBox;
  late final Box<dynamic> _dailyRewardBox;
  late final Box<dynamic> _settingsBox;
  late final Box<dynamic> _leaderboardBox;

  /// Must be awaited before any repository is used (called from `main`).
  Future<void> init() async {
    await Hive.initFlutter();
    _profileBox = await Hive.openBox<dynamic>(AppConstants.profileBox);
    _statsBox = await Hive.openBox<dynamic>(AppConstants.statsBox);
    _challengesBox = await Hive.openBox<dynamic>(AppConstants.challengesBox);
    _dailyRewardBox = await Hive.openBox<dynamic>(AppConstants.dailyRewardBox);
    _settingsBox = await Hive.openBox<dynamic>(AppConstants.settingsBox);
    _leaderboardBox = await Hive.openBox<dynamic>(AppConstants.leaderboardBox);
  }

  Box<dynamic> get profileBox => _profileBox;
  Box<dynamic> get statsBox => _statsBox;
  Box<dynamic> get challengesBox => _challengesBox;
  Box<dynamic> get dailyRewardBox => _dailyRewardBox;
  Box<dynamic> get settingsBox => _settingsBox;
  Box<dynamic> get leaderboardBox => _leaderboardBox;

  /// Wipes all persisted data (used by the "reset progress" setting / tests).
  Future<void> clearAll() async {
    await Future.wait<void>(<Future<void>>[
      _profileBox.clear(),
      _statsBox.clear(),
      _challengesBox.clear(),
      _dailyRewardBox.clear(),
      _settingsBox.clear(),
      _leaderboardBox.clear(),
    ]);
  }
}
