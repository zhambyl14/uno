import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/insets.dart';
import '../../../../core/constants/strings.dart';
import '../../../../core/widgets/adaptive_scaffold.dart';
import '../../../auth/presentation/auth_controller.dart';
import '../domain/playing_card.dart';

class Crazy8sScreen extends ConsumerStatefulWidget {
  const Crazy8sScreen({super.key});

  @override
  ConsumerState<Crazy8sScreen> createState() => _Crazy8sScreenState();
}

class _Crazy8sScreenState extends ConsumerState<Crazy8sScreen> {
  final _rng = Random();
  late List<PlayingCard> _stock;
  late List<PlayingCard> _myHand;
  late List<PlayingCard> _botHand;
  late PlayingCard _top;
  late Suit _activeSuit;
  bool _myTurn = true;
  bool _finished = false;
  bool _iWon = false;
  int _passStreak = 0;
  String? _message;
  Timer? _botTimer;

  @override
  void initState() {
    super.initState();
    _deal();
  }

  @override
  void dispose() {
    _botTimer?.cancel();
    super.dispose();
  }

  void _deal() {
    _botTimer?.cancel();
    final deck = PlayingCard.shuffledDeck(_rng);
    _myHand = [for (var i = 0; i < 7; i++) deck.removeLast()];
    _botHand = [for (var i = 0; i < 7; i++) deck.removeLast()];
    // Start on a non-wild card so the opening suit is unambiguous.
    var top = deck.removeLast();
    while (top.isWild) {
      deck.insert(0, top);
      top = deck.removeLast();
    }
    setState(() {
      _stock = deck;
      _top = top;
      _activeSuit = top.suit;
      _myTurn = true;
      _finished = false;
      _iWon = false;
      _passStreak = 0;
      _message = null;
    });
  }

  bool _canPlay(PlayingCard card) =>
      card.isWild || card.suit == _activeSuit || card.rank == _top.rank;

  Future<void> _playMine(PlayingCard card) async {
    if (!_myTurn || _finished || !_canPlay(card)) return;
    Suit suit = card.suit;
    if (card.isWild) {
      final chosen = await _pickSuit();
      if (chosen == null || !mounted) return;
      suit = chosen;
    }
    _apply(card, suit, fromMe: true);
  }

  void _apply(PlayingCard card, Suit suit, {required bool fromMe}) {
    HapticFeedback.selectionClick();
    setState(() {
      (fromMe ? _myHand : _botHand).remove(card);
      _top = card;
      _activeSuit = suit;
      _passStreak = 0;
    });
    if ((fromMe ? _myHand : _botHand).isEmpty) {
      _endGame(iWon: fromMe);
      return;
    }
    _handOff(toMe: !fromMe);
  }

  void _drawMine() {
    if (!_myTurn || _finished) return;
    if (_stock.isEmpty) {
      _passTurn(fromMe: true);
      return;
    }
    HapticFeedback.selectionClick();
    setState(() {
      _myHand.add(_stock.removeLast());
      _passStreak = 0;
    });
    _handOff(toMe: false);
  }

  void _passTurn({required bool fromMe}) {
    _passStreak++;
    if (_passStreak >= 2) {
      _endGame(iWon: _myHand.length <= _botHand.length);
      return;
    }
    _handOff(toMe: !fromMe);
  }

  void _handOff({required bool toMe}) {
    setState(() {
      _myTurn = toMe;
      _message = toMe ? S.yourTurnShort : S.botThinking;
    });
    if (!toMe) {
      _botTimer = Timer(
        Duration(milliseconds: 800 + _rng.nextInt(600)),
        _botTurn,
      );
    }
  }

  void _botTurn() {
    if (!mounted || _finished) return;
    final playable = _botHand.where(_canPlay).toList();
    if (playable.isEmpty) {
      if (_stock.isEmpty) {
        _passTurn(fromMe: false);
      } else {
        setState(() {
          _botHand.add(_stock.removeLast());
          _passStreak = 0;
        });
        _handOff(toMe: true);
      }
      return;
    }
    // Prefer a matching non-wild; hold 8s for when they're needed.
    playable.sort((a, b) => (a.isWild ? 1 : 0).compareTo(b.isWild ? 1 : 0));
    final card = playable.first;
    final suit = card.isWild ? _botBestSuit(card) : card.suit;
    _apply(card, suit, fromMe: false);
  }

  Suit _botBestSuit(PlayingCard exclude) {
    final counts = <Suit, int>{};
    for (final c in _botHand) {
      if (identical(c, exclude) || c.isWild) continue;
      counts[c.suit] = (counts[c.suit] ?? 0) + 1;
    }
    if (counts.isEmpty) return Suit.values[_rng.nextInt(4)];
    return counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  Future<Suit?> _pickSuit() => showModalBottomSheet<Suit>(
    context: context,
    showDragHandle: true,
    builder: (_) => _SuitPicker(),
  );

  void _endGame({required bool iWon}) {
    _botTimer?.cancel();
    setState(() {
      _finished = true;
      _iWon = iWon;
      _message = null;
    });
    if (iWon) {
      HapticFeedback.heavyImpact();
      unawaited(ref.read(authControllerProvider.notifier).creditCoins(20));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.crazy8sTitle),
        actions: [
          IconButton(
            onPressed: _deal,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: S.playAgain,
          ),
        ],
      ),
      body: ContentWidth(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: Insets.m),
                _BotRow(count: _botHand.length),
                const Spacer(),
                _TableCenter(
                  top: _top,
                  activeSuit: _activeSuit,
                  stockCount: _stock.length,
                  onDraw: _myTurn && !_finished ? _drawMine : null,
                  message: _message,
                ),
                const Spacer(),
                _MyHand(
                  hand: _myHand,
                  canPlay: (c) => _myTurn && !_finished && _canPlay(c),
                  onPlay: _playMine,
                ),
                const SizedBox(height: Insets.m),
              ],
            ),
            if (_finished)
              Positioned.fill(
                child: _Crazy8sOverlay(iWon: _iWon, onPlayAgain: _deal),
              ),
          ],
        ),
      ),
    );
  }
}

class _TableCenter extends StatelessWidget {
  const _TableCenter({
    required this.top,
    required this.activeSuit,
    required this.stockCount,
    required this.onDraw,
    required this.message,
  });
  final PlayingCard top;
  final Suit activeSuit;
  final int stockCount;
  final VoidCallback? onDraw;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        if (message != null)
          Padding(
            padding: const EdgeInsets.only(bottom: Insets.s),
            child: Text(
              message!,
              style: theme.textTheme.titleSmall!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Stock (draw).
            Column(
              children: [
                GestureDetector(
                  onTap: onDraw,
                  child: Opacity(
                    opacity: onDraw == null ? 0.5 : 1,
                    child: const _CardBack(width: 76),
                  ),
                ),
                const SizedBox(height: Insets.xs),
                Text('${S.drawCard} ($stockCount)',
                    style: theme.textTheme.labelSmall),
              ],
            ),
            const SizedBox(width: Insets.xl),
            // Discard top + active suit badge.
            Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    PlayingCardView(card: top, width: 92),
                    Positioned(
                      top: -8,
                      right: -8,
                      child: Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black12),
                          boxShadow: const [
                            BoxShadow(color: Colors.black26, blurRadius: 4),
                          ],
                        ),
                        child: Text(
                          activeSuit.symbol,
                          style: TextStyle(
                            color: activeSuit.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _MyHand extends StatelessWidget {
  const _MyHand({
    required this.hand,
    required this.canPlay,
    required this.onPlay,
  });
  final List<PlayingCard> hand;
  final bool Function(PlayingCard) canPlay;
  final ValueChanged<PlayingCard> onPlay;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Insets.m),
        physics: const BouncingScrollPhysics(),
        itemCount: hand.length,
        separatorBuilder: (_, _) => const SizedBox(width: Insets.xs),
        itemBuilder: (context, index) {
          final card = hand[index];
          final playable = canPlay(card);
          return GestureDetector(
            onTap: playable ? () => onPlay(card) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              transform: Matrix4.translationValues(0, playable ? -10 : 0, 0),
              child: Opacity(
                opacity: playable ? 1 : 0.6,
                child: PlayingCardView(card: card, width: 80),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BotRow extends StatelessWidget {
  const _BotRow({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🤖', style: TextStyle(fontSize: 26)),
        const SizedBox(width: Insets.s),
        Text(
          '$count 🂠',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class PlayingCardView extends StatelessWidget {
  const PlayingCardView({super.key, required this.card, this.width = 80});
  final PlayingCard card;
  final double width;

  @override
  Widget build(BuildContext context) {
    final height = width * 1.4;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Corners.card),
        border: Border.all(color: Colors.black12, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              card.label,
              style: TextStyle(
                color: card.suit.color,
                fontWeight: FontWeight.w900,
                fontSize: width * 0.24,
                height: 1,
              ),
            ),
          ),
          Center(
            child: Text(
              card.suit.symbol,
              style: TextStyle(color: card.suit.color, fontSize: width * 0.5),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              card.label,
              style: TextStyle(
                color: card.suit.color,
                fontWeight: FontWeight.w900,
                fontSize: width * 0.24,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  const _CardBack({required this.width});
  final double width;

  @override
  Widget build(BuildContext context) {
    final height = width * 1.4;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5B6CF0), Color(0xFF3B3B54)],
        ),
        borderRadius: BorderRadius.circular(Corners.card),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: const Center(
        child: Text('🎴', style: TextStyle(fontSize: 26)),
      ),
    );
  }
}

class _SuitPicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Insets.l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              S.chooseSuit,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Insets.m),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final suit in Suit.values)
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(suit),
                    child: Container(
                      width: 64,
                      height: 64,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(Corners.m),
                      ),
                      child: Text(
                        suit.symbol,
                        style: TextStyle(color: suit.color, fontSize: 34),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Crazy8sOverlay extends StatelessWidget {
  const _Crazy8sOverlay({required this.iWon, required this.onPlayAgain});
  final bool iWon;
  final VoidCallback onPlayAgain;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(iWon ? '🏆' : '🤖', style: const TextStyle(fontSize: 56)),
            const SizedBox(height: Insets.m),
            Text(
              iWon ? S.youWon : S.botWon,
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
