# Graph Report - .  (2026-07-20)

## Corpus Check
- Corpus is ~42,976 words - fits in a single context window. You may not need a graph.

## Summary
- 1626 nodes · 2264 edges · 98 communities (94 shown, 4 thin omitted)
- Extraction: 100% EXTRACTED · 0% INFERRED · 0% AMBIGUOUS
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Community 0|Community 0]]
- [[_COMMUNITY_Community 1|Community 1]]
- [[_COMMUNITY_Community 2|Community 2]]
- [[_COMMUNITY_Community 3|Community 3]]
- [[_COMMUNITY_Community 4|Community 4]]
- [[_COMMUNITY_Community 5|Community 5]]
- [[_COMMUNITY_Community 6|Community 6]]
- [[_COMMUNITY_Community 7|Community 7]]
- [[_COMMUNITY_Community 8|Community 8]]
- [[_COMMUNITY_Community 9|Community 9]]
- [[_COMMUNITY_Community 10|Community 10]]
- [[_COMMUNITY_Community 11|Community 11]]
- [[_COMMUNITY_Community 12|Community 12]]
- [[_COMMUNITY_Community 13|Community 13]]
- [[_COMMUNITY_Community 14|Community 14]]
- [[_COMMUNITY_Community 15|Community 15]]
- [[_COMMUNITY_Community 16|Community 16]]
- [[_COMMUNITY_Community 17|Community 17]]
- [[_COMMUNITY_Community 18|Community 18]]
- [[_COMMUNITY_Community 19|Community 19]]
- [[_COMMUNITY_Community 20|Community 20]]
- [[_COMMUNITY_Community 21|Community 21]]
- [[_COMMUNITY_Community 22|Community 22]]
- [[_COMMUNITY_Community 23|Community 23]]
- [[_COMMUNITY_Community 24|Community 24]]
- [[_COMMUNITY_Community 25|Community 25]]
- [[_COMMUNITY_Community 26|Community 26]]
- [[_COMMUNITY_Community 27|Community 27]]
- [[_COMMUNITY_Community 28|Community 28]]
- [[_COMMUNITY_Community 29|Community 29]]
- [[_COMMUNITY_Community 30|Community 30]]
- [[_COMMUNITY_Community 31|Community 31]]
- [[_COMMUNITY_Community 32|Community 32]]
- [[_COMMUNITY_Community 33|Community 33]]
- [[_COMMUNITY_Community 34|Community 34]]
- [[_COMMUNITY_Community 35|Community 35]]
- [[_COMMUNITY_Community 36|Community 36]]
- [[_COMMUNITY_Community 37|Community 37]]
- [[_COMMUNITY_Community 38|Community 38]]
- [[_COMMUNITY_Community 39|Community 39]]
- [[_COMMUNITY_Community 40|Community 40]]
- [[_COMMUNITY_Community 41|Community 41]]
- [[_COMMUNITY_Community 42|Community 42]]
- [[_COMMUNITY_Community 43|Community 43]]
- [[_COMMUNITY_Community 44|Community 44]]
- [[_COMMUNITY_Community 45|Community 45]]
- [[_COMMUNITY_Community 46|Community 46]]
- [[_COMMUNITY_Community 47|Community 47]]
- [[_COMMUNITY_Community 48|Community 48]]
- [[_COMMUNITY_Community 49|Community 49]]
- [[_COMMUNITY_Community 50|Community 50]]
- [[_COMMUNITY_Community 51|Community 51]]
- [[_COMMUNITY_Community 52|Community 52]]
- [[_COMMUNITY_Community 53|Community 53]]
- [[_COMMUNITY_Community 54|Community 54]]
- [[_COMMUNITY_Community 55|Community 55]]
- [[_COMMUNITY_Community 56|Community 56]]
- [[_COMMUNITY_Community 57|Community 57]]
- [[_COMMUNITY_Community 58|Community 58]]
- [[_COMMUNITY_Community 59|Community 59]]
- [[_COMMUNITY_Community 60|Community 60]]
- [[_COMMUNITY_Community 61|Community 61]]
- [[_COMMUNITY_Community 62|Community 62]]
- [[_COMMUNITY_Community 63|Community 63]]
- [[_COMMUNITY_Community 64|Community 64]]
- [[_COMMUNITY_Community 65|Community 65]]
- [[_COMMUNITY_Community 66|Community 66]]
- [[_COMMUNITY_Community 67|Community 67]]
- [[_COMMUNITY_Community 68|Community 68]]
- [[_COMMUNITY_Community 69|Community 69]]
- [[_COMMUNITY_Community 70|Community 70]]
- [[_COMMUNITY_Community 71|Community 71]]
- [[_COMMUNITY_Community 72|Community 72]]
- [[_COMMUNITY_Community 73|Community 73]]
- [[_COMMUNITY_Community 74|Community 74]]
- [[_COMMUNITY_Community 75|Community 75]]
- [[_COMMUNITY_Community 76|Community 76]]
- [[_COMMUNITY_Community 77|Community 77]]
- [[_COMMUNITY_Community 78|Community 78]]
- [[_COMMUNITY_Community 79|Community 79]]
- [[_COMMUNITY_Community 80|Community 80]]
- [[_COMMUNITY_Community 81|Community 81]]
- [[_COMMUNITY_Community 82|Community 82]]
- [[_COMMUNITY_Community 83|Community 83]]
- [[_COMMUNITY_Community 84|Community 84]]
- [[_COMMUNITY_Community 85|Community 85]]
- [[_COMMUNITY_Community 86|Community 86]]
- [[_COMMUNITY_Community 87|Community 87]]
- [[_COMMUNITY_Community 88|Community 88]]
- [[_COMMUNITY_Community 89|Community 89]]
- [[_COMMUNITY_Community 90|Community 90]]

## God Nodes (most connected - your core abstractions)
1. `authControllerProvider` - 30 edges
2. `gameControllerProvider` - 10 edges
3. `AppFailure` - 7 edges
4. `GameAction` - 7 edges
5. `GameMode` - 7 edges
6. `t` - 7 edges
7. `prefsServiceProvider` - 6 edges
8. `GameState` - 6 edges
9. `GameController` - 6 edges
10. `_GameScreenState` - 6 edges

## Surprising Connections (you probably didn't know these)
- `addByCode` --references--> `authControllerProvider`  [EXTRACTED]
  lib/features/friends/presentation/friends_controller.dart → lib/features/auth/presentation/auth_controller.dart
- `claim` --references--> `authControllerProvider`  [EXTRACTED]
  lib/features/missions/presentation/missions_controller.dart → lib/features/auth/presentation/auth_controller.dart
- `build` --references--> `prefsServiceProvider`  [EXTRACTED]
  lib/features/settings/presentation/locale_controller.dart → lib/core/services/prefs_service.dart
- `setLocale` --references--> `prefsServiceProvider`  [EXTRACTED]
  lib/features/settings/presentation/locale_controller.dart → lib/core/services/prefs_service.dart
- `MissionsController` --references--> `prefsServiceProvider`  [EXTRACTED]
  lib/features/missions/presentation/missions_controller.dart → lib/core/services/prefs_service.dart

## Import Cycles
- None detected.

## Communities (98 total, 4 thin omitted)

### Community 0 - "Community 0"
Cohesion: 0.01
Nodes (220): aboutTitle, add, addBot, addFriend, alreadyFriends, appearance, appName, birthYearLabel (+212 more)

### Community 1 - "Community 1"
Cohesion: 0.05
Nodes (45): claimed, copyWith, daily, DailyMissionsState, ../../domain/mission.dart, day, entries, fresh (+37 more)

### Community 2 - "Community 2"
Cohesion: 0.05
Nodes (40): package:flutter_test/flutter_test.dart, package:shared_preferences/shared_preferences.dart, package:uno_family/app/app.dart, package:uno_family/core/constants/strings.dart, package:uno_family/core/services/prefs_service.dart, package:uno_family/core/services/push_service.dart, package:uno_family/core/utils/code_gen.dart, package:uno_family/core/utils/nickname_filter.dart (+32 more)

### Community 3 - "Community 3"
Cohesion: 0.05
Nodes (42): dart:io, addBot, _controllers, createRoom, currentGameState, _emit, joinRoom, leaveRoom (+34 more)

### Community 4 - "Community 4"
Cohesion: 0.05
Nodes (40): description, emoji, GameMode, handSize, isTeam, label, turnSeconds, withSpecials (+32 more)

### Community 5 - "Community 5"
Cohesion: 0.05
Nodes (40): game_controller.dart, game_event_text.dart, canPass, canUno, cardBack, _chat, _chatTimer, count (+32 more)

### Community 6 - "Community 6"
Cohesion: 0.05
Nodes (36): activeColor, actorId, avatarId, copyWith, currentIndex, currentPlayer, direction, discardPile (+28 more)

### Community 7 - "Community 7"
Cohesion: 0.07
Nodes (33): _confirmLeave, roomControllerProvider, roomStreamProvider, amHost, build, busy, code, createState (+25 more)

### Community 8 - "Community 8"
Cohesion: 0.08
Nodes (28): ../../../core/widgets/avatar_circle.dart, GamePlayer, StandingEntry, ../../game/domain/match_result.dart, _CenterArea, _DrawPile, _GameBoard, _NoGame (+20 more)

### Community 9 - "Community 9"
Cohesion: 0.07
Nodes (26): auth, build, _destinations, HomeShell, _rootKey, shell, ../features/auth/presentation/auth_controller.dart, ../features/auth/presentation/login_screen.dart (+18 more)

### Community 10 - "Community 10"
Cohesion: 0.08
Nodes (25): _actionsSub, _appliedActionIds, _bindClient, _bindHost, client, _controller, _db, dispose (+17 more)

### Community 11 - "Community 11"
Cohesion: 0.08
Nodes (25): avatarId, cardsLeft, cardsPlayed, coinGain, copyWith, fromState, isLocal, isLocalWin (+17 more)

### Community 12 - "Community 12"
Cohesion: 0.09
Nodes (24): lobby_controller.dart, _playVsBots, lobbyControllerProvider, build, _controller, _createRoom, createState, dispose (+16 more)

### Community 13 - "Community 13"
Cohesion: 0.08
Nodes (24): _avatarId, _AvatarPicker, avatars, _birthYear, build, busy, _childThreshold, _controller (+16 more)

### Community 14 - "Community 14"
Cohesion: 0.08
Nodes (22): AppConfig, firebaseApiKey, firebaseAppId, firebaseProjectId, firebaseSenderId, firebaseVapidKey, isOnline, pushReady (+14 more)

### Community 15 - "Community 15"
Cohesion: 0.08
Nodes (23): afterMatch, avatarId, cardSkinId, coins, copyWith, friendCode, fromJson, gamesPlayed (+15 more)

### Community 16 - "Community 16"
Cohesion: 0.09
Nodes (22): all, avatarsInPack, back, bottom, byCategory, byId, CardSkin, category (+14 more)

### Community 17 - "Community 17"
Cohesion: 0.10
Nodes (18): buildTheme, scheme, _seed, ../constants/insets.dart, package:flutter/material.dart, ../utils/rank.dart, build, CoinChip (+10 more)

### Community 18 - "Community 18"
Cohesion: 0.09
Nodes (21): _apply, _botTimer, buildResult, _controller, createState, dispose, localPlayerId, localStats (+13 more)

### Community 19 - "Community 19"
Cohesion: 0.10
Nodes (19): AsyncValue, status_views.dart, ../utils/failures.dart, VoidCallback, Widget?, AsyncView, build, empty (+11 more)

### Community 20 - "Community 20"
Cohesion: 0.11
Nodes (14): Any, Bool, Flutter, FlutterAppDelegate, FlutterImplicitEngineBridge, FlutterImplicitEngineDelegate, FlutterSceneDelegate, AppDelegate (+6 more)

### Community 21 - "Community 21"
Cohesion: 0.11
Nodes (18): ../../../app/routes.dart, ../../auth/presentation/widgets/profile_setup_form.dart, ../../../core/widgets/coin_chip.dart, ../../../core/widgets/rank_badge.dart, ../../../core/widgets/stat_tile.dart, locale_controller.dart, package:go_router/go_router.dart, _ChildChip (+10 more)

### Community 22 - "Community 22"
Cohesion: 0.10
Nodes (19): AuthRepository get, ../../../../core/utils/nickname_filter.dart, PlayerProfile? get, applyMatchResult, _autoGuest, creditCoins, equipCardSkin, equipTableTheme (+11 more)

### Community 23 - "Community 23"
Cohesion: 0.11
Nodes (19): build, copyWith, fromJson, _key, notifDaily, notifInvites, notifSeason, _prefs (+11 more)

### Community 24 - "Community 24"
Cohesion: 0.12
Nodes (17): ../data/room_repository.dart, ../domain/room.dart, ../../game/data/remote_game_session.dart, ../../game/domain/seat_factory.dart, ../../game/presentation/game_controller.dart, build, createRoom, joinByCode (+9 more)

### Community 25 - "Community 25"
Cohesion: 0.11
Nodes (18): ../../lobby/presentation/lobby_controller.dart, ../../missions/presentation/widgets/missions_card.dart, createState, _GuestGateSheet, guestLocked, _LocalBadge, _mode, _ModeGrid (+10 more)

### Community 26 - "Community 26"
Cohesion: 0.11
Nodes (17): AnimationController, build, color, _colors, _controller, createState, delay, dispose (+9 more)

### Community 27 - "Community 27"
Cohesion: 0.12
Nodes (16): ../../../core/widgets/async_view.dart, ../../../core/widgets/status_views.dart, ../data/leaderboard_repository.dart, leaderboard_controller.dart, package:flutter_riverpod/flutter_riverpod.dart, leaderboardControllerProvider, avatarId, build (+8 more)

### Community 28 - "Community 28"
Cohesion: 0.12
Nodes (17): ../data/game_session.dart, ../data/local_game_session.dart, ../domain/game_mode.dart, ../domain/seat_factory.dart, ../../missions/presentation/missions_controller.dart, attach, build, clear (+9 more)

### Community 29 - "Community 29"
Cohesion: 0.11
Nodes (17): GameEvent, Offset, build, color, _controller, createState, didUpdateWidget, dispose (+9 more)

### Community 30 - "Community 30"
Cohesion: 0.13
Nodes (17): Friend, friends_controller.dart, friendsControllerProvider, _add, build, _confirmRemove, _controller, createState (+9 more)

### Community 31 - "Community 31"
Cohesion: 0.12
Nodes (16): ../auth_controller.dart, FormState, profile_setup_form.dart, build, _busy, createState, dispose, _doRegister (+8 more)

### Community 32 - "Community 32"
Cohesion: 0.12
Nodes (16): ../../../../core/constants/game_palette.dart, ActiveColorDot, backColor, build, card, _CardBack, color, colorOf (+8 more)

### Community 33 - "Community 33"
Cohesion: 0.13
Nodes (14): ../../../core/constants/insets.dart, ../../../core/constants/strings.dart, ../../../core/widgets/adaptive_scaffold.dart, package:flutter/gestures.dart, build, PrivacyScreen, build, SplashScreen (+6 more)

### Community 34 - "Community 34"
Cohesion: 0.12
Nodes (16): deck.dart, apply, _deadline, _draw, _fairSplit, _forceDraw, GameEngine, _leave (+8 more)

### Community 35 - "Community 35"
Cohesion: 0.12
Nodes (16): ../domain/shop_item.dart, _ActionButton, affordable, _buy, category, _CategorySection, equipped, icon (+8 more)

### Community 36 - "Community 36"
Cohesion: 0.12
Nodes (15): friends, game, home, leaderboard, lobby, login, privacy, profile (+7 more)

### Community 37 - "Community 37"
Cohesion: 0.12
Nodes (15): all, AvatarDef, Avatars, background, base, BotNames, byId, emoji (+7 more)

### Community 38 - "Community 38"
Cohesion: 0.13
Nodes (15): authEvents, AuthRepository, _key, LocalAuthRepository, OAuthKind, _prefs, restore, signInEmail (+7 more)

### Community 39 - "Community 39"
Cohesion: 0.13
Nodes (14): ../constants/breakpoints.dart, IconData, AdaptiveDestination, AdaptiveScaffold, body, build, child, ContentWidth (+6 more)

### Community 40 - "Community 40"
Cohesion: 0.14
Nodes (14): addByCode, FriendsRepository, invite, _key, list, LocalFriendsRepository, _prefs, _read (+6 more)

### Community 41 - "Community 41"
Cohesion: 0.13
Nodes (14): addBot, createRoom, currentGameState, _db, _fetch, joinRoom, leaveRoom, quickMatch (+6 more)

### Community 42 - "Community 42"
Cohesion: 0.13
Nodes (14): CardType, color, fromJson, hashCode, id, isWildType, matches, needsColorChoice (+6 more)

### Community 43 - "Community 43"
Cohesion: 0.14
Nodes (13): auth_repository.dart, authEvents, _client, _createProfile, _defaultNickname, _loadOrCreateProfile, mobileRedirect, restore (+5 more)

### Community 44 - "Community 44"
Cohesion: 0.18
Nodes (14): ConsumerWidget, authControllerProvider, build, LeaderboardScreen, LoginScreen, _oauth, ProfileScreen, joinAsClient (+6 more)

### Community 45 - "Community 45"
Cohesion: 0.20
Nodes (14): _AddFriendDialog, _AddFriendDialogState, _ActionBar, _ActionBarState, SingleTickerProviderStateMixin, State, StatefulWidget, TurnTimer (+6 more)

### Community 46 - "Community 46"
Cohesion: 0.22
Nodes (12): build, UnoFamilyApp, routerProvider, ../features/settings/presentation/locale_controller.dart, ../features/settings/presentation/settings_controller.dart, localeControllerProvider, settingsControllerProvider, build (+4 more)

### Community 47 - "Community 47"
Cohesion: 0.18
Nodes (12): ../constants/app_config.dart, package:firebase_core/firebase_core.dart, package:firebase_messaging/firebase_messaging.dart, FcmPushService, init, NoopPushService, PushService, _ready (+4 more)

### Community 48 - "Community 48"
Cohesion: 0.17
Nodes (11): dart:math, _bestColor, BotBrain, decide, _score, thinkDelay, build, Deck (+3 more)

### Community 49 - "Community 49"
Cohesion: 0.15
Nodes (12): ../data/auth_repository.dart, build, _email, filled, icon, label, _LocalModeNote, onPressed (+4 more)

### Community 50 - "Community 50"
Cohesion: 0.23
Nodes (12): cardId, chosenColor, DrawCardAction, fromJson, GameAction, LeaveAction, PassAction, PlayCardAction (+4 more)

### Community 51 - "Community 51"
Cohesion: 0.17
Nodes (11): bool get, Breakpoints, compact, contentMaxWidth, isCompact, isMedium, isWide, medium (+3 more)

### Community 52 - "Community 52"
Cohesion: 0.17
Nodes (11): dart:convert, getBool, getJson, getString, _prefs, PrefsService, remove, setBool (+3 more)

### Community 53 - "Community 53"
Cohesion: 0.17
Nodes (11): dispose, localPlayerId, localStats, state, states, submit, ../domain/game_action.dart, ../domain/match_result.dart (+3 more)

### Community 54 - "Community 54"
Cohesion: 0.17
Nodes (11): GameState, ../../domain/uno_rules.dart, build, _fanStep, isCompactHeight, _liftPerStep, myTurn, onPlay (+3 more)

### Community 55 - "Community 55"
Cohesion: 0.18
Nodes (10): blue, cardFace, cardInk, GamePalette, green, red, wild, yellow (+2 more)

### Community 56 - "Community 56"
Cohesion: 0.18
Nodes (10): card, Corners, Insets, l, m, s, xl, xs (+2 more)

### Community 57 - "Community 57"
Cohesion: 0.18
Nodes (10): dart:async, DateTime, build, createState, dispose, endsAt, initState, size (+2 more)

### Community 58 - "Community 58"
Cohesion: 0.18
Nodes (10): static const List, _allowed, _banned, _contact, _fold, maxLength, minLength, NicknameFilter (+2 more)

### Community 59 - "Community 59"
Cohesion: 0.18
Nodes (10): background_color, description, display, icons, name, orientation, prefer_related_applications, short_name (+2 more)

### Community 60 - "Community 60"
Cohesion: 0.20
Nodes (9): ../../auth/presentation/auth_controller.dart, ../data/friends_repository.dart, ../domain/friend.dart, FriendsRepository get, addByCode, build, invite, remove (+1 more)

### Community 61 - "Community 61"
Cohesion: 0.24
Nodes (10): ConsumerState, ConsumerStatefulWidget, gameStateProvider, build, GameScreen, _GameScreenState, HomeScreen, _HomeScreenState (+2 more)

### Community 62 - "Community 62"
Cohesion: 0.24
Nodes (9): ../../../core/localization/app_locale.dart, core/services/prefs_service.dart, AppLocale, build, _key, LocaleController, setLocale, prefsServiceProvider (+1 more)

### Community 63 - "Community 63"
Cohesion: 0.20
Nodes (9): ../../../core/utils/code_gen.dart, addByCode, _db, invite, list, remove, _uid, friends_repository.dart (+1 more)

### Community 64 - "Community 64"
Cohesion: 0.22
Nodes (9): ../../../core/utils/failures.dart, _client, LeaderboardRepository, leaderboardRepositoryProvider, SupabaseLeaderboardRepository, top, ../domain/leaderboard_entry.dart, package:supabase_flutter/supabase_flutter.dart (+1 more)

### Community 65 - "Community 65"
Cohesion: 0.31
Nodes (9): Exception, AppFailure, AuthFailure, message, NetworkFailure, NotFoundFailure, OfflineFailure, toString (+1 more)

### Community 66 - "Community 66"
Cohesion: 0.22
Nodes (8): Color, color, fromPoints, label, minPoints, progress, RankTier, seasonName

### Community 67 - "Community 67"
Cohesion: 0.25
Nodes (7): app/app.dart, core/constants/app_config.dart, core/services/push_service.dart, main, prefs, push, package:flutter_web_plugins/url_strategy.dart

### Community 68 - "Community 68"
Cohesion: 0.29
Nodes (8): AsyncNotifier, authRepositoryProvider, PlayerProfile, AuthController, build, signOut, _syncPush, pushServiceProvider

### Community 69 - "Community 69"
Cohesion: 0.25
Nodes (7): ../../auth/domain/player_profile.dart, ../../../core/constants/catalog.dart, defaultBotCount, fillWithBots, SeatFactory, withBots, static const int

### Community 70 - "Community 70"
Cohesion: 0.25
Nodes (7): avatarId, Friend, friendCode, fromJson, id, nickname, toJson

### Community 71 - "Community 71"
Cohesion: 0.29
Nodes (6): ../constants/catalog.dart, AvatarCircle, avatarId, build, selected, size

### Community 72 - "Community 72"
Cohesion: 0.29
Nodes (6): avatarId, fromJson, id, LeaderboardEntry, nickname, rankPoints

### Community 73 - "Community 73"
Cohesion: 0.29
Nodes (6): CardColor, ../../domain/uno_card.dart, uno_card_view.dart, build, ColorPickerSheet, show

### Community 74 - "Community 74"
Cohesion: 0.29
Nodes (7): gameControllerProvider, _draw, _onState, _pass, _sayUno, startVsBots, Routes.results

### Community 75 - "Community 75"
Cohesion: 0.29
Nodes (5): BODIES, projectId, PushKind, serviceAccount, TITLES

### Community 76 - "Community 76"
Cohesion: 0.33
Nodes (5): ../constants/strings.dart, failures.dart, errorMessage, showError, showSnack

### Community 77 - "Community 77"
Cohesion: 0.33
Nodes (5): ../../../core/utils/ui_feedback.dart, package:flutter/services.dart, build, code, FriendCodeCard

### Community 78 - "Community 78"
Cohesion: 0.40
Nodes (6): roomRepositoryProvider, MatchResult, Notifier, LastResult, LobbyController, RoomController

### Community 79 - "Community 79"
Cohesion: 0.33
Nodes (5): ../../domain/game_state.dart, actor, describeEvent, event, target

### Community 80 - "Community 80"
Cohesion: 0.33
Nodes (5): handle_new_rx_page(), __lldb_init_module(), Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages., SBDebugger, SBFrame

### Community 81 - "Community 81"
Cohesion: 0.50
Nodes (3): canPlayCard, UnoRules, game_state.dart

### Community 83 - "Community 83"
Cohesion: 0.50
Nodes (3): code, fromCode, label

### Community 84 - "Community 84"
Cohesion: 0.67
Nodes (3): BuildContext, AdaptiveX, UiFeedback

### Community 85 - "Community 85"
Cohesion: 0.67
Nodes (3): CustomPainter, _ConfettiPainter, _BurstPainter

### Community 86 - "Community 86"
Cohesion: 0.67
Nodes (3): friendsRepositoryProvider, List, FriendsController

### Community 87 - "Community 87"
Cohesion: 0.67
Nodes (3): GameSession, LocalGameSession, RemoteGameSession

## Knowledge Gaps
- **1029 isolated node(s):** `flutter_export_environment.sh script`, `XCTest`, `-registerWithRegistry`, `_rootKey`, `auth` (+1024 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **4 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `t` connect `Community 63` to `Community 0`, `Community 41`, `Community 43`, `Community 24`, `Community 26`?**
  _High betweenness centrality (0.079) - this node is a cross-community bridge._
- **Why does `GameMode` connect `Community 4` to `Community 25`, `Community 11`, `Community 12`, `Community 6`?**
  _High betweenness centrality (0.018) - this node is a cross-community bridge._
- **Why does `PlayerProfile` connect `Community 68` to `Community 35`, `Community 21`, `Community 15`?**
  _High betweenness centrality (0.015) - this node is a cross-community bridge._
- **What connects `Intercept NOTIFY_DEBUGGER_ABOUT_RX_PAGES and touch the pages.`, `flutter_export_environment.sh script`, `XCTest` to the rest of the system?**
  _1030 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Community 0` be split into smaller, more focused modules?**
  _Cohesion score 0.00904977375565611 - nodes in this community are weakly interconnected._
- **Should `Community 1` be split into smaller, more focused modules?**
  _Cohesion score 0.04521276595744681 - nodes in this community are weakly interconnected._
- **Should `Community 2` be split into smaller, more focused modules?**
  _Cohesion score 0.05365402405180388 - nodes in this community are weakly interconnected._