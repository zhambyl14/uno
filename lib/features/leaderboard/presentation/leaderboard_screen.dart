import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_config.dart';
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
      data: (list) => ListView.builder(
        padding: const EdgeInsets.all(Insets.l),
        itemCount: list.length,
        itemBuilder: (context, index) {
          final entry = list[index];
          return _LeaderboardTile(
            rank: index + 1,
            nickname: entry.nickname,
            avatarId: entry.avatarId,
            points: entry.rankPoints,
            isMe: entry.id == myId,
          );
        },
      ),
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
