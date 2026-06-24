import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/services/audio_service.dart';
import '../../game_framework/game_difficulty.dart';
import '../../game_framework/game_result.dart';
import '../../game_framework/mini_game.dart';

/// Speed Tap — tap as many times as possible in 10 seconds.
class SpeedTapGame extends MiniGame {
  static const int durationSeconds = 10;

  @override
  String get id => 'speed_tap';

  @override
  String get name => 'Speed Tap';

  @override
  String get description => 'Tap as fast as you can for 10 seconds.';

  @override
  IconData get icon => Icons.touch_app_rounded;

  @override
  Color get accentColor => const Color(0xFF00B894);

  @override
  GameDifficulty get difficulty => GameDifficulty.easy;

  @override
  String get scoreUnit => 'taps';

  @override
  Widget build(BuildContext context, GameController controller) =>
      _SpeedTapView(controller: controller);
}

class _SpeedTapView extends StatefulWidget {
  const _SpeedTapView({required this.controller});

  final GameController controller;

  @override
  State<_SpeedTapView> createState() => _SpeedTapViewState();
}

class _SpeedTapViewState extends State<_SpeedTapView>
    with SingleTickerProviderStateMixin {
  int _taps = 0;
  int _remaining = SpeedTapGame.durationSeconds;
  bool _started = false;
  bool _finished = false;
  Timer? _timer;

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 90),
    lowerBound: 0.9,
    upperBound: 1.0,
    value: 1.0,
  );

  @override
  void dispose() {
    _timer?.cancel();
    _pulse.dispose();
    super.dispose();
  }

  void _begin() {
    setState(() {
      _started = true;
      _remaining = SpeedTapGame.durationSeconds;
      _taps = 0;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() => _remaining--);
      if (_remaining <= 0) {
        t.cancel();
        _finish();
      }
    });
  }

  void _tap() {
    if (_finished) return;
    if (!_started) {
      _begin();
    }
    _pulse
      ..reverse()
      ..forward();
    AudioService.instance.vibrateLight();
    setState(() => _taps++);
  }

  void _finish() {
    setState(() => _finished = true);
    AudioService.instance.vibrateHeavy();
    widget.controller.submit(
      GameResult(
        gameId: 'speed_tap',
        score: _taps,
        won: true,
        durationSeconds: SpeedTapGame.durationSeconds,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _tap(),
      behavior: HitTestBehavior.opaque,
      child: Container(
        color: const Color(0xFF0E1A14),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _started ? '0:${_remaining.toString().padLeft(2, '0')}' : 'Ready?',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 28,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            ScaleTransition(
              scale: _pulse,
              child: Text(
                '$_taps',
                style: const TextStyle(
                  color: Color(0xFF00B894),
                  fontSize: 96,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              _started ? 'TAP! TAP! TAP!' : 'Tap anywhere to start',
              style: const TextStyle(color: Colors.white54, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
