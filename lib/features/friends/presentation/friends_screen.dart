import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/constants/app_config.dart';
import '../../../core/constants/insets.dart';
import '../../../core/constants/strings.dart';
import '../../../core/utils/code_gen.dart';
import '../../../core/utils/ui_feedback.dart';
import '../../../core/widgets/adaptive_scaffold.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/avatar_circle.dart';
import '../../../core/widgets/status_views.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../game/domain/game_mode.dart';
import '../../lobby/presentation/lobby_controller.dart';
import '../../profile/presentation/widgets/friend_code_card.dart';
import '../domain/friend.dart';
import 'friends_controller.dart';

class FriendsScreen extends ConsumerWidget {
  const FriendsScreen({super.key});

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final code = await showDialog<String>(
      context: context,
      builder: (_) => const _AddFriendDialog(),
    );
    if (code == null || !context.mounted) return;
    try {
      await ref.read(friendsControllerProvider.notifier).addByCode(code);
      if (context.mounted) context.showSnack(S.friendAdded);
    } catch (error) {
      if (context.mounted) context.showError(error);
    }
  }

  /// Invites a friend to play: spins up a private room, drops the invite into
  /// it, and takes the host to the waiting room to greet them.
  Future<void> _invite(
    BuildContext context,
    WidgetRef ref,
    Friend friend,
  ) async {
    if (!AppConfig.isOnline) {
      context.showSnack(S.onlineOnlyBody);
      return;
    }
    try {
      final room = await ref
          .read(lobbyControllerProvider.notifier)
          .createRoom(isPublic: false, mode: GameMode.classic);
      await ref
          .read(friendsControllerProvider.notifier)
          .inviteToRoom(friendId: friend.id, roomCode: room.code);
      if (!context.mounted) return;
      context.showSnack(S.inviteSent);
      unawaited(context.push(Routes.roomPath(room.code)));
    } catch (error) {
      if (context.mounted) context.showError(error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final friendsAsync = ref.watch(friendsControllerProvider);
    final myCode = ref.watch(authControllerProvider).value?.friendCode;

    return Scaffold(
      appBar: AppBar(title: Text(S.friendsTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context, ref),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: Text(S.addFriend),
      ),
      body: ContentWidth(
        child: Column(
          children: [
            if (myCode != null)
              Padding(
                padding: const EdgeInsets.all(Insets.l),
                child: FriendCodeCard(code: myCode),
              ),
            Expanded(
              child: AsyncView<List<Friend>>(
                value: friendsAsync,
                onRetry: () => ref.invalidate(friendsControllerProvider),
                isEmpty: (list) => list.isEmpty,
                empty: EmptyView(
                  emoji: '🧑‍🤝‍🧑',
                  title: S.noFriendsYet,
                  hint: S.noFriendsHint,
                  action: FilledButton.tonalIcon(
                    onPressed: () => _add(context, ref),
                    icon: const Icon(Icons.person_add_alt_1_rounded),
                    label: Text(S.addFriend),
                  ),
                ),
                data: (friends) => ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    Insets.l,
                    0,
                    Insets.l,
                    Insets.xxl * 2,
                  ),
                  itemCount: friends.length,
                  itemBuilder: (context, index) => _FriendTile(
                    friend: friends[index],
                    onInvite: () => _invite(context, ref, friends[index]),
                    onRemove: () =>
                        _confirmRemove(context, ref, friends[index]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    Friend friend,
  ) async {
    final remove = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(S.removeFriend),
        content: Text(S.removeFriendConfirm(friend.nickname)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(S.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(S.removeFriend),
          ),
        ],
      ),
    );
    if (remove == true && context.mounted) {
      await ref.read(friendsControllerProvider.notifier).remove(friend.id);
    }
  }
}

class _FriendTile extends StatelessWidget {
  const _FriendTile({
    required this.friend,
    required this.onInvite,
    required this.onRemove,
  });
  final Friend friend;
  final VoidCallback onInvite;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: AvatarCircle(avatarId: friend.avatarId, size: 44),
        title: Text(friend.nickname, overflow: TextOverflow.ellipsis),
        subtitle: Text(friend.friendCode),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: S.inviteToGame,
              onPressed: onInvite,
              icon: const Icon(Icons.videogame_asset_rounded),
            ),
            IconButton(
              tooltip: S.removeFriend,
              onPressed: onRemove,
              icon: const Icon(Icons.person_remove_alt_1_outlined),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddFriendDialog extends StatefulWidget {
  const _AddFriendDialog();

  @override
  State<_AddFriendDialog> createState() => _AddFriendDialogState();
}

class _AddFriendDialogState extends State<_AddFriendDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final code = CodeGen.normalize(_controller.text);
    if (!CodeGen.friendCodePattern.hasMatch(code)) {
      setState(() => _error = S.invalidFriendCode);
      return;
    }
    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.addFriend),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(S.friendCodeExplain),
          const SizedBox(height: Insets.m),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            maxLength: 8,
            decoration: InputDecoration(
              labelText: S.friendCodeHint,
              errorText: _error,
              prefixIcon: const Icon(Icons.tag_rounded),
              counterText: '',
            ),
            onSubmitted: (_) => _submit(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(S.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(S.add)),
      ],
    );
  }
}
