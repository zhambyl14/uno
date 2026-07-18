import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/constants/insets.dart';
import '../../../core/constants/strings.dart';
import '../../../core/widgets/adaptive_scaffold.dart';
import '../../../core/widgets/coin_chip.dart';
import '../../../core/widgets/rank_badge.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../game/domain/game_mode.dart';
import '../../lobby/presentation/lobby_controller.dart';
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

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(authControllerProvider).value;
    return Scaffold(
      appBar: AppBar(
        title: const Text(S.appName),
        actions: [
          if (!AppConfig.isOnline)
            const Padding(
              padding: EdgeInsets.only(right: Insets.s),
              child: Center(child: _LocalBadge()),
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
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: Insets.l),
            Text(S.chooseMode, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: Insets.s),
            _ModeGrid(
              selected: _mode,
              onSelect: (m) => setState(() => _mode = m),
            ),
            const SizedBox(height: Insets.l),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _playVsBots,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 56),
                    ),
                    icon: const Icon(Icons.smart_toy_outlined),
                    label: Text(S.playVsBots),
                  ),
                ),
                const SizedBox(width: Insets.s),
                Expanded(
                  child: FilledButton.tonalIcon(
                    onPressed: _playWithFriends,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 56),
                    ),
                    icon: const Icon(Icons.people_alt_outlined),
                    label: Text(S.playWithFriends),
                  ),
                ),
              ],
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
          ],
        ),
      ),
    );
  }
}

class _ModeGrid extends StatelessWidget {
  const _ModeGrid({required this.selected, required this.onSelect});
  final GameMode selected;
  final ValueChanged<GameMode> onSelect;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 320,
        mainAxisExtent: 116,
        crossAxisSpacing: Insets.s,
        mainAxisSpacing: Insets.s,
      ),
      itemCount: GameMode.values.length,
      itemBuilder: (context, index) {
        final mode = GameMode.values[index];
        return ModeCard(
          mode: mode,
          selected: mode == selected,
          onTap: () => onSelect(mode),
        );
      },
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
