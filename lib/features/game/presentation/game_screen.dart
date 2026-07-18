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
        child: Column(
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
            _ActionBar(myTurn: myTurn, canUno: canUno, onUno: onUno),
            PlayerHand(state: state, myTurn: myTurn, onPlay: onPlay),
            const SizedBox(height: Insets.s),
            QuickChatBar(onSend: onChat),
            const SizedBox(height: Insets.s),
          ],
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
      child: Row(
        children: [
          IconButton(onPressed: onLeave, icon: const Icon(Icons.close_rounded)),
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
    final banner = describeEvent(state);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 28,
          child: chat != null
              ? ChatBubble(text: chat!)
              : (banner != null
                    ? Text(
                        banner,
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    : null),
        ),
        const SizedBox(height: Insets.s),
        Container(
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
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _DrawPile(
                count: state.drawPile.length,
                enabled: myTurn,
                cardBack: cardBack,
                onTap: onDraw,
              ),
              const SizedBox(width: Insets.xl),
              UnoCardView(card: state.topCard, width: 84),
            ],
          ),
        ),
        const SizedBox(height: Insets.m),
        AnimatedOpacity(
          opacity: myTurn ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: Chip(
            avatar: const Text('👉'),
            label: Text(S.yourTurn),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
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

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.myTurn,
    required this.canUno,
    required this.onUno,
  });
  final bool myTurn;
  final bool canUno;
  final VoidCallback onUno;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Insets.m,
        vertical: Insets.xs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FilledButton.icon(
            onPressed: canUno ? onUno : null,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              minimumSize: const Size(120, 48),
            ),
            icon: const Icon(Icons.pan_tool_alt_rounded),
            label: const Text(S.unoButton),
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
