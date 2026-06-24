import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/di/providers.dart';
import 'core/services/ad_service.dart';
import 'core/services/storage_service.dart';
import 'features/profile/profile_notifier.dart';
import 'features/progression/progression_service.dart';

/// Application entry point.
///
/// Boots local storage (Hive) and AdMob before the first frame, then warms up
/// the core Riverpod providers and grants the daily-login XP bonus once per day.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Persisted data must be ready before any provider reads it.
  await StorageService.instance.init();

  // AdMob init is fire-and-forget; gameplay never blocks on it.
  unawaited(AdService.instance.init());

  final container = ProviderContainer();

  // Sync the "ads removed" flag into the ad service and apply the daily login
  // bonus. Reading the providers here also constructs them eagerly so the first
  // screen has no load jank.
  AdService.instance.adsRemoved = container.read(profileProvider).adsRemoved;
  container.read(progressionServiceProvider).grantDailyLoginIfDue();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const PocketArcadeApp(),
    ),
  );
}
