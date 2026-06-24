import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Coarse difficulty label shown on game cards.
enum GameDifficulty { easy, medium, hard }

extension GameDifficultyX on GameDifficulty {
  String get label {
    switch (this) {
      case GameDifficulty.easy:
        return 'Easy';
      case GameDifficulty.medium:
        return 'Medium';
      case GameDifficulty.hard:
        return 'Hard';
    }
  }

  Color get color {
    switch (this) {
      case GameDifficulty.easy:
        return AppColors.success;
      case GameDifficulty.medium:
        return AppColors.warning;
      case GameDifficulty.hard:
        return AppColors.danger;
    }
  }
}
