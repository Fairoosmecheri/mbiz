import 'package:flutter/services.dart';

/// Lightweight audio / haptics facade.
///
/// Sound effects and background music are intentionally abstracted behind this
/// service. Wiring an audio package (e.g. `audioplayers`) only requires filling
/// in [playSfx] / [playMusic]; the rest of the app already calls through here
/// and respects the user's Settings toggles via the flags below.
class AudioService {
  AudioService._();

  static final AudioService instance = AudioService._();

  bool soundEnabled = true;
  bool musicEnabled = true;
  bool vibrationEnabled = true;

  /// Play a named short sound effect (e.g. 'tap', 'win', 'fail').
  void playSfx(String name) {
    if (!soundEnabled) return;
    // Hook an audio package in here. Kept as a no-op so the build stays
    // asset-light; SFX files live under assets/sounds/.
  }

  void playMusic(String name) {
    if (!musicEnabled) return;
    // Background music hook.
  }

  void stopMusic() {
    // Stop background music hook.
  }

  /// Light haptic tick, gated on the vibration setting.
  void vibrateLight() {
    if (!vibrationEnabled) return;
    HapticFeedback.lightImpact();
  }

  /// Stronger haptic, used for win/fail moments.
  void vibrateHeavy() {
    if (!vibrationEnabled) return;
    HapticFeedback.heavyImpact();
  }
}
