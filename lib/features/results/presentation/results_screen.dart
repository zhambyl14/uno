import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/constants/insets.dart';
import '../../../core/constants/strings.dart';
import '../../../core/widgets/adaptive_scaffold.dart';
import '../../../core/widgets/avatar_circle.dart';
import '../../game/domain/match_result.dart';
import '../../game/presentation/game_controller.dart';
import 'widgets/confetti.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(lastResultProvider);
    if (result == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: ContentWidth(
              child: ListView(
                padding: const EdgeInsets.all(Insets.l),
                children: [
                  const SizedBox(height: Insets.l),
                  _Headline(result: result),
                  const SizedBox(height: Insets.l),
                  _RewardRow(result: result),
                  const SizedBox(height: Insets.l),
                  Text(
                    S.standings,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: Insets.s),
                  ...result.standings.asMap().entries.map(
                    (e) => _StandingTile(rank: e.key + 1, entry: e.value),
                  ),
                  const SizedBox(height: Insets.xl),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonalIcon(
                          onPressed: () => context.go(Routes.home),
                          icon: const Icon(Icons.home_rounded),
                          label: Text(S.goHome),
                        ),
                      ),
                      const SizedBox(width: Insets.s),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            ref.read(lastResultProvider.notifier).clear();
                            context.go(
                              '${Routes.lobby}?mode=${result.mode.index}',
                            );
                          },
                          icon: const Icon(Icons.replay_rounded),
                          label: Text(S.playAgain),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (result.isLocalWin) const Positioned.fill(child: Confetti()),
        ],
      ),
    );
  }
}

class _Headline extends StatelessWidget {
  const _Headline({required this.result});
  final MatchResult result;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          result.isLocalWin ? '🏆' : '🤝',
          style: const TextStyle(fontSize: 64),
        ),
        const SizedBox(height: Insets.s),
        Text(
          result.isLocalWin ? S.winTitle : S.goodGameTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: Insets.xs),
        Text(
          S.winnerLabel(result.winnerName),
          style: theme.textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class _RewardRow extends StatelessWidget {
  const _RewardRow({required this.result});
  final MatchResult result;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _RewardChip(emoji: '⭐', text: S.xpGained(result.xpGain)),
        const SizedBox(width: Insets.s),
        _RewardChip(emoji: '🪙', text: S.coinsGained(result.coinGain)),
        const SizedBox(width: Insets.s),
        _RewardChip(emoji: '📈', text: S.rankGained(result.rankGain)),
      ],
    );
  }
}

class _RewardChip extends StatelessWidget {
  const _RewardChip({required this.emoji, required this.text});
  final String emoji;
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Insets.m,
        vertical: Insets.s,
      ),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer,
        borderRadius: BorderRadius.circular(Corners.l),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji),
          const SizedBox(width: Insets.xs),
          Text(
            text,
            style: TextStyle(
              color: scheme.onSecondaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _StandingTile extends StatelessWidget {
  const _StandingTile({required this.rank, required this.entry});
  final int rank;
  final StandingEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: entry.isLocal ? theme.colorScheme.primaryContainer : null,
      child: ListTile(
        leading: SizedBox(
          width: 32,
          child: Center(
            child: Text(
              '$rank',
              style: theme.textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            AvatarCircle(avatarId: entry.avatarId, size: 32),
            const SizedBox(width: Insets.s),
            Flexible(child: Text(entry.name, overflow: TextOverflow.ellipsis)),
          ],
        ),
        trailing: Text(
          S.cardsCount(entry.cardsLeft),
          style: theme.textTheme.bodySmall,
        ),
      ),
    );
  }
}
