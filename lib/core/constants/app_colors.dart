import 'package:flutter/material.dart';

/// Centralised colour palette. Bright, modern, mobile-first.
///
/// Theme-specific colours (backgrounds, surfaces, text) are resolved by
/// [AppTheme]; the values here are brand/accent constants reused across both
/// light and dark themes.
class AppColors {
  const AppColors._();

  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryDark = Color(0xFF5546C9);
  static const Color secondary = Color(0xFF00CEC9);
  static const Color accent = Color(0xFFFD79A8);

  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color danger = Color(0xFFE74C3C);
  static const Color info = Color(0xFF0984E3);

  static const Color coin = Color(0xFFFFC107);
  static const Color xp = Color(0xFF6C5CE7);

  // Light theme surfaces.
  static const Color lightBackground = Color(0xFFF5F6FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightText = Color(0xFF2D3436);

  // Dark theme surfaces.
  static const Color darkBackground = Color(0xFF15151E);
  static const Color darkSurface = Color(0xFF20202E);
  static const Color darkText = Color(0xFFF1F2F6);

  /// Vibrant gradient used on hero cards, the quick-play button, etc.
  static const List<Color> heroGradient = <Color>[
    Color(0xFF6C5CE7),
    Color(0xFF00CEC9),
  ];

  /// Per-game accent colours, keyed by game id, so cards feel distinct.
  static const Map<String, Color> gameAccents = <String, Color>{
    'reaction_test': Color(0xFFE74C3C),
    'speed_tap': Color(0xFF00B894),
    'stack_tower': Color(0xFF0984E3),
    'ball_dodge': Color(0xFFFD79A8),
    'memory_match': Color(0xFFFDCB6E),
  };
}
