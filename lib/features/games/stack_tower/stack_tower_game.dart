import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/services/audio_service.dart';
import '../../game_framework/game_difficulty.dart';
import '../../game_framework/game_result.dart';
import '../../game_framework/mini_game.dart';

/// Stack Tower — a block slides back and forth; tap to drop it onto the stack.
/// Any overhang is sliced off, shrinking the next block. Miss completely and
/// it's game over. Endless; score is the number of blocks stacked.
class StackTowerGame extends MiniGame {
  @override
  String get id => 'stack_tower';

  @override
  String get name => 'Stack Tower';

  @override
  String get description => 'Drop blocks and build the tallest tower.';

  @override
  IconData get icon => Icons.view_agenda_rounded;

  @override
  Color get accentColor => const Color(0xFF0984E3);

  @override
  GameDifficulty get difficulty => GameDifficulty.medium;

  @override
  String get scoreUnit => 'blocks';

  @override
  Widget build(BuildContext context, GameController controller) =>
      _StackTowerView(controller: controller);
}

class _Block {
  _Block(this.left, this.width);
  double left;
  double width;
}

class _StackTowerView extends StatefulWidget {
  const _StackTowerView({required this.controller});

  final GameController controller;

  @override
  State<_StackTowerView> createState() => _StackTowerViewState();
}

class _StackTowerViewState extends State<_StackTowerView>
    with SingleTickerProviderStateMixin {
  static const double _blockHeight = 30;

  late AnimationController _mover;
  final List<_Block> _stack = <_Block>[];
  double _movingLeft = 0;
  double _movingWidth = 0;
  double _fieldWidth = 0;
  bool _started = false;
  bool _gameOver = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _mover = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..addListener(_tick);
  }

  @override
  void dispose() {
    _mover.dispose();
    super.dispose();
  }

  void _tick() {
    if (_fieldWidth == 0) return;
    final double maxLeft = _fieldWidth - _movingWidth;
    setState(() => _movingLeft = maxLeft * _mover.value);
  }

  void _setup(double width) {
    _fieldWidth = width;
    _movingWidth = width * 0.45;
    final double baseLeft = (width - _movingWidth) / 2;
    _stack
      ..clear()
      ..add(_Block(baseLeft, _movingWidth));
  }

  void _start() {
    setState(() {
      _started = true;
      _gameOver = false;
      _score = 0;
    });
    _setup(_fieldWidth);
    _mover.repeat(reverse: true);
  }

  void _drop() {
    if (!_started || _gameOver) return;
    final _Block top = _stack.last;
    final double newLeft = max(top.left, _movingLeft);
    final double newRight = min(top.left + top.width, _movingLeft + _movingWidth);
    final double overlap = newRight - newLeft;

    if (overlap <= 0) {
      _end();
      return;
    }

    AudioService.instance.vibrateLight();
    setState(() {
      _stack.add(_Block(newLeft, overlap));
      _movingWidth = overlap;
      _score++;
    });

    // Speed up as the tower grows.
    final int ms = max(450, 1400 - _score * 60);
    _mover
      ..stop()
      ..duration = Duration(milliseconds: ms)
      ..reset()
      ..repeat(reverse: true);
  }

  void _end() {
    _mover.stop();
    AudioService.instance.vibrateHeavy();
    setState(() => _gameOver = true);
    widget.controller.submit(
      GameResult(
        gameId: 'stack_tower',
        score: _score,
        won: _score >= 10,
        durationSeconds: _score, // ~1 drop/sec feel
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (_fieldWidth == 0) {
          _fieldWidth = constraints.maxWidth;
          _setup(_fieldWidth);
        }
        final double height = constraints.maxHeight;

        // Only the most recent blocks are visible, scrolling upward.
        final int visible = (height ~/ _blockHeight) - 2;
        final int startIndex = max(0, _stack.length - visible);

        return GestureDetector(
          onTapDown: (_) => _started ? _drop() : _start(),
          behavior: HitTestBehavior.opaque,
          child: Container(
            color: const Color(0xFF0B1622),
            child: Stack(
              children: <Widget>[
                // Placed blocks.
                for (int i = startIndex; i < _stack.length; i++)
                  Positioned(
                    left: _stack[i].left,
                    bottom: (i - startIndex) * _blockHeight,
                    child: _blockBox(_stack[i].width,
                        Color.lerp(const Color(0xFF0984E3),
                            const Color(0xFF00CEC9), (i % 10) / 10)!),
                  ),
                // Moving block sits one row above the top of the stack.
                if (_started && !_gameOver)
                  Positioned(
                    left: _movingLeft,
                    bottom: (_stack.length - startIndex) * _blockHeight,
                    child: _blockBox(_movingWidth, const Color(0xFFFD79A8)),
                  ),
                Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      _started ? '$_score' : 'Tap to start',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
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

  Widget _blockBox(double width, Color color) => Container(
        width: width,
        height: _blockHeight - 3,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
        ),
      );
}
