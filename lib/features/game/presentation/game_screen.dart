import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/constants/insets.dart';
import '../../../core/constants/strings.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../shop/domain/shop_item.dart';
import '../domain/game_action.dart';
import '../domain/game_state.dart';
import '../domain/uno_card.dart';
import 'game_controller.dart';
import 'game_event_text.dart';
import 'widgets/color_picker_sheet.dart';
import 'widgets/game_event_fx.dart';
import 'widgets/opponent_seat.dart';
import 'widgets/player_hand.dart';
import 'widgets/quick_chat_bar.dart';
import 'widgets/turn_timer.dart';
import 'widgets/uno_card_view.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  bool _ending = false;
  String? _chat;
  Timer? _chatTimer;

  @override
  void dispose() {
    _chatTimer?.cancel();
    super.dispose();
  }

  String? get _localId => ref.read(gameControllerProvider)?.localPlayerId;

  void _onState(GameState state) {
    if (state.phase == GamePhase.finished && !_ending) {
      _ending = true;
      _chatTimer?.cancel();
      Future.delayed(const Duration(milliseconds: 900), () async {
        await ref.read(gameControllerProvider.notifier).endAndAward();
        if (mounted) context.go(Routes.results);
      });
    }
  }

  Future<void> _play(GameState state, UnoCard card) async {
    final id = _localId;
    if (id == null) return;
    CardColor? chosen;
    if (card.needsColorChoice) {
      chosen = await ColorPickerSheet.show(context);
      if (chosen == null) return;
    }
    ref
        .read(gameControllerProvider.notifier)
        .submit(PlayCardAction(id, cardId: card.id, chosenColor: chosen));
  }

  void _draw() {
    final id = _localId;
    if (id == null) return;
    ref.read(gameControllerProvider.notifier).submit(DrawCardAction(id));
  }

  void _sayUno() {
    final id = _localId;
    if (id == null) return;
    ref.read(gameControllerProvider.notifier).submit(SayUnoAction(id));
  }

  void _pass() {
    final id = _localId;
    if (id == null) return;
    ref.read(gameControllerProvider.notifier).submit(PassAction(id));
  }

  void _showChat(String phrase) {
    _chatTimer?.cancel();
    setState(() => _chat = phrase);
    _chatTimer = Timer(
      const Duration(seconds: 2),
      () => mounted ? setState(() => _chat = null) : null,
    );
  }

  Future<void> _confirmLeave() async {
    final leave = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(S.leaveGameTitle),
        content: Text(S.leaveGameConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(S.stay),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(S.leave),
          ),
        ],
      ),
    );
    if (leave == true && mounted) {
      _ending = true;
      await ref.read(gameControllerProvider.notifier).endAndAward();
      if (mounted) context.go(Routes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(gameStateProvider, (_, next) {
      final state = next.value;
      if (state != null) _onState(state);
    });
    final async = ref.watch(gameStateProvider);
    final profile = ref.watch(authControllerProvider).value;
    final tableTheme = TableTheme.byId(profile?.tableThemeId ?? 'theme_green');
    final cardBack = CardSkin.byId(profile?.cardSkinId ?? 'skin_classic').back;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmLeave();
      },
      child: Scaffold(
        body: SafeArea(
          child: async.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, _) => _NoGame(onExit: () => context.go(Routes.home)),
            data: (state) => _GameBoard(
              state: state,
              localId: _localId,
              chat: _chat,
              tableTheme: tableTheme,
              cardBack: cardBack,
              onLeave: _confirmLeave,
              onPlay: (card) => _play(state, card),
              onDraw: _draw,
              onUno: _sayUno,
              onPass: _pass,
              onChat: _showChat,
            ),
          ),
        ),
      ),
    );
  }
}

class _GameBoard extends StatelessWidget {
  const _GameBoard({
    required this.state,
    required this.localId,
    required this.chat,
    required this.tableTheme,
    required this.cardBack,
    required this.onLeave,
    required this.onPlay,
    required this.onDraw,
    required this.onUno,
    required this.onPass,
    required this.onChat,
  });

  final GameState state;
  final String? localId;
  final String? chat;
  final TableTheme tableTheme;
  final Color cardBack;
  final VoidCallback onLeave;
  final ValueChanged<UnoCard> onPlay;
  final VoidCallback onDraw;
  final VoidCallback onUno;
  final VoidCallback onPass;
  final ValueChanged<String> onChat;

  @override
  Widget build(BuildContext context) {
    final me =
        state.playerById(localId ?? '') ??
        state.players.firstWhere(
          (p) => !p.isBot,
          orElse: () => state.players.first,
        );
    final myTurn =
        state.currentPlayer.id == me.id && state.phase == GamePhase.playing;
    final opponents = state.players.where((p) => p.id != me.id).toList();
    final canUno = me.hand.length == 2 && !me.saidUno;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.15),
              radius: 1.1,
              colors: [
                tableTheme.top.withValues(alpha: 0.96),
                tableTheme.bottom,
              ],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              GameEventBurst(
                event: state.event,
                trigger:
                    '${state.topCard.id}:${state.event?.type}:${state.currentIndex}',
              ),
              Column(
                children: [
                  _TopBar(state: state, onLeave: onLeave),
                  const SizedBox(height: Insets.s),
                  _OpponentsRow(
                    opponents: opponents,
                    currentId: state.currentPlayer.id,
                  ),
                  Expanded(
                    child: _CenterArea(
                      state: state,
                      myTurn: myTurn,
                      chat: chat,
                      tableTheme: tableTheme,
                      cardBack: cardBack,
                      onDraw: onDraw,
                    ),
                  ),
                  _ActionBar(
                    myTurn: myTurn,
                    canUno: canUno,
                    canPass: myTurn && state.drawnCardId != null,
                    onUno: onUno,
                    onPass: onPass,
                  ),
                  PlayerHand(
                    state: state,
                    playerId: me.id,
                    myTurn: myTurn,
                    onPlay: onPlay,
                  ),
                  const SizedBox(height: Insets.s),
                  QuickChatBar(onSend: onChat),
                  const SizedBox(height: Insets.s),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.state, required this.onLeave});
  final GameState state;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final seconds = state.mode.turnSeconds;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Insets.s),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: Insets.xs),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(Corners.l),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: onLeave,
              icon: const Icon(Icons.close_rounded),
            ),
            Text(
              '${state.mode.emoji} ${state.mode.label}',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const Spacer(),
            ActiveColorDot(color: state.activeColor),
            const SizedBox(width: Insets.m),
            if (seconds != null && state.turnEndsAt != null)
              TurnTimer(endsAt: state.turnEndsAt!, totalSeconds: seconds),
          ],
        ),
      ),
    );
  }
}

class _OpponentsRow extends StatelessWidget {
  const _OpponentsRow({required this.opponents, required this.currentId});
  final List<GamePlayer> opponents;
  final String currentId;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: Insets.m),
        itemCount: opponents.length,
        separatorBuilder: (_, _) => const SizedBox(width: Insets.s),
        itemBuilder: (context, index) {
          final player = opponents[index];
          return OpponentSeat(
            player: player,
            isCurrent: player.id == currentId,
          );
        },
      ),
    );
  }
}

class _CenterArea extends StatelessWidget {
  const _CenterArea({
    required this.state,
    required this.myTurn,
    required this.chat,
    required this.tableTheme,
    required this.cardBack,
    required this.onDraw,
  });
  final GameState state;
  final bool myTurn;
  final String? chat;
  final TableTheme tableTheme;
  final Color cardBack;
  final VoidCallback onDraw;

  @override
  Widget build(BuildContext context) {
    final banner =
        describeEvent(state) ??
        (myTurn ? S.yourTurn : S.turnOf(state.currentPlayer.name));
    final canDraw = myTurn && state.drawnCardId == null;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        chat != null
            ? SizedBox(height: 42, child: ChatBubble(text: chat!))
            : GameEventBanner(
                message: banner,
                event: state.event,
                isMyTurn: myTurn,
              ),
        const SizedBox(height: Insets.s),
        AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          margin: const EdgeInsets.symmetric(horizontal: Insets.l),
          padding: const EdgeInsets.symmetric(
            horizontal: Insets.xl,
            vertical: Insets.l,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [tableTheme.top, tableTheme.bottom],
            ),
            borderRadius: BorderRadius.circular(Corners.l),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: (myTurn ? tableTheme.top : Colors.black).withValues(
                  alpha: myTurn ? 0.38 : 0.18,
                ),
                blurRadius: myTurn ? 26 : 12,
                spreadRadius: myTurn ? 1 : 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _DrawPile(
                count: state.drawPile.length,
                enabled: canDraw,
                cardBack: cardBack,
                onTap: onDraw,
              ),
              const SizedBox(width: Insets.xl),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: UnoCardView(
                  key: ValueKey(state.topCard.id),
                  card: state.topCard,
                  width: 84,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Insets.m),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: state.drawnCardId != null && myTurn
              ? Text(
                  S.drawnCardHint,
                  key: const ValueKey('drawn-hint'),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : const SizedBox(key: ValueKey('empty-hint')),
        ),
      ],
    );
  }
}

class _DrawPile extends StatelessWidget {
  const _DrawPile({
    required this.count,
    required this.enabled,
    required this.cardBack,
    required this.onTap,
  });
  final int count;
  final bool enabled;
  final Color cardBack;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: enabled ? onTap : null,
          child: Opacity(
            opacity: enabled ? 1 : 0.7,
            child: UnoCardView(
              card: const UnoCard(
                id: 'back',
                color: CardColor.wild,
                type: CardType.wild,
              ),
              width: 84,
              faceUp: false,
              backColor: cardBack,
            ),
          ),
        ),
        const SizedBox(height: Insets.xs),
        Text(
          '${S.drawPileLabel} ($count)',
          style: Theme.of(
            context,
          ).textTheme.labelSmall!.copyWith(color: Colors.white),
        ),
      ],
    );
  }
}

class _ActionBar extends StatefulWidget {
  const _ActionBar({
    required this.myTurn,
    required this.canUno,
    required this.canPass,
    required this.onUno,
    required this.onPass,
  });
  final bool myTurn;
  final bool canUno;
  final bool canPass;
  final VoidCallback onUno;
  final VoidCallback onPass;

  @override
  State<_ActionBar> createState() => _ActionBarState();
}

class _ActionBarState extends State<_ActionBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 550),
  )..addListener(() => setState(() {}));

  @override
  void initState() {
    super.initState();
    if (widget.canUno) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(_ActionBar old) {
    super.didUpdateWidget(old);
    if (widget.canUno && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.canUno && _pulse.isAnimating) {
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
    final scale = widget.canUno ? 1 + _pulse.value * 0.08 : 1.0;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Insets.m,
        vertical: Insets.xs,
      ),
      child: Wrap(
        spacing: Insets.s,
        runSpacing: Insets.xs,
        alignment: WrapAlignment.center,
        children: [
          if (widget.canPass)
            OutlinedButton.icon(
              onPressed: widget.onPass,
              icon: const Icon(Icons.skip_next_rounded),
              label: Text(S.finishTurn),
            ),
          Transform.scale(
            scale: scale,
            child: FilledButton.icon(
              onPressed: widget.canUno ? widget.onUno : null,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(120, 48),
              ),
              icon: const Icon(Icons.pan_tool_alt_rounded),
              label: const Text(S.unoButton),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoGame extends StatelessWidget {
  const _NoGame({required this.onExit});
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🃏', style: TextStyle(fontSize: 48)),
          const SizedBox(height: Insets.m),
          FilledButton(onPressed: onExit, child: Text(S.goHome)),
        ],
      ),
    );
  }
}
