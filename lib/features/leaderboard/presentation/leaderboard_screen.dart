import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/constants/game_palette.dart';
import '../../../core/constants/insets.dart';
import '../../../core/constants/strings.dart';
import '../../../core/widgets/adaptive_scaffold.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/avatar_circle.dart';
import '../../../core/widgets/status_views.dart';
import '../../auth/presentation/auth_controller.dart';
import '../domain/leaderboard_entry.dart';
import 'leaderboard_controller.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(S.leaderboardTitle)),
      body: ContentWidth(
        child: AppConfig.isOnline
            ? _OnlineLeaderboard(
                myId: ref.watch(authControllerProvider).value?.id,
              )
            : EmptyView(
                emoji: '🌐',
                title: S.onlineOnlyTitle,
                hint: S.onlineOnlyBody,
              ),
      ),
    );
  }
}

class _OnlineLeaderboard extends ConsumerWidget {
  const _OnlineLeaderboard({required this.myId});
  final String? myId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(leaderboardControllerProvider);
    return AsyncView<List<LeaderboardEntry>>(
      value: entries,
      onRetry: () => ref.invalidate(leaderboardControllerProvider),
      isEmpty: (data) => data.isEmpty,
      empty: EmptyView(emoji: '🏆', title: S.leaderboardEmpty),
      data: (list) {
        final hasPodium = list.length >= 3;
        final podium = hasPodium ? list.sublist(0, 3) : const <LeaderboardEntry>[];
        final rest = hasPodium ? list.sublist(3) : list;
        return Column(
          children: [
            if (hasPodium) _Podium(top3: podium),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(Insets.l),
                itemCount: rest.length,
                itemBuilder: (context, index) {
                  final entry = rest[index];
                  return _LeaderboardTile(
                    rank: index + (hasPodium ? 4 : 1),
                    nickname: entry.nickname,
                    avatarId: entry.avatarId,
                    points: entry.rankPoints,
                    isMe: entry.id == myId,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Top-3 podium: the redesign's headline leaderboard moment, before the
/// plain ranked list for everyone else.
class _Podium extends StatelessWidget {
  const _Podium({required this.top3});
  final List<LeaderboardEntry> top3;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        Insets.l,
        Insets.l,
        Insets.l,
        Insets.xl,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: GamePalette.brandGradient,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _PodiumColumn(
            entry: top3[1],
            rank: 2,
            avatarSize: 44,
            barHeight: 44,
            barColor: const Color(0xFFC9C9D6),
          ),
          const SizedBox(width: Insets.s),
          _PodiumColumn(
            entry: top3[0],
            rank: 1,
            avatarSize: 58,
            barHeight: 62,
            barColor: const Color(0xFFFFD84D),
            crown: true,
          ),
          const SizedBox(width: Insets.s),
          _PodiumColumn(
            entry: top3[2],
            rank: 3,
            avatarSize: 44,
            barHeight: 34,
            barColor: const Color(0xFFE0B98C),
          ),
        ],
      ),
    );
  }
}

class _PodiumColumn extends StatelessWidget {
  const _PodiumColumn({
    required this.entry,
    required this.rank,
    required this.avatarSize,
    required this.barHeight,
    required this.barColor,
    this.crown = false,
  });
  final LeaderboardEntry entry;
  final int rank;
  final double avatarSize;
  final double barHeight;
  final Color barColor;
  final bool crown;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (crown)
          const Text('👑', style: TextStyle(fontSize: 18))
        else
          const SizedBox(height: 22),
        AvatarCircle(avatarId: entry.avatarId, size: avatarSize),
        const SizedBox(height: Insets.xs),
        SizedBox(
          width: avatarSize + 18,
          child: Text(
            entry.nickname,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: Insets.xs),
        Container(
          width: avatarSize + 10,
          height: barHeight,
          alignment: Alignment.topCenter,
          padding: const EdgeInsets.only(top: 6),
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(Corners.m),
            ),
          ),
          child: Text(
            '$rank',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Color(0xFF3A3A46),
            ),
          ),
        ),
      ],
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  const _LeaderboardTile({
    required this.rank,
    required this.nickname,
    required this.avatarId,
    required this.points,
    required this.isMe,
  });
  final int rank;
  final String nickname;
  final String avatarId;
  final int points;
  final bool isMe;

  static const _medals = ['🥇', '🥈', '🥉'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: isMe ? theme.colorScheme.primaryContainer : null,
      child: ListTile(
        leading: SizedBox(
          width: 32,
          child: Center(
            child: rank <= 3
                ? Text(_medals[rank - 1], style: const TextStyle(fontSize: 20))
                : Text(
                    '$rank',
                    style: theme.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        title: Row(
          children: [
            AvatarCircle(avatarId: avatarId, size: 36),
            const SizedBox(width: Insets.s),
            Flexible(
              child: Text(
                isMe ? '$nickname (${S.leaderboardYou})' : nickname,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
        trailing: Text(
          S.rankPointsLabel(points),
          style: theme.textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
