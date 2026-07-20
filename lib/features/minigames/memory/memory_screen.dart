import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/insets.dart';
import '../../../core/constants/strings.dart';
import '../../../core/widgets/adaptive_scaffold.dart';
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
  int _moves = 0;
  bool _won = false;

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
    _moves = 0;
    _won = false;
  }

  bool _isPair(UnoCard a, UnoCard b) =>
      a.color == b.color && a.number == b.number;

  void _onTap(int index) {
    if (_busy || _won) return;
    final tile = _tiles[index];
    if (tile.flipped || tile.matched) return;
    HapticFeedback.selectionClick();
    setState(() => tile.flipped = true);

    if (_firstIndex == null) {
      _firstIndex = index;
      return;
    }
    final first = _tiles[_firstIndex!];
    setState(() => _moves++);
    if (_isPair(first.card, tile.card)) {
      setState(() {
        first.matched = true;
        tile.matched = true;
        _firstIndex = null;
      });
      HapticFeedback.lightImpact();
      if (_tiles.every((t) => t.matched)) _handleWin();
    } else {
      _busy = true;
      final firstIndex = _firstIndex!;
      _firstIndex = null;
      Timer(const Duration(milliseconds: 750), () {
        if (!mounted) return;
        setState(() {
          _tiles[firstIndex].flipped = false;
          _tiles[index].flipped = false;
          _busy = false;
        });
      });
    }
  }

  void _handleWin() {
    setState(() => _won = true);
    HapticFeedback.heavyImpact();
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
              padding: const EdgeInsets.all(Insets.m),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _Stat(label: S.moves, value: '$_moves'),
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
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(Insets.m),
                    child: GridView.builder(
                      gridDelegate:
                          SliverGridDelegateWithFixedCrossAxisCount(
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
                  if (_won)
                    Positioned.fill(
                      child: _WinOverlay(moves: _moves, onPlayAgain: _restart),
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
              child: UnoCardView(
                card: tile.card,
                width: 66,
                faceUp: faceUp,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall),
        Text(
          value,
          style: theme.textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _WinOverlay extends StatelessWidget {
  const _WinOverlay({required this.moves, required this.onPlayAgain});
  final int moves;
  final VoidCallback onPlayAgain;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.55),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 56)),
            const SizedBox(height: Insets.m),
            Text(
              S.memoryWon(moves),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
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
