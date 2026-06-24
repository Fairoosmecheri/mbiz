import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/di/providers.dart';
import '../../data/models/app_settings.dart';

final settingsProvider =
    NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

/// Owns user preferences and propagates the audio/haptics flags to the
/// [AudioService] so games respect them without each game reading storage.
class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final dynamic raw =
        ref.read(storageServiceProvider).settingsBox.get(AppConstants.settingsKey);
    final AppSettings settings =
        raw is Map ? AppSettings.fromJson(raw) : AppSettings.defaults();
    _applyToAudio(settings);
    return settings;
  }

  void _persist(AppSettings settings) {
    state = settings;
    ref
        .read(storageServiceProvider)
        .settingsBox
        .put(AppConstants.settingsKey, settings.toJson());
    _applyToAudio(settings);
  }

  void _applyToAudio(AppSettings s) {
    final audio = ref.read(audioServiceProvider);
    audio.soundEnabled = s.soundEnabled;
    audio.musicEnabled = s.musicEnabled;
    audio.vibrationEnabled = s.vibrationEnabled;
  }

  void toggleMusic(bool value) => _persist(state.copyWith(musicEnabled: value));
  void toggleSound(bool value) => _persist(state.copyWith(soundEnabled: value));
  void toggleVibration(bool value) =>
      _persist(state.copyWith(vibrationEnabled: value));
  void setThemeMode(ThemeMode mode) =>
      _persist(state.copyWith(themeMode: mode));
}
