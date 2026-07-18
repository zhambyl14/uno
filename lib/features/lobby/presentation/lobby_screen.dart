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
import '../../game/domain/game_mode.dart';
import 'lobby_controller.dart';

class LobbyScreen extends ConsumerWidget {
  const LobbyScreen({super.key});

  GameMode _modeFromQuery(BuildContext context) {
    final raw = GoRouterState.of(context).uri.queryParameters['mode'];
    final index = int.tryParse(raw ?? '');
    if (index == null || index < 0 || index >= GameMode.values.length) {
      return GameMode.classic;
    }
    return GameMode.values[index];
  }

  Future<void> _createRoom(
    BuildContext context,
    WidgetRef ref,
    GameMode mode,
  ) async {
    final isPublic = await showDialog<bool>(
      context: context,
      builder: (_) => const _RoomTypeDialog(),
    );
    if (isPublic == null || !context.mounted) return;
    try {
      final room = await ref
          .read(lobbyControllerProvider.notifier)
          .createRoom(isPublic: isPublic, mode: mode);
      if (context.mounted) unawaited(context.push(Routes.roomPath(room.code)));
    } catch (error) {
      if (context.mounted) context.showError(error);
    }
  }

  Future<void> _joinByCode(BuildContext context, WidgetRef ref) async {
    if (!AppConfig.isOnline) {
      await showDialog<void>(
        context: context,
        builder: (_) => AlertDialog(
          title: Text(S.onlineOnlyTitle),
          content: Text(S.onlineOnlyBody),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(S.ok),
            ),
          ],
        ),
      );
      return;
    }
    final code = await showDialog<String>(
      context: context,
      builder: (_) => const _JoinCodeDialog(),
    );
    if (code == null || !context.mounted) return;
    try {
      final room = await ref
          .read(lobbyControllerProvider.notifier)
          .joinByCode(code);
      if (context.mounted) unawaited(context.push(Routes.roomPath(room.code)));
    } catch (error) {
      if (context.mounted) context.showError(error);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = _modeFromQuery(context);
    final busy = ref.watch(lobbyControllerProvider);
    return Scaffold(
      appBar: AppBar(title: Text(S.lobbyTitle)),
      body: ContentWidth(
        child: ListView(
          padding: const EdgeInsets.all(Insets.l),
          children: [
            _ModeHeader(mode: mode),
            const SizedBox(height: Insets.l),
            _LobbyTile(
              emoji: '🤖',
              title: S.playVsBots,
              subtitle: S.botsDesc,
              onTap: busy
                  ? null
                  : () {
                      ref
                          .read(lobbyControllerProvider.notifier)
                          .startVsBots(mode);
                      context.go(Routes.game);
                    },
            ),
            _LobbyTile(
              emoji: '➕',
              title: S.createRoom,
              subtitle: '${S.publicRoom} / ${S.privateRoom}',
              onTap: busy ? null : () => _createRoom(context, ref, mode),
            ),
            _LobbyTile(
              emoji: '🔑',
              title: S.joinByCode,
              subtitle: S.roomCodeHint,
              onTap: busy ? null : () => _joinByCode(context, ref),
            ),
            if (AppConfig.isOnline)
              _LobbyTile(
                emoji: '⚡',
                title: S.quickPlay,
                subtitle: S.publicRoomDesc,
                onTap: busy
                    ? null
                    : () async {
                        try {
                          final room = await ref
                              .read(lobbyControllerProvider.notifier)
                              .quickMatch(mode);
                          if (context.mounted) {
                            unawaited(context.push(Routes.roomPath(room.code)));
                          }
                        } catch (error) {
                          if (context.mounted) context.showError(error);
                        }
                      },
              ),
            if (busy) ...[
              const SizedBox(height: Insets.l),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}

class _ModeHeader extends StatelessWidget {
  const _ModeHeader({required this.mode});
  final GameMode mode;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(Insets.m),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(Corners.l),
      ),
      child: Row(
        children: [
          Text(mode.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: Insets.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mode.label,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  mode.description,
                  style: TextStyle(color: scheme.onPrimaryContainer),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LobbyTile extends StatelessWidget {
  const _LobbyTile({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Insets.m,
          vertical: Insets.s,
        ),
        leading: Text(emoji, style: const TextStyle(fontSize: 28)),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}

class _RoomTypeDialog extends StatelessWidget {
  const _RoomTypeDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.createRoom),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.public),
            title: Text(S.publicRoom),
            subtitle: Text(S.publicRoomDesc),
            onTap: () => Navigator.of(context).pop(true),
          ),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: Text(S.privateRoom),
            subtitle: Text(S.privateRoomDesc),
            onTap: () => Navigator.of(context).pop(false),
          ),
        ],
      ),
    );
  }
}

class _JoinCodeDialog extends StatefulWidget {
  const _JoinCodeDialog();

  @override
  State<_JoinCodeDialog> createState() => _JoinCodeDialogState();
}

class _JoinCodeDialogState extends State<_JoinCodeDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final code = CodeGen.normalize(_controller.text);
    if (!CodeGen.roomCodePattern.hasMatch(code)) {
      setState(() => _error = S.invalidRoomCode);
      return;
    }
    Navigator.of(context).pop(code);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(S.joinByCode),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.characters,
        maxLength: 6,
        decoration: InputDecoration(
          labelText: S.roomCodeHint,
          errorText: _error,
          prefixIcon: const Icon(Icons.vpn_key_outlined),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(S.cancel),
        ),
        FilledButton(onPressed: _submit, child: Text(S.join)),
      ],
    );
  }
}
