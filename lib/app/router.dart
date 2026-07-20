import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/adaptive_scaffold.dart';
import '../core/constants/strings.dart';
import '../core/utils/ui_feedback.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/friends/domain/game_invite.dart';
import '../features/friends/presentation/friends_controller.dart';
import '../features/friends/presentation/friends_screen.dart';
import '../features/lobby/presentation/lobby_controller.dart';
import '../features/game/presentation/game_controller.dart';
import '../features/game/presentation/game_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/leaderboard/presentation/leaderboard_screen.dart';
import '../features/lobby/presentation/lobby_screen.dart';
import '../features/lobby/presentation/room_screen.dart';
import '../features/minigames/crazy8s/presentation/crazy8s_screen.dart';
import '../features/minigames/memory/memory_screen.dart';
import '../features/minigames/snap/snap_screen.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/splash_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/results/presentation/results_screen.dart';
import '../features/settings/presentation/privacy_screen.dart';
import '../features/settings/presentation/settings_screen.dart';
import '../features/shop/presentation/shop_screen.dart';
import 'routes.dart';

final _rootKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ValueNotifier<int>(0);
  ref.listen(authControllerProvider, (_, _) => auth.value++);
  ref.onDispose(auth.dispose);

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: Routes.splash,
    refreshListenable: auth,
    redirect: (context, state) {
      final authState = ref.read(authControllerProvider);
      final loc = state.matchedLocation;
      // Wait on splash while a guest session is being created/restored —
      // there is no login gate, the app always ends up with a profile.
      if (authState.isLoading || !authState.hasValue) {
        return loc == Routes.splash ? null : Routes.splash;
      }
      if (loc == Routes.splash) return Routes.home;
      return null;
    },
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: Routes.login, builder: (_, _) => const LoginScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.friends,
                builder: (_, _) => const FriendsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(path: Routes.shop, builder: (_, _) => const ShopScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (_, _) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: Routes.lobby,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const LobbyScreen(),
      ),
      GoRoute(
        path: Routes.room,
        parentNavigatorKey: _rootKey,
        builder: (_, state) =>
            RoomScreen(code: state.pathParameters['code'] ?? ''),
      ),
      GoRoute(
        path: Routes.game,
        parentNavigatorKey: _rootKey,
        // Deep-linking straight to /game with no active match returns home.
        redirect: (_, _) =>
            ref.read(gameControllerProvider) == null ? Routes.home : null,
        builder: (_, _) => const GameScreen(),
      ),
      GoRoute(
        path: Routes.results,
        parentNavigatorKey: _rootKey,
        redirect: (_, _) =>
            ref.read(lastResultProvider) == null ? Routes.home : null,
        builder: (_, _) => const ResultsScreen(),
      ),
      GoRoute(
        path: Routes.settings,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const SettingsScreen(),
      ),
      GoRoute(
        path: Routes.privacy,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const PrivacyScreen(),
      ),
      GoRoute(
        path: Routes.leaderboard,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: Routes.memory,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const MemoryScreen(),
      ),
      GoRoute(
        path: Routes.snap,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const SnapScreen(),
      ),
      GoRoute(
        path: Routes.crazy8s,
        parentNavigatorKey: _rootKey,
        builder: (_, _) => const Crazy8sScreen(),
      ),
    ],
  );
});

/// Adaptive navigation shell around the four main tabs. Also the app-wide
/// home for incoming room invites: while a player is anywhere in the main
/// app, a friend's invite pops a "join this room?" prompt.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  final Set<int> _handledInvites = {};

  static List<AdaptiveDestination> get _destinations => [
    AdaptiveDestination(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: S.navHome,
    ),
    AdaptiveDestination(
      icon: Icons.people_outline_rounded,
      selectedIcon: Icons.people_rounded,
      label: S.navFriends,
    ),
    AdaptiveDestination(
      icon: Icons.storefront_outlined,
      selectedIcon: Icons.storefront_rounded,
      label: S.navShop,
    ),
    AdaptiveDestination(
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      label: S.navProfile,
    ),
  ];

  Future<void> _showInvite(GameInvite invite) async {
    _handledInvites.add(invite.id);
    final friends = ref.read(friendsControllerProvider).value ?? const [];
    String? senderName;
    for (final f in friends) {
      if (f.id == invite.fromId) {
        senderName = f.nickname;
        break;
      }
    }
    final body = senderName != null
        ? S.inviteReceivedBody(senderName)
        : S.inviteReceivedGeneric;
    final join = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(S.inviteReceivedTitle),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(S.maybeLater),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.play_arrow_rounded),
            label: Text(S.join),
          ),
        ],
      ),
    );
    // Clear it either way so the prompt doesn't linger on the next stream tick.
    await ref.read(friendsControllerProvider.notifier).consumeInvite(invite.id);
    if (!mounted || join != true) return;
    // Actually join the room (adds this player to it) before entering.
    try {
      await ref
          .read(lobbyControllerProvider.notifier)
          .joinByCode(invite.roomCode);
      if (mounted) unawaited(context.push(Routes.roomPath(invite.roomCode)));
    } catch (error) {
      if (mounted) context.showError(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(incomingInvitesProvider, (_, next) {
      final invites = next.value;
      if (invites == null || invites.isEmpty) return;
      GameInvite? fresh;
      for (final invite in invites) {
        if (!_handledInvites.contains(invite.id)) fresh = invite;
      }
      if (fresh != null) unawaited(_showInvite(fresh));
    });

    return AdaptiveScaffold(
      selectedIndex: widget.shell.currentIndex,
      onDestinationSelected: (i) => widget.shell.goBranch(
        i,
        initialLocation: i == widget.shell.currentIndex,
      ),
      destinations: _destinations,
      body: widget.shell,
    );
  }
}
