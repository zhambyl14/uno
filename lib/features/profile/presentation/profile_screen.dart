import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/constants/catalog.dart';
import '../../../core/constants/insets.dart';
import '../../../core/constants/strings.dart';
import '../../../core/utils/ui_feedback.dart';
import '../../../core/widgets/adaptive_scaffold.dart';
import '../../../core/widgets/avatar_circle.dart';
import '../../../core/widgets/coin_chip.dart';
import '../../../core/widgets/rank_badge.dart';
import '../../../core/widgets/stat_tile.dart';
import '../../auth/domain/player_profile.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../auth/presentation/widgets/profile_setup_form.dart';
import 'widgets/friend_code_card.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    PlayerProfile profile,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: Insets.l,
          right: Insets.l,
          bottom: MediaQuery.viewInsetsOf(context).bottom + Insets.l,
        ),
        child: SingleChildScrollView(
          child: ProfileSetupForm(
            submitLabel: S.save,
            avatars: Avatars.unlockedFor(profile.ownedItems),
            initialNickname: profile.nickname,
            initialAvatarId: profile.avatarId,
            onSubmit: (nickname, avatarId, _) async {
              try {
                await ref
                    .read(authControllerProvider.notifier)
                    .updateNicknameAndAvatar(
                      nickname: nickname,
                      avatarId: avatarId,
                    );
                if (context.mounted) Navigator.of(context).pop();
              } catch (error) {
                if (context.mounted) context.showError(error);
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(authControllerProvider).value;
    return Scaffold(
      appBar: AppBar(
        title: Text(S.profileTitle),
        actions: [
          IconButton(
            tooltip: S.settingsTitle,
            onPressed: () => context.push(Routes.settings),
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: profile == null
          ? const Center(child: CircularProgressIndicator())
          : ContentWidth(
              child: ListView(
                padding: const EdgeInsets.all(Insets.l),
                children: [
                  _Header(profile: profile),
                  const SizedBox(height: Insets.l),
                  RankBadge(points: profile.rankPoints),
                  const SizedBox(height: Insets.l),
                  Text(
                    S.statsTitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: Insets.s),
                  Row(
                    children: [
                      Expanded(
                        child: StatTile(
                          value: '${profile.gamesPlayed}',
                          label: S.gamesPlayed,
                          emoji: '🎮',
                        ),
                      ),
                      const SizedBox(width: Insets.s),
                      Expanded(
                        child: StatTile(
                          value: '${profile.wins}',
                          label: S.wins,
                          emoji: '🏆',
                        ),
                      ),
                      const SizedBox(width: Insets.s),
                      Expanded(
                        child: StatTile(
                          value: '${profile.winRatePercent}%',
                          label: S.winRate,
                          emoji: '📈',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Insets.l),
                  FriendCodeCard(code: profile.friendCode),
                  const SizedBox(height: Insets.l),
                  FilledButton.tonalIcon(
                    onPressed: () => _edit(context, ref, profile),
                    icon: const Icon(Icons.edit_outlined),
                    label: Text(S.editProfile),
                  ),
                ],
              ),
            ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.profile});
  final PlayerProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        AvatarCircle(avatarId: profile.avatarId, size: 72),
        const SizedBox(width: Insets.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      profile.nickname,
                      style: theme.textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (profile.isChild) ...[
                    const SizedBox(width: Insets.s),
                    const _ChildChip(),
                  ],
                ],
              ),
              const SizedBox(height: Insets.xs),
              Text(
                '${S.levelLabel} ${profile.level}',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: Insets.xs),
              LinearProgressIndicator(
                value: profile.levelProgress,
                minHeight: 6,
                borderRadius: BorderRadius.circular(Corners.s),
              ),
            ],
          ),
        ),
        const SizedBox(width: Insets.s),
        CoinChip(coins: profile.coins),
      ],
    );
  }
}

class _ChildChip extends StatelessWidget {
  const _ChildChip();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Insets.s,
        vertical: Insets.xs,
      ),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(Corners.s),
      ),
      child: Text(
        S.childBadge,
        style: TextStyle(fontSize: 11, color: scheme.onTertiaryContainer),
      ),
    );
  }
}
