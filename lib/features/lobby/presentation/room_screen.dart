import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/constants/insets.dart';
import '../../../core/constants/strings.dart';
import '../../../core/utils/ui_feedback.dart';
import '../../../core/widgets/adaptive_scaffold.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/avatar_circle.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../friends/domain/friend.dart';
import '../../friends/presentation/friends_controller.dart';
import '../domain/room.dart';
import 'room_controller.dart';

class RoomScreen extends ConsumerStatefulWidget {
  const RoomScreen({super.key, required this.code});
  final String code;

  @override
  ConsumerState<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends ConsumerState<RoomScreen> {
  bool _navigated = false;

  void _onRoom(Room? room) {
    if (room == null || _navigated) return;
    final me = ref.read(authControllerProvider).value;
    final amHost = me != null && room.isHostId(me.id);

    if (room.status == RoomStatus.closed) {
      _navigated = true;
      context.showSnack(S.roomClosed);
      context.go(Routes.home);
      return;
    }
    // A non-host client jumps into the match once the host starts it.
    if (room.status == RoomStatus.playing && !amHost) {
      _navigated = true;
      unawaited(_joinAsClient(room));
    }
  }

  Future<void> _joinAsClient(Room room) async {
    final ok = await ref
        .read(roomControllerProvider.notifier)
        .joinAsClient(room);
    if (!mounted) return;
    if (ok) {
      context.go(Routes.game);
    } else {
      context.showSnack(S.roomNotFound);
      context.go(Routes.home);
    }
  }

  Future<void> _start(Room room) async {
    setState(() => _navigated = true);
    try {
      await ref.read(roomControllerProvider.notifier).startAsHost(room);
      if (mounted) context.go(Routes.game);
    } catch (error) {
      if (mounted) {
        setState(() => _navigated = false);
        context.showError(error);
      }
    }
  }

  Future<void> _leave() async {
    await ref.read(roomControllerProvider.notifier).leave(widget.code);
    if (mounted) context.go(Routes.home);
  }

  Future<void> _inviteFriend(Room room) => showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (_) => _InviteFriendSheet(roomCode: room.code),
  );

  @override
  Widget build(BuildContext context) {
    ref.listen(roomStreamProvider(widget.code), (_, next) {
      _onRoom(next.value);
    });
    final me = ref.watch(authControllerProvider).value;
    final roomAsync = ref.watch(roomStreamProvider(widget.code));

    return Scaffold(
      appBar: AppBar(
        title: Text(S.waitingRoom),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _leave,
        ),
      ),
      body: ContentWidth(
        child: AsyncView<Room?>(
          value: roomAsync,
          onRetry: () => ref.invalidate(roomStreamProvider(widget.code)),
          data: (room) {
            if (room == null) {
              return Center(child: Text(S.roomNotFound));
            }
            final amHost = me != null && room.isHostId(me.id);
            return _RoomBody(
              room: room,
              amHost: amHost,
              busy: ref.watch(roomControllerProvider),
              onAddBot: () =>
                  ref.read(roomControllerProvider.notifier).addBot(room.code),
              onInviteFriend: AppConfig.isOnline
                  ? () => _inviteFriend(room)
                  : null,
              onStart: () => _start(room),
              myId: me?.id,
            );
          },
        ),
      ),
    );
  }
}

class _RoomBody extends StatelessWidget {
  const _RoomBody({
    required this.room,
    required this.amHost,
    required this.busy,
    required this.onAddBot,
    required this.onInviteFriend,
    required this.onStart,
    required this.myId,
  });

  final Room room;
  final bool amHost;
  final bool busy;
  final VoidCallback onAddBot;
  final VoidCallback? onInviteFriend;
  final VoidCallback onStart;
  final String? myId;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(Insets.l),
      children: [
        _RoomCodeCard(code: room.code, isPublic: room.isPublic),
        const SizedBox(height: Insets.m),
        if (amHost && onInviteFriend != null) ...[
          FilledButton.tonalIcon(
            onPressed: (busy || room.isFull) ? null : onInviteFriend,
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: Text(S.inviteFriend),
            style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
          ),
          const SizedBox(height: Insets.xs),
          Text(
            S.inviteFriendSubtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: Insets.l),
        Row(
          children: [
            Text(
              '${S.playersLabel} (${room.players.length}/${Room.maxPlayers})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            if (amHost && !room.isFull)
              TextButton.icon(
                onPressed: busy ? null : onAddBot,
                icon: const Icon(Icons.smart_toy_outlined),
                label: Text(S.addBot),
              ),
          ],
        ),
        const SizedBox(height: Insets.s),
        ...room.players.map((p) => _PlayerTile(player: p, isMe: p.id == myId)),
        const SizedBox(height: Insets.xl),
        if (amHost)
          FilledButton.icon(
            onPressed: busy ? null : onStart,
            style: FilledButton.styleFrom(minimumSize: const Size(0, 56)),
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(S.startGame),
          )
        else
          const _WaitingHint(),
      ],
    );
  }
}

class _RoomCodeCard extends StatelessWidget {
  const _RoomCodeCard({required this.code, required this.isPublic});
  final String code;
  final bool isPublic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(Insets.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(isPublic ? Icons.public : Icons.lock_outline, size: 18),
                const SizedBox(width: Insets.xs),
                Text(isPublic ? S.publicRoom : S.privateRoom),
              ],
            ),
            const SizedBox(height: Insets.s),
            Text(S.roomCodeLabel, style: theme.textTheme.labelMedium),
            Row(
              children: [
                Expanded(
                  child: SelectableText(
                    code,
                    style: theme.textTheme.headlineMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: code));
                    if (context.mounted) context.showSnack(S.copied);
                  },
                  icon: const Icon(Icons.copy_rounded),
                ),
              ],
            ),
            Text(S.shareCodeHint, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _PlayerTile extends StatelessWidget {
  const _PlayerTile({required this.player, required this.isMe});
  final RoomPlayer player;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: AvatarCircle(avatarId: player.avatarId, size: 44),
        title: Row(
          children: [
            Flexible(child: Text(player.name, overflow: TextOverflow.ellipsis)),
            if (isMe) ...[const SizedBox(width: Insets.s), _Tag(S.youLabel)],
            if (player.isBot) ...[
              const SizedBox(width: Insets.s),
              const _Tag('BOT'),
            ],
          ],
        ),
        trailing: player.isHost ? _Tag(S.hostBadge, highlight: true) : null,
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag(this.label, {this.highlight = false});
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Insets.s,
        vertical: Insets.xs,
      ),
      decoration: BoxDecoration(
        color: highlight
            ? scheme.primaryContainer
            : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(Corners.s),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}

class _WaitingHint extends StatelessWidget {
  const _WaitingHint();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: Insets.m),
        Text(
          S.waitingForHost,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}

/// Host picks a friend to pull straight into this waiting room.
class _InviteFriendSheet extends ConsumerWidget {
  const _InviteFriendSheet({required this.roomCode});
  final String roomCode;

  Future<void> _invite(
    BuildContext context,
    WidgetRef ref,
    Friend friend,
  ) async {
    try {
      await ref
          .read(friendsControllerProvider.notifier)
          .inviteToRoom(friendId: friend.id, roomCode: roomCode);
      if (context.mounted) {
        Navigator.of(context).pop();
        context.showSnack(S.inviteSent);
      }
    } catch (error) {
      if (context.mounted) context.showError(error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsAsync = ref.watch(friendsControllerProvider);
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(Insets.m),
              child: Text(
                S.inviteFriend,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            Flexible(
              child: friendsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(Insets.xl),
                  child: CircularProgressIndicator(),
                ),
                error: (_, _) => Padding(
                  padding: const EdgeInsets.all(Insets.xl),
                  child: Text(S.networkError),
                ),
                data: (friends) => friends.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(Insets.xl),
                        child: Text(
                          S.noFriendsToInvite,
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        padding: const EdgeInsets.fromLTRB(
                          Insets.m,
                          0,
                          Insets.m,
                          Insets.l,
                        ),
                        itemCount: friends.length,
                        itemBuilder: (context, index) {
                          final friend = friends[index];
                          return Card(
                            child: ListTile(
                              leading: AvatarCircle(
                                avatarId: friend.avatarId,
                                size: 40,
                              ),
                              title: Text(
                                friend.nickname,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: const Icon(Icons.send_rounded),
                              onTap: () => _invite(context, ref, friend),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
