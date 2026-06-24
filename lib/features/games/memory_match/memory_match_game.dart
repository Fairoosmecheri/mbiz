import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/services/audio_service.dart';
import '../../game_framework/game_difficulty.dart';
import '../../game_framework/game_result.dart';
import '../../game_framework/mini_game.dart';

/// Memory Match — flip cards to find matching pairs against the clock. Supports
/// three difficulty levels (more pairs = harder). Score rewards speed and few
/// moves; the run is "won" when every pair is matched.
class MemoryMatchGame extends MiniGame {
  @override
  String get id => 'memory_match';

  @override
  String get name => 'Memory Match';

  @override
  String get description => 'Find every matching pair before the clock climbs.';

  @override
  IconData get icon => Icons.grid_view_rounded;

  @override
  Color get accentColor => const Color(0xFFFDCB6E);

  @override
  GameDifficulty get difficulty => GameDifficulty.medium;

  @override
  String get scoreUnit => 'pts';

  @override
  Widget build(BuildContext context, GameController controller) =>
      _MemoryMatchView(controller: controller);
}

/// (pairs, columns) per difficulty level.
const Map<String, ({int pairs, int columns})> _levels =
    <String, ({int pairs, int columns})>{
  'Easy': (pairs: 6, columns: 3),
  'Medium': (pairs: 8, columns: 4),
  'Hard': (pairs: 10, columns: 4),
};

const List<String> _faces = <String>[
  '🍎', '🚀', '🐱', '🎲', '⭐', '🍩', '🐸', '🎸', '🔥', '💎', '🍔', '🌈',
];

class _Card {
  _Card(this.face);
  final String face;
  bool flipped = false;
  bool matched = false;
}

class _MemoryMatchView extends StatefulWidget {
  const _MemoryMatchView({required this.controller});

  final GameController controller;

  @override
  State<_MemoryMatchView> createState() => _MemoryMatchViewState();
}

class _MemoryMatchViewState extends State<_MemoryMatchView> {
  List<_Card> _cards = <_Card>[];
  int _columns = 4;
  int _pairs = 8;
  int _moves = 0;
  int _matched = 0;
  int _seconds = 0;
  Timer? _timer;
  _Card? _firstFlipped;
  bool _locked = false;
  bool _playing = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startLevel(String level) {
    final ({int pairs, int columns}) cfg = _levels[level]!;
    final List<String> chosen = _faces.take(cfg.pairs).toList();
    final List<_Card> deck = <_Card>[
      for (final String f in chosen) ...<_Card>[_Card(f), _Card(f)],
    ]..shuffle();

    setState(() {
      _cards = deck;
      _columns = cfg.columns;
      _pairs = cfg.pairs;
      _moves = 0;
      _matched = 0;
      _seconds = 0;
      _firstFlipped = null;
      _locked = false;
      _playing = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _seconds++);
    });
  }

  void _onCardTap(_Card card) {
    if (_locked || card.flipped || card.matched) return;
    AudioService.instance.vibrateLight();
    setState(() => card.flipped = true);

    if (_firstFlipped == null) {
      _firstFlipped = card;
      return;
    }

    _moves++;
    final _Card first = _firstFlipped!;
    if (first.face == card.face) {
      setState(() {
        first.matched = true;
        card.matched = true;
        _matched++;
      });
      _firstFlipped = null;
      if (_matched == _pairs) _finish();
    } else {
      _locked = true;
      Timer(const Duration(milliseconds: 700), () {
        setState(() {
          first.flipped = false;
          card.flipped = false;
          _firstFlipped = null;
          _locked = false;
        });
      });
    }
  }

  void _finish() {
    _timer?.cancel();
    AudioService.instance.vibrateHeavy();
    // Reward speed and efficiency: base scales with difficulty.
    final int base = _pairs * 100;
    final int score = (base - _seconds * 5 - _moves * 3).clamp(10, base);
    widget.controller.submit(
      GameResult(
        gameId: 'memory_match',
        score: score,
        won: true,
        durationSeconds: _seconds,
        metrics: <String, int>{'completionSeconds': _seconds},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_playing) return _levelPicker();

    return Container(
      color: const Color(0xFF15151E),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                _stat('Time', '${_seconds}s'),
                _stat('Moves', '$_moves'),
                _stat('Pairs', '$_matched / $_pairs'),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _columns,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                itemCount: _cards.length,
                itemBuilder: (BuildContext context, int i) =>
                    _cardTile(_cards[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) => Column(
        children: <Widget>[
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
        ],
      );

  Widget _cardTile(_Card card) {
    final bool faceUp = card.flipped || card.matched;
    return GestureDetector(
      onTap: () => _onCardTap(card),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: card.matched
              ? const Color(0xFF00B894)
              : faceUp
                  ? Colors.white
                  : const Color(0xFF2D2D3E),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          faceUp ? card.face : '',
          style: const TextStyle(fontSize: 34),
        ),
      ),
    );
  }

  Widget _levelPicker() {
    return Container(
      color: const Color(0xFF15151E),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Text(
            'Choose difficulty',
            style: TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          for (final String level in _levels.keys)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () => _startLevel(level),
                  child: Text('$level  •  ${_levels[level]!.pairs} pairs'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
