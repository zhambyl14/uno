import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/adaptive_scaffold.dart';
import '../core/constants/strings.dart';
import '../features/auth/presentation/auth_controller.dart';
import '../features/friends/presentation/friends_screen.dart';
import '../features/game/presentation/game_controller.dart';
import '../features/game/presentation/game_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/lobby/presentation/lobby_screen.dart';
import '../features/lobby/presentation/room_screen.dart';
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
      // Wait on splash while the session is resolving.
      if (authState.isLoading || !authState.hasValue) {
        return loc == Routes.splash ? null : Routes.splash;
      }
      final loggedIn = authState.value != null;
      final atGate = loc == Routes.splash || loc == Routes.login;
      if (!loggedIn) return atGate ? Routes.login : Routes.login;
      if (atGate) return Routes.home;
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
    ],
  );
});

/// Adaptive navigation shell around the four main tabs.
class HomeShell extends StatelessWidget {
  const HomeShell({super.key, required this.shell});
  final StatefulNavigationShell shell;

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

  @override
  Widget build(BuildContext context) {
    return AdaptiveScaffold(
      selectedIndex: shell.currentIndex,
      onDestinationSelected: (i) =>
          shell.goBranch(i, initialLocation: i == shell.currentIndex),
      destinations: _destinations,
      body: shell,
    );
  }
}
