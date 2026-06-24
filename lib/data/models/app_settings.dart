import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// User-configurable preferences surfaced on the Settings screen.
class AppSettings extends Equatable {
  const AppSettings({
    required this.musicEnabled,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.themeMode,
  });

  final bool musicEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final ThemeMode themeMode;

  factory AppSettings.defaults() => const AppSettings(
        musicEnabled: true,
        soundEnabled: true,
        vibrationEnabled: true,
        themeMode: ThemeMode.system,
      );

  AppSettings copyWith({
    bool? musicEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
    ThemeMode? themeMode,
  }) {
    return AppSettings(
      musicEnabled: musicEnabled ?? this.musicEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'musicEnabled': musicEnabled,
        'soundEnabled': soundEnabled,
        'vibrationEnabled': vibrationEnabled,
        'themeMode': themeMode.name,
      };

  factory AppSettings.fromJson(Map<dynamic, dynamic> json) => AppSettings(
        musicEnabled: json['musicEnabled'] as bool? ?? true,
        soundEnabled: json['soundEnabled'] as bool? ?? true,
        vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
        themeMode: ThemeMode.values.firstWhere(
          (ThemeMode m) => m.name == json['themeMode'],
          orElse: () => ThemeMode.system,
        ),
      );

  @override
  List<Object?> get props =>
      <Object?>[musicEnabled, soundEnabled, vibrationEnabled, themeMode];
}
