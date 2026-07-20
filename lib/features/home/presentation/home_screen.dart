import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/constants/game_palette.dart';
import '../../../core/constants/insets.dart';
import '../../../core/constants/strings.dart';
import '../../../core/widgets/adaptive_scaffold.dart';
import '../../../core/widgets/coin_chip.dart';
import '../../../core/widgets/rank_badge.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../game/domain/game_mode.dart';
import '../../lobby/presentation/lobby_controller.dart';
import '../../minigames/domain/mini_game.dart';
import '../../missions/presentation/widgets/missions_card.dart';
import 'widgets/mode_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  GameMode _mode = GameMode.classic;

  void _playVsBots() {
    ref.read(lobbyControllerProvider.notifier).startVsBots(_mode);
    context.go(Routes.game);
  }

  void _playWithFriends() =>
      context.push('${Routes.lobby}?mode=${_mode.index}');

  Future<void> _tapMode(GameMode mode, bool locked) async {
    if (!locked) {
      setState(() => _mode = mode);
      return;
    }
    final signIn = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (_) => const _GuestGateSheet(),
    );
    if (signIn == true && mounted) unawaited(context.push(Routes.login));
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(authControllerProvider).value;
    final isGuest = profile?.isGuest ?? true;
    return Scaffold(
      appBar: AppBar(
        title: const Text(S.appName),
        actions: [
          if (!AppConfig.isOnline)
            const Padding(
              padding: EdgeInsets.only(right: Insets.s),
              child: Center(child: _LocalBadge()),
            ),
          IconButton(
            tooltip: S.leaderboardTitle,
            onPressed: () => context.push(Routes.leaderboard),
            icon: const Icon(Icons.emoji_events_outlined),
          ),
          if (profile != null)
            Padding(
              padding: const EdgeInsets.only(right: Insets.m),
              child: Center(child: CoinChip(coins: profile.coins)),
            ),
        ],
      ),
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.all(Insets.l),
          children: [
            if (profile != null)
              Text(
                S.greeting(profile.nickname),
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600),
              ),
            const SizedBox(height: Insets.m),
            _PlayHero(
              mode: _mode,
              onPlay: _playVsBots,
              onPlayWithFriends: _playWithFriends,
            ),
            const SizedBox(height: Insets.l),
            Text(S.chooseMode, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: Insets.s),
            _ModeGrid(
              selected: _mode,
              guestLocked: isGuest,
              onSelect: _tapMode,
            ),
            const SizedBox(height: Insets.l),
            if (profile != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(Insets.m),
                  child: RankBadge(points: profile.rankPoints),
                ),
              ),
            const SizedBox(height: Insets.m),
            const MissionsCard(),
            const SizedBox(height: Insets.l),
            Text(S.otherGames, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: Insets.s),
            const _OtherGamesGrid(),
          ],
        ),
      ),
    );
  }
}

class _OtherGamesGrid extends StatelessWidget {
  const _OtherGamesGrid();

  static String _routeFor(MiniGame game) => switch (game) {
    MiniGame.memory => Routes.memory,
    MiniGame.snap => Routes.snap,
    MiniGame.crazy8s => Routes.crazy8s,
  };

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 320,
        mainAxisExtent: 96,
        crossAxisSpacing: Insets.s,
        mainAxisSpacing: Insets.s,
      ),
      itemCount: MiniGame.values.length,
      itemBuilder: (context, index) {
        final game = MiniGame.values[index];
        return _MiniGameCard(
          game: game,
          onTap: () => context.push(_routeFor(game)),
        );
      },
    );
  }
}

class _MiniGameCard extends StatelessWidget {
  const _MiniGameCard({required this.game, required this.onTap});
  final MiniGame game;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Material(
      color: scheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(Corners.l),
      child: InkWell(
        borderRadius: BorderRadius.circular(Corners.l),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Insets.m),
          child: Row(
            children: [
              Text(game.emoji, style: const TextStyle(fontSize: 30)),
              const SizedBox(width: Insets.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      game.label,
                      style: theme.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      game.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall!.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: scheme.outline),
            ],
          ),
        ),
      ),
    );
  }
}

/// The single primary call-to-action: big, colorful, impossible to miss.
class _PlayHero extends StatelessWidget {
  const _PlayHero({
    required this.mode,
    required this.onPlay,
    required this.onPlayWithFriends,
  });
  final GameMode mode;
  final VoidCallback onPlay;
  final VoidCallback onPlayWithFriends;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(Insets.l),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [GamePalette.blue, GamePalette.wild],
        ),
        borderRadius: BorderRadius.circular(Corners.l),
        boxShadow: [
          BoxShadow(
            color: GamePalette.blue.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(mode.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: Insets.s),
              Expanded(
                child: Text(
                  mode.label,
                  style: theme.textTheme.titleLarge!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Insets.m),
          SizedBox(
            height: 52,
            child: FilledButton.icon(
              onPressed: onPlay,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: GamePalette.wild,
                textStyle: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              icon: const Icon(Icons.play_arrow_rounded),
              label: Text(S.playNow),
            ),
          ),
          const SizedBox(height: Insets.xs),
          TextButton.icon(
            onPressed: onPlayWithFriends,
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            icon: const Icon(Icons.people_alt_outlined, size: 18),
            label: Text(S.playWithFriends),
          ),
        ],
      ),
    );
  }
}

class _ModeGrid extends StatelessWidget {
  const _ModeGrid({
    required this.selected,
    required this.guestLocked,
    required this.onSelect,
  });
  final GameMode selected;
  final bool guestLocked;
  final void Function(GameMode mode, bool locked) onSelect;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 320,
        mainAxisExtent: 108,
        crossAxisSpacing: Insets.s,
        mainAxisSpacing: Insets.s,
      ),
      itemCount: GameMode.values.length,
      itemBuilder: (context, index) {
        final mode = GameMode.values[index];
        final locked = guestLocked && mode != GameMode.classic;
        return ModeCard(
          mode: mode,
          selected: mode == selected,
          locked: locked,
          onTap: () => onSelect(mode, locked),
        );
      },
    );
  }
}

class _GuestGateSheet extends StatelessWidget {
  const _GuestGateSheet();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(Insets.l, 0, Insets.l, Insets.l),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔒', style: TextStyle(fontSize: 40)),
          const SizedBox(height: Insets.s),
          Text(
            S.guestGateTitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: Insets.xs),
          Text(
            S.guestGateBody,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: Insets.l),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(S.signInNow),
            ),
          ),
          const SizedBox(height: Insets.xs),
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(S.maybeLater),
          ),
        ],
      ),
    );
  }
}

class _LocalBadge extends StatelessWidget {
  const _LocalBadge();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Insets.s,
        vertical: Insets.xs,
      ),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(Corners.s),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 14),
          const SizedBox(width: Insets.xs),
          Text(S.localModeBadge, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
