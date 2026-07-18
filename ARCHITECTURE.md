# UNO FAMILY — Architecture

Child-safe (4+/Everyone) multiplayer card game. Flutter, one codebase: Android + iOS + Web.

## Two runtime modes

| Mode | When | What works |
|---|---|---|
| **Local** | No Supabase keys passed | Guest profile, game vs bots (all 4 modes), shop, missions, rank — everything offline |
| **Online** | `--dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...` | + real auth (Google/Apple/Email), friends by code, public matchmaking, private rooms, realtime multiplayer |

Push (FCM) activates only when Firebase is configured via dart-defines (see README). Never blocks the app.

## Route map (go_router, real URL paths)

| Path | Screen |
|---|---|
| `/splash` | Splash — boot + auth resolution |
| `/login` | Login — Google / Apple / Email / Guest (child-safe signup: nickname filter, preset avatar, birth year) |
| `/` | Home — play modes, daily missions, rank/season (shell tab) |
| `/friends` | Friends — friend code add/list/invite (shell tab) |
| `/shop` | Shop — cosmetics only, fixed prices, no loot boxes (shell tab) |
| `/profile` | Profile — stats, rank, friend code, edit (shell tab) |
| `/lobby` | Lobby — create public/private, join by code, quick play |
| `/room/:code` | Waiting room — players, room code, host start |
| `/game` | Game — cards, timer, UNO button, quick chat |
| `/results` | Results — winner, standings, +XP/+coins |
| `/settings` | Settings — theme, sound, push toggles, sign out |
| `/settings/privacy` | Privacy policy |

Shell: `StatefulShellRoute` — bottom `NavigationBar` (<600), `NavigationRail` (≥600), extended rail (>1024).

## Feature-first layout

```
lib/
  main.dart            # bootstrap only
  app/                 # app.dart, router.dart, theme.dart
  core/
    constants/         # config, breakpoints, insets, strings (KZ, centralized), catalog, game palette
    services/          # prefs, push (guarded FCM)
    utils/             # failures, nickname filter, code generators, rank
    widgets/           # AdaptiveScaffold, AsyncView, AvatarCircle, CoinChip
  features/
    auth/ home/ friends/ lobby/ game/ results/ shop/ missions/ settings/ profile/
      data/ domain/ presentation/
```

## Game engine (pure Dart, `features/game/domain`)

Deterministic reducer: `GameEngine.apply(state, action) -> state`. Fully unit-tested.
- Deck: standard 108 + safe specials (⭐ Star = extra turn, 🎁 Gift = pass a card, 🔄 Shuffle = shuffle-hands, 🌈 Rainbow = table accepts any color for one turn). No aggressive cards.
- Modes: Classic (30s timer), Family (standard deck, no timer), Fast (5 cards, 15s), Team 2v2.
- UNO button: at 2 cards; forgot → auto +2 penalty. Timeout → auto draw + pass. No stacking (child-simple).
- `GameSession` interface: `LocalGameSession` (bots) / `RemoteGameSession` (Supabase Realtime broadcast, host-authoritative).

## State: Riverpod v3

Logic in Notifier/AsyncNotifier only. `autoDispose` by default; session/profile is keepAlive. No Notifier families (one active game at a time).

## Data rule

UI → controller → repository (abstract) → local (shared_preferences) | Supabase impl. Typed `AppFailure`s; `AsyncValue` carries errors to UI. Every data screen: loading / error+Retry / empty / data.

## Dependencies (each justified)

- `flutter_riverpod` — state; `go_router` — web-correct URLs/deep links
- `shared_preferences` — local profile/settings persistence (small KV, no DB needed)
- `supabase_flutter` — auth + Postgres + Realtime in one web-compatible SDK
- `firebase_core`/`firebase_messaging` — push only (guarded init)
- No lottie (implicit animations + custom confetti painter), no image/network libs (avatars are emoji, cards drawn with widgets → tiny app size)

## Safety invariants (App Store 4+/Everyone)

No free-form chat anywhere (Quick Chat phrase IDs only travel over the wire), no user media, preset avatars only, nickname filter (profanity/phone/link/email), friends only via `UNO-XXXX-XXXX` code, private rooms via 6-char code, soft push texts only, cosmetic-only monetization, no loot boxes.
