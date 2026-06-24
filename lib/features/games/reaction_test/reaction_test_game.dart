import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/services/audio_service.dart';
import '../../game_framework/game_difficulty.dart';
import '../../game_framework/game_result.dart';
import '../../game_framework/mini_game.dart';

/// Reaction Test — the screen turns green after a random delay; tap as fast as
/// possible. Score is the reaction time in milliseconds (lower is better).
class ReactionTestGame extends MiniGame {
  @override
  String get id => 'reaction_test';

  @override
  String get name => 'Reaction Test';

  @override
  String get description => 'Tap the instant the screen turns green.';

  @override
  IconData get icon => Icons.bolt_rounded;

  @override
  Color get accentColor => const Color(0xFFE74C3C);

  @override
  GameDifficulty get difficulty => GameDifficulty.easy;

  @override
  bool get higherIsBetter => false;

  @override
  String get scoreUnit => 'ms';

  @override
  String formatScore(int score) => '$score ms';

  @override
  Widget build(BuildContext context, GameController controller) =>
      _ReactionTestView(controller: controller);
}

enum _Phase { idle, waiting, ready, tooSoon }

class _ReactionTestView extends StatefulWidget {
  const _ReactionTestView({required this.controller});

  final GameController controller;

  @override
  State<_ReactionTestView> createState() => _ReactionTestViewState();
}

class _ReactionTestViewState extends State<_ReactionTestView> {
  _Phase _phase = _Phase.idle;
  Timer? _timer;
  int? _greenAt;
  int? _lastMs;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    setState(() => _phase = _Phase.waiting);
    final int delayMs = 1200 + Random().nextInt(2800);
    _timer = Timer(Duration(milliseconds: delayMs), () {
      _greenAt = DateTime.now().millisecondsSinceEpoch;
      setState(() => _phase = _Phase.ready);
    });
  }

  void _onTap() {
    switch (_phase) {
      case _Phase.idle:
      case _Phase.tooSoon:
        _start();
        break;
      case _Phase.waiting:
        // Tapped before green — penalise and reset.
        _timer?.cancel();
        AudioService.instance.vibrateHeavy();
        setState(() => _phase = _Phase.tooSoon);
        break;
      case _Phase.ready:
        final int reaction =
            DateTime.now().millisecondsSinceEpoch - (_greenAt ?? 0);
        AudioService.instance.vibrateLight();
        setState(() {
          _lastMs = reaction;
          _phase = _Phase.idle;
        });
        widget.controller.submit(
          GameResult(
            gameId: 'reaction_test',
            score: reaction,
            won: true,
            durationSeconds: (reaction / 1000).ceil(),
          ),
        );
        break;
    }
  }

  Color get _bg {
    switch (_phase) {
      case _Phase.ready:
        return const Color(0xFF00B894);
      case _Phase.waiting:
        return const Color(0xFFE74C3C);
      case _Phase.tooSoon:
        return const Color(0xFFF39C12);
      case _Phase.idle:
        return const Color(0xFF2D3436);
    }
  }

  String get _label {
    switch (_phase) {
      case _Phase.ready:
        return 'TAP!';
      case _Phase.waiting:
        return 'Wait for green…';
      case _Phase.tooSoon:
        return 'Too soon!\nTap to retry';
      case _Phase.idle:
        return _lastMs == null
            ? 'Tap to start'
            : 'Last: $_lastMs ms\nTap to retry';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        color: _bg,
        alignment: Alignment.center,
        child: Text(
          _label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
