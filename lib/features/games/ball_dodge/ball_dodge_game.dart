import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../core/services/audio_service.dart';
import '../../game_framework/game_difficulty.dart';
import '../../game_framework/game_result.dart';
import '../../game_framework/mini_game.dart';

/// Ball Dodge — slide the player left/right to dodge falling obstacles. The
/// longer you survive the faster they fall. Endless; score is obstacles dodged.
class BallDodgeGame extends MiniGame {
  @override
  String get id => 'ball_dodge';

  @override
  String get name => 'Ball Dodge';

  @override
  String get description => 'Slide to dodge the falling obstacles.';

  @override
  IconData get icon => Icons.sports_baseball_rounded;

  @override
  Color get accentColor => const Color(0xFFFD79A8);

  @override
  GameDifficulty get difficulty => GameDifficulty.hard;

  @override
  String get scoreUnit => 'dodged';

  @override
  Widget build(BuildContext context, GameController controller) =>
      _BallDodgeView(controller: controller);
}

class _Obstacle {
  _Obstacle(this.x, this.y, this.size);
  double x;
  double y;
  double size;
}

class _BallDodgeView extends StatefulWidget {
  const _BallDodgeView({required this.controller});

  final GameController controller;

  @override
  State<_BallDodgeView> createState() => _BallDodgeViewState();
}

class _BallDodgeViewState extends State<_BallDodgeView>
    with SingleTickerProviderStateMixin {
  static const double _playerRadius = 22;

  late final Ticker _ticker;
  final Random _rng = Random();
  final List<_Obstacle> _obstacles = <_Obstacle>[];

  Size _field = Size.zero;
  double _playerX = 0;
  Duration _lastTick = Duration.zero;
  double _spawnTimer = 0;
  double _elapsed = 0;
  int _dodged = 0;
  bool _started = false;
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick);
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _start() {
    _obstacles.clear();
    _playerX = _field.width / 2;
    _lastTick = Duration.zero;
    _spawnTimer = 0;
    _elapsed = 0;
    _dodged = 0;
    setState(() {
      _started = true;
      _gameOver = false;
    });
    _ticker.start();
  }

  double get _fallSpeed => 160 + _elapsed * 14; // px/sec, ramps up
  double get _spawnInterval => max(0.45, 1.1 - _elapsed * 0.02); // seconds

  void _onTick(Duration now) {
    if (_lastTick == Duration.zero) {
      _lastTick = now;
      return;
    }
    final double dt = (now - _lastTick).inMicroseconds / 1e6;
    _lastTick = now;
    _elapsed += dt;
    _spawnTimer += dt;

    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      final double size = 24 + _rng.nextDouble() * 26;
      _obstacles.add(_Obstacle(
        _rng.nextDouble() * (_field.width - size),
        -size,
        size,
      ));
    }

    final double playerY = _field.height - 70;
    for (final _Obstacle o in _obstacles) {
      o.y += _fallSpeed * dt;
      // Circle (player) vs rect (obstacle) overlap.
      final double nearestX = o.x + o.size / 2;
      final double dx = (_playerX - nearestX);
      final double dy = (playerY - (o.y + o.size / 2));
      if (dx.abs() < (_playerRadius + o.size / 2) &&
          dy.abs() < (_playerRadius + o.size / 2)) {
        _end();
        return;
      }
    }

    final int before = _obstacles.length;
    _obstacles.removeWhere((_Obstacle o) => o.y > _field.height);
    _dodged += before - _obstacles.length;

    setState(() {});
  }

  void _end() {
    _ticker.stop();
    AudioService.instance.vibrateHeavy();
    setState(() => _gameOver = true);
    final int survived = _elapsed.round();
    widget.controller.submit(
      GameResult(
        gameId: 'ball_dodge',
        score: _dodged,
        won: survived >= 30,
        durationSeconds: survived,
        metrics: <String, int>{'survivedSeconds': survived},
      ),
    );
  }

  void _moveTo(double x) {
    setState(() => _playerX = x.clamp(_playerRadius, _field.width - _playerRadius));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        _field = Size(constraints.maxWidth, constraints.maxHeight);
        if (!_started && _playerX == 0) _playerX = _field.width / 2;
        final double playerY = _field.height - 70;

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (_) {
            if (!_started || _gameOver) _start();
          },
          onPanUpdate: (DragUpdateDetails d) {
            if (_started) _moveTo(d.localPosition.dx);
          },
          child: Container(
            color: const Color(0xFF1A0E1A),
            child: Stack(
              children: <Widget>[
                for (final _Obstacle o in _obstacles)
                  Positioned(
                    left: o.x,
                    top: o.y,
                    child: Container(
                      width: o.size,
                      height: o.size,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFD79A8),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                if (_started)
                  Positioned(
                    left: _playerX - _playerRadius,
                    top: playerY - _playerRadius,
                    child: Container(
                      width: _playerRadius * 2,
                      height: _playerRadius * 2,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.5),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      _started ? '$_dodged dodged' : 'Tap to start',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (_started)
                  const Positioned(
                    bottom: 12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Text(
                        'Drag to move',
                        style: TextStyle(color: Colors.white38, fontSize: 14),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
