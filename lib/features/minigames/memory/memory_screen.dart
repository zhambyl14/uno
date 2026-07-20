import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/insets.dart';
import '../../../core/constants/strings.dart';
import '../../../core/services/game_sounds.dart';
import '../../../core/services/haptics.dart';
import '../../../core/widgets/adaptive_scaffold.dart';
import '../../../core/widgets/how_to_play_sheet.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../game/domain/uno_card.dart';
import '../../game/presentation/widgets/uno_card_view.dart';

enum _Difficulty { easy, medium, hard }

extension on _Difficulty {
  int get pairs => switch (this) {
    _Difficulty.easy => 6,
    _Difficulty.medium => 8,
    _Difficulty.hard => 10,
  };
  int get columns => switch (this) {
    _Difficulty.easy => 3,
    _Difficulty.medium => 4,
    _Difficulty.hard => 4,
  };
  String get label => switch (this) {
    _Difficulty.easy => S.easy,
    _Difficulty.medium => S.medium,
    _Difficulty.hard => S.hard,
  };
}

class _Tile {
  _Tile(this.card);
  final UnoCard card;
  bool flipped = false;
  bool matched = false;
}

/// Memory/Concentration, played the way it's actually meant to be: two
/// players take turns on the same device (hotseat — pass the phone back and
/// forth). A match keeps your turn going; a miss hands it to the other
/// player. Most pairs found wins.
class MemoryScreen extends ConsumerStatefulWidget {
  const MemoryScreen({super.key});

  @override
  ConsumerState<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends ConsumerState<MemoryScreen> {
  final _rng = Random();
  _Difficulty _difficulty = _Difficulty.medium;
  late List<_Tile> _tiles;
  int? _firstIndex;
  bool _busy = false;
  bool _turnA = true;
  int _scoreA = 0;
  int _scoreB = 0;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _deal();
  }

  void _deal() {
    final pool = <UnoCard>[];
    var id = 0;
    const colors = [
      CardColor.red,
      CardColor.yellow,
      CardColor.green,
      CardColor.blue,
    ];
    for (final c in colors) {
      for (var n = 1; n <= 9; n++) {
        pool.add(
          UnoCard(id: 'm${id++}', color: c, type: CardType.number, number: n),
        );
      }
    }
    pool.shuffle(_rng);
    final faces = pool.take(_difficulty.pairs).toList();
    final tiles = <_Tile>[];
    for (final face in faces) {
      tiles
        ..add(_Tile(face))
        ..add(_Tile(face));
    }
    tiles.shuffle(_rng);
    _tiles = tiles;
    _firstIndex = null;
    _busy = false;
    _turnA = true;
    _scoreA = 0;
    _scoreB = 0;
    _finished = false;
  }

  bool _isPair(UnoCard a, UnoCard b) =>
      a.color == b.color && a.number == b.number;

  void _onTap(int index) {
    if (_busy || _finished) return;
    final tile = _tiles[index];
    if (tile.flipped || tile.matched) return;
    GameHaptics.tap();
    GameSounds.play(Sfx.tap);
    setState(() => tile.flipped = true);

    if (_firstIndex == null) {
      _firstIndex = index;
      return;
    }
    final first = _tiles[_firstIndex!];
    if (_isPair(first.card, tile.card)) {
      setState(() {
        first.matched = true;
        tile.matched = true;
        _firstIndex = null;
        if (_turnA) {
          _scoreA++;
        } else {
          _scoreB++;
        }
      });
      GameHaptics.light();
      GameSounds.play(Sfx.match);
      if (_tiles.every((t) => t.matched)) _handleWin();
    } else {
      _busy = true;
      final firstIndex = _firstIndex!;
      _firstIndex = null;
      GameSounds.play(Sfx.buzz);
      Timer(const Duration(milliseconds: 850), () {
        if (!mounted) return;
        setState(() {
          _tiles[firstIndex].flipped = false;
          _tiles[index].flipped = false;
          _busy = false;
          _turnA = !_turnA;
        });
      });
    }
  }

  void _handleWin() {
    setState(() => _finished = true);
    GameHaptics.success();
    GameSounds.play(Sfx.win);
    // A small reward keeps mini-games tied into progression.
    unawaited(ref.read(authControllerProvider.notifier).creditCoins(15));
  }

  void _restart() => setState(_deal);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.memoryTitle),
        actions: [
          IconButton(
            onPressed: () => HowToPlaySheet.show(
              context,
              emoji: '🧠',
              title: S.memoryTitle,
              rules: S.memoryRules,
            ),
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: S.howToPlayTitle,
          ),
          IconButton(
            onPressed: _restart,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: S.playAgain,
          ),
        ],
      ),
      body: ContentWidth(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Insets.m,
                Insets.m,
                Insets.m,
                Insets.xs,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _PlayerScore(
                    label: S.player1,
                    pairs: _scoreA,
                    active: _turnA && !_finished,
                  ),
                  SegmentedButton<_Difficulty>(
                    segments: [
                      for (final d in _Difficulty.values)
                        ButtonSegment(value: d, label: Text(d.label)),
                    ],
                    selected: {_difficulty},
                    showSelectedIcon: false,
                    onSelectionChanged: (s) => setState(() {
                      _difficulty = s.first;
                      _deal();
                    }),
                  ),
                  _PlayerScore(
                    label: S.player2,
                    pairs: _scoreB,
                    active: !_turnA && !_finished,
                  ),
                ],
              ),
            ),
            if (!_finished)
              Padding(
                padding: const EdgeInsets.only(bottom: Insets.xs),
                child: Text(
                  S.memoryTurnOf(_turnA ? S.player1 : S.player2),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(Insets.m),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _difficulty.columns,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: Insets.s,
                        mainAxisSpacing: Insets.s,
                      ),
                      itemCount: _tiles.length,
                      itemBuilder: (context, index) => _MemoryTile(
                        tile: _tiles[index],
                        onTap: () => _onTap(index),
                      ),
                    ),
                  ),
                  if (_finished)
                    Positioned.fill(
                      child: _WinOverlay(
                        scoreA: _scoreA,
                        scoreB: _scoreB,
                        onPlayAgain: _restart,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerScore extends StatelessWidget {
  const _PlayerScore({
    required this.label,
    required this.pairs,
    required this.active,
  });
  final String label;
  final int pairs;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: Insets.s, vertical: 6),
      decoration: BoxDecoration(
        color: active ? scheme.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(Corners.m),
        border: Border.all(
          color: active ? scheme.primary : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          Text(
            S.pairsLabel(pairs),
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _MemoryTile extends StatelessWidget {
  const _MemoryTile({required this.tile, required this.onTap});
  final _Tile tile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final faceUp = tile.flipped || tile.matched;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: tile.matched ? 0.45 : 1,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: SizedBox(
            key: ValueKey(faceUp),
            child: Center(
              child: UnoCardView(card: tile.card, width: 66, faceUp: faceUp),
            ),
          ),
        ),
      ),
    );
  }
}

class _WinOverlay extends StatelessWidget {
  const _WinOverlay({
    required this.scoreA,
    required this.scoreB,
    required this.onPlayAgain,
  });
  final int scoreA;
  final int scoreB;
  final VoidCallback onPlayAgain;

  @override
  Widget build(BuildContext context) {
    final draw = scoreA == scoreB;
    final winner = scoreA > scoreB ? S.player1 : S.player2;
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.55),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(draw ? '🤝' : '🎉', style: const TextStyle(fontSize: 56)),
            const SizedBox(height: Insets.m),
            Text(
              draw ? S.memoryDraw : S.memoryWinnerIs(winner),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Insets.xs),
            Text(
              '${S.player1}: ${S.pairsLabel(scoreA)}   ${S.player2}: ${S.pairsLabel(scoreB)}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: Insets.l),
            FilledButton.icon(
              onPressed: onPlayAgain,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(S.playAgain),
            ),
          ],
        ),
      ),
    );
  }
}
