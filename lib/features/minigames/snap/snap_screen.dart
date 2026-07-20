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

class SnapScreen extends ConsumerStatefulWidget {
  const SnapScreen({super.key});

  @override
  ConsumerState<SnapScreen> createState() => _SnapScreenState();
}

class _SnapScreenState extends ConsumerState<SnapScreen> {
  final _rng = Random();
  late List<UnoCard> _deck;
  final List<UnoCard> _pile = [];
  UnoCard? _top;
  UnoCard? _prev;
  int _myCards = 0;
  int _botCards = 0;
  bool _matchOpen = false;
  bool _finished = false;
  String? _flash;

  Timer? _flipTimer;
  Timer? _botTimer;
  Timer? _flashTimer;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _flipTimer?.cancel();
    _botTimer?.cancel();
    _flashTimer?.cancel();
    super.dispose();
  }

  void _start() {
    final deck = <UnoCard>[];
    var id = 0;
    const colors = [
      CardColor.red,
      CardColor.yellow,
      CardColor.green,
      CardColor.blue,
    ];
    for (final c in colors) {
      for (var n = 0; n <= 9; n++) {
        deck.add(
          UnoCard(id: 's${id++}', color: c, type: CardType.number, number: n),
        );
      }
    }
    deck.shuffle(_rng);
    _flipTimer?.cancel();
    _botTimer?.cancel();
    setState(() {
      _deck = deck;
      _pile.clear();
      _top = null;
      _prev = null;
      _myCards = 0;
      _botCards = 0;
      _matchOpen = false;
      _finished = false;
      _flash = null;
    });
    _scheduleFlip(const Duration(milliseconds: 700));
  }

  void _scheduleFlip(Duration d) {
    _flipTimer?.cancel();
    _flipTimer = Timer(d, _flipNext);
  }

  bool _isMatch(UnoCard? a, UnoCard? b) {
    if (a == null || b == null) return false;
    return a.color == b.color || a.number == b.number;
  }

  void _flipNext() {
    if (!mounted) return;
    if (_deck.isEmpty) {
      _endGame();
      return;
    }
    final card = _deck.removeLast();
    setState(() {
      _prev = _top;
      _top = card;
      _pile.add(card);
    });
    if (_isMatch(_prev, _top)) {
      setState(() => _matchOpen = true);
      // Bot reacts after a beatable, randomized delay.
      _botTimer = Timer(
        Duration(milliseconds: 550 + _rng.nextInt(1000)),
        _botSnaps,
      );
    } else {
      // The pace quickens as the deck thins out — later flips come faster,
      // so the round builds tension instead of staying flat throughout.
      final dealt = _pile.length;
      final delay = (1050 - dealt * 14).clamp(500, 1050);
      _scheduleFlip(Duration(milliseconds: delay));
    }
  }

  void _playerSnaps() {
    if (_finished) return;
    if (_matchOpen) {
      _botTimer?.cancel();
      GameHaptics.medium();
      GameSounds.play(Sfx.snap);
      _awardPile(toMe: true, message: S.snapYouWon);
    } else {
      // Forgiving for kids: a nudge, a short lock-out, no card loss.
      GameHaptics.success();
      GameSounds.play(Sfx.buzz);
      _showFlash(S.snapTooSoon);
    }
  }

  void _botSnaps() {
    if (!mounted || _finished || !_matchOpen) return;
    _awardPile(toMe: false, message: S.snapBotWon);
  }

  void _awardPile({required bool toMe, required String message}) {
    final count = _pile.length;
    setState(() {
      _matchOpen = false;
      if (toMe) {
        _myCards += count;
      } else {
        _botCards += count;
      }
      _pile.clear();
      _top = null;
      _prev = null;
    });
    _showFlash(message);
    if (_deck.isEmpty) {
      _endGame();
    } else {
      _scheduleFlip(const Duration(milliseconds: 900));
    }
  }

  void _showFlash(String text) {
    _flashTimer?.cancel();
    setState(() => _flash = text);
    _flashTimer = Timer(const Duration(milliseconds: 1100), () {
      if (mounted) setState(() => _flash = null);
    });
  }

  void _endGame() {
    _flipTimer?.cancel();
    _botTimer?.cancel();
    setState(() => _finished = true);
    if (_myCards >= _botCards) {
      GameHaptics.success();
      GameSounds.play(Sfx.win);
      unawaited(ref.read(authControllerProvider.notifier).creditCoins(15));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(S.snapTitle),
        actions: [
          IconButton(
            onPressed: () => HowToPlaySheet.show(
              context,
              emoji: '👏',
              title: S.snapTitle,
              rules: S.snapRules,
            ),
            icon: const Icon(Icons.help_outline_rounded),
            tooltip: S.howToPlayTitle,
          ),
          IconButton(
            onPressed: _start,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: S.playAgain,
          ),
        ],
      ),
      body: ContentWidth(
        child: Column(
          children: [
            _ScoreRow(label: S.snapBotPile, count: _botCards, highlight: false),
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _PileView(
                        top: _top,
                        count: _pile.length,
                        matchOpen: _matchOpen,
                      ),
                      const SizedBox(height: Insets.m),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 150),
                        opacity: _matchOpen ? 1 : 0,
                        child: Text(
                          '👀',
                          style: theme.textTheme.headlineMedium,
                        ),
                      ),
                    ],
                  ),
                  if (_flash != null) _FlashLabel(text: _flash!),
                  if (_finished)
                    Positioned.fill(
                      child: _SnapWinOverlay(
                        myCards: _myCards,
                        botCards: _botCards,
                        onPlayAgain: _start,
                      ),
                    ),
                ],
              ),
            ),
            _ScoreRow(label: S.snapYourPile, count: _myCards, highlight: true),
            Padding(
              padding: const EdgeInsets.all(Insets.l),
              child: SizedBox(
                width: double.infinity,
                height: 64,
                child: FilledButton(
                  onPressed: _finished ? null : _playerSnaps,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  child: Text(S.snapButton),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: Insets.m),
              child: Text(
                S.snapTapWhenMatch,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PileView extends StatefulWidget {
  const _PileView({
    required this.top,
    required this.count,
    required this.matchOpen,
  });
  final UnoCard? top;
  final int count;
  final bool matchOpen;

  @override
  State<_PileView> createState() => _PileViewState();
}

class _PileViewState extends State<_PileView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 340),
  );

  @override
  void didUpdateWidget(_PileView old) {
    super.didUpdateWidget(old);
    if (widget.matchOpen && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.matchOpen && _pulse.isAnimating) {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) => Container(
        decoration: widget.matchOpen
            ? BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.redAccent.withValues(
                      alpha: 0.25 + _pulse.value * 0.35,
                    ),
                    blurRadius: 18 + _pulse.value * 14,
                    spreadRadius: 2 + _pulse.value * 4,
                  ),
                ],
              )
            : null,
        child: child,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: Tween<double>(begin: 1.2, end: 1).animate(animation),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: widget.top == null
                ? const SizedBox(
                    key: ValueKey('empty'),
                    width: 120,
                    height: 174,
                  )
                : UnoCardView(
                    key: ValueKey(widget.top!.id),
                    card: widget.top!,
                    width: 120,
                  ),
          ),
          if (widget.count > 0)
            Positioned(
              top: -10,
              right: -10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Insets.s,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.inverseSurface,
                  borderRadius: BorderRadius.circular(Corners.l),
                ),
                child: Text(
                  '${widget.count}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.label,
    required this.count,
    required this.highlight,
  });
  final String label;
  final int count;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: Insets.l,
        vertical: Insets.s,
      ),
      color: highlight
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.4)
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.titleSmall),
          Text(
            '$count 🃏',
            style: theme.textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _FlashLabel extends StatelessWidget {
  const _FlashLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Insets.l,
        vertical: Insets.s,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(Corners.l),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 18,
        ),
      ),
    );
  }
}

class _SnapWinOverlay extends StatelessWidget {
  const _SnapWinOverlay({
    required this.myCards,
    required this.botCards,
    required this.onPlayAgain,
  });
  final int myCards;
  final int botCards;
  final VoidCallback onPlayAgain;

  @override
  Widget build(BuildContext context) {
    final iWon = myCards >= botCards;
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
            const SizedBox(height: Insets.s),
            Text(
              '$myCards : $botCards',
              style: const TextStyle(color: Colors.white70, fontSize: 20),
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
