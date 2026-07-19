# UNO FAMILY 🃏

Балалар мен отбасыларға арналған **child-safe** (4+ / Everyone / PEGI 3) онлайн
карта ойыны. Бір кодбаза — **Android + iOS + Web**. Flutter + Riverpod + go_router,
міндетті емес Supabase бэкенді және Firebase push.

## Қауіпсіздік ұстанымдары (App Store 4+ / Google Play Everyone)

- ❌ Еркін чат жоқ — тек алдын ала дайын **Quick Chat** фразалары желімен жүреді
- ❌ Дауыстық чат, пайдаланушы фото/видео/мәтіні жоқ
- ✅ Аватарлар — тек дайын суреттер (өз суретін қою мүмкін емес)
- ✅ Никнейм фильтрі: боғауыз, телефон, сілтеме, email бөгеленеді
- ✅ Достар тек `UNO-XXXX-XXXX` коды арқылы қосылады (бейтаныс іздеу жоқ)
- ✅ 13 жасқа дейінгілерге **балалар режимі** (push шектеулі)
- ✅ Монетизация тек косметика — loot box жоқ, pay-to-win жоқ
- ✅ Ешбір агрессивті карта жоқ (bomb/poison/curse орнына ⭐🎁🔄🌈)

## Онбординг: логин экраны жоқ

Қосымша ашылғанда бірден **гость профилі автоматты жасалады** — ешқандай
батырма басудың, форма толтырудың қажеті жоқ. Гость бірден **Classic**
режимін ойнай алады. Family/Fast/Team 2v2 режимдері мен әлемдік рейтингте
жоғары орын алу үшін «Кіру» (Google/Apple/Email) керек — локтелген режимге
басқанда түсіндірме sheet шығады. Profile бетінде де «Тіркеліп ал» баннері
тұрады.

## Екі жұмыс режимі

| Режим | Қашан | Не істейді |
|---|---|---|
| **Local** (әдепкі) | Кілттерсіз | Гость профилі (авто), боттармен **Classic** ойын, дүкен, тапсырмалар — офлайн. Кіру мүмкін емес болғандықтан Family/Fast/Team де ашылмайды (dev/тест үшін нормальный жайт) |
| **Online** | Supabase кілттерімен | + нақты авторизация (гость → толық аккаунт), кодпен достар, публичный matchmaking, жабық бөлмелер, **realtime** мультиплеер, әлемдік рейтинг |

Push (FCM) тек Firebase конфигурацияланғанда қосылады — ешқашан қосымшаны бөгемейді.

Локал режимде барлық 4 режимді сынап көру керек болса: `lib/features/home/presentation/home_screen.dart`
ішіндегі `guestLocked: isGuest` жолын уақытша `false`-қа өзгерт (тек dev
үшін — production build-те гость шектеуі сақталуы керек).

## Іске қосу (dev)

```powershell
flutter pub get
flutter run -d chrome            # Web (локал режим — бірден ойнауға болады)
flutter run -d <device>          # Android / iOS
```

PowerShell-де командаларды `&&`-мен тізбектеуге болмайды (Bash емес) — әр
команданы бөлек жолда жаз немесе `;` қолдан. Жоба ішінде жүрсең, `cd` де
қажет емес.

## Онлайн режимді қосу (Supabase)

Жоба **қосылып, схемасы қойылды**: `qkrwrbeostnosimuqiii` (URL мен
publishable кілт төменде дайын скрипттерге енгізілген). Supabase MCP арқылы
тексеріп, екі миграцияны да тікелей осы жобаға қойдым — `profiles`,
`friendships`, `rooms`, `room_actions`, `invites`, `device_tokens` кестелерінің
барлығы RLS қосулы күйде дайын тұр (`get_advisors` ешбір ескерту қоймады —
өз кестелеріміз бойынша таза). Қалғаны — бір ғана қадам:

**Екі тумблерді қолмен қосу керек** (Dashboard → Authentication → Sign In /
Providers — MCP-мен автоматты қойылмайды, платформа деңгейіндегі auth
конфигурациясы, SQL емес):

1. **Anonymous** → ON. Тексердім: дәл қазір `anonymous_users: false`.
   Гость авто-логин («ашылғанда бірден гость») дәл осыны талап етеді —
   өшірулі тұрса, гость профилі жасалмайды (қосымша қатпайды, бірақ
   профильсіз Home-де қалады).
2. **Email** провайдерінің ішінде **"Confirm email"** → OFF. Қазір ON
   тұр (`mailer_autoconfirm: false`), яғни тіркелгеннен кейін email
   растау керек. Өшірсең, тіркелгеннен кейін бірден кіреді (сессия
   бірден келеді).

Google/Apple provider де әзірге өшірулі — солар керек болса, сол жерден
қос (Google-ге Google Cloud Console-дан Client ID/Secret, Apple-ге Apple
Developer аккаунты керек).

**Іске қосу.** Дайын скрипт бар — кілттерді қолмен теріп жүрудің қажеті
жоқ:

```powershell
.\run_online.ps1                  # Chrome
.\run_online.ps1 -Device <id>     # Android/iOS device
```

Немесе қолмен:

```powershell
flutter run -d chrome --dart-define=SUPABASE_URL=https://qkrwrbeostnosimuqiii.supabase.co --dart-define=SUPABASE_ANON_KEY=sb_publishable_YIYmHuzo1jjmJ1T0vC2PXw_Ppu-lULq
```

## Push (Firebase, міндетті емес)

**Архитектура: Firebase деректі сақтамайды.** Firebase тек құрылғы push
токенін алу үшін қолданылады; сол токен Supabase-тегі `device_tokens`
кестесіне жүктеледі (клиент коды: `lib/core/services/push_service.dart` →
`syncToken`). Хабарламаны нақты жіберу **Supabase Edge Function**
(`supabase/functions/send-push/`) арқылы серверде болады — Firebase
Admin деректері тек сол функцияның ортасында (`FCM_SERVICE_ACCOUNT`
secret), қосымшада ешқашан сақталмайды.

### Күй — не дайын, не қалды

**Дайын (жасалды):**
- Android (`com.example.uno_family`) және iOS (`com.example.unoFamily`)
  Firebase-те тіркелген; `google-services.json` /
  `GoogleService-Info.plist` репозиторийге қойылып, Gradle-ге
  `com.google.gms.google-services` plugin қосылды. Android/iOS-та
  push endi қолмен define берудің қажеті жоқ — құрылғанда автоматты
  жұмыс істейді (`Firebase.initializeApp()` нативті файлды өзі оқиды).
- `FCM_SERVICE_ACCOUNT` secret Supabase-ке қойылды (сен жасадың).
- `send-push` Edge Function MCP арқылы деплой болды (Supabase Dashboard →
  Edge Functions → `send-push` → **ACTIVE**).
- SQL миграциялары (`0001`, `0002`) MCP арқылы қойылды — барлық 6 кесте
  RLS-пен дайын.

**Сенің қолыңнан керек 3 нәрсе:**

1. **Database Webhook (1 рет, 30 секунд).** `invites` кестесіне жазба
   түскенде `send-push`-ті шақыратын webhook-ті SQL арқылы автоматты
   қоя алмадым — Supabase бұл механизмді (`supabase_functions` схемасы)
   тек Dashboard арқылы бір рет қосқанда өзі дайындайды, ал ол сервис-рөл
   кілтін қауіпсіз өзі қол қояды (мен ол кілтті сұрамаймын — құпия
   болғандықтан). Dashboard → **Database → Webhooks → Create a new hook**:
   - Name: `invite_push`
   - Table: `invites` · Event: `INSERT`
   - Type: **Supabase Edge Function** → `send-push` таңда
   - Save.

2. **Anonymous auth қосу** (жоғарыда айтылды) — Dashboard → Authentication
   → Sign In / Providers → Anonymous.

3. **Web app тіркеу** (тек web push керек болса). Firebase Console →
   осы жобада (`uno0-779e5`) → ⚙️ Project settings → General → "Add app"
   → Web (`</>`). Одан кейін `apiKey`, `appId`, `messagingSenderId`
   (=`986924424996`, ортақ), `projectId` (=`uno0-779e5`) мәндерін ал және
   Cloud Messaging бетінен **Web Push certificates** → Generate key pair
   → VAPID кілтін ал. Осыларды `run_online.ps1` /
   `build_web_online.ps1` ішіндегі commented `FIREBASE_*` жолдарына қой.

### iOS push — APNs кілті қосу

FCM iOS-та жұмыс істеу үшін Apple-дың өз push кілті керек (Firebase
жеке өзі жібере алмайды, APNs арқылы өтеді):

1. [developer.apple.com](https://developer.apple.com) → Account →
   Certificates, Identifiers & Profiles → **Keys** → **+** →
   "Apple Push Notifications service (APNs)" тексер → Continue → Register.
2. `.p8` файлын жүкте — **бір рет ғана жүктеуге болады**, сақтап қой.
   Сол беттен **Key ID**-ды жаз; **Team ID** — аккаунт атыңның астында
   (Membership бетінде).
3. Firebase Console → осы жоба → ⚙️ Project settings → **Cloud Messaging**
   табы → "Apple app configuration" (iOS app-тың астында) → **APNs
   Authentication Key** → Upload → `.p8` файлды, Key ID мен Team ID-ды
   енгіз → Upload.
4. Identifiers → `com.example.unoFamily` App ID-де **Push Notifications**
   capability қосулы тұруы керек (әдетте автоматты қосылады).
5. Xcode-та (тек macOS-та құрғанда): Runner target → Signing & Capabilities
   → **+ Capability** → "Push Notifications" және "Background Modes →
   Remote notifications" қос.

Хабарламалар тек жұмсақ: «Досың шақырды», «Күнделікті сыйлық дайын», «Жаңа маусым».

## Тілдер

Қазақша / Русский / English — Settings → Тіл. Барлық мәтін
`lib/core/constants/strings.dart` файлында үш тілде орталықтандырылған
(`S.xxx` getter-лері ағымдағы тілге қарай мән қайтарады); тіл таңдауы
құрылғыда сақталады. Жаңа тіл қосу үшін сол файлдағы `_v(kk:, ru:, en:)`
үлгісіне төртінші тілді қосып, `AppLocale` enum-ын кеңейту жеткілікті.

## App icon

`assets/icon/icon.png` (`tool/generate_icon.dart` арқылы бағдарламалы
түрде салынған — брендтің күлгін-көк градиенті үстінде екі қиғаш карта
+ жұлдыз). Барлық платформа иконкасы (`flutter_launcher_icons.yaml`
конфигі бойынша) содан генерацияланды:

```bash
dart run tool/generate_icon.dart      # icon.png / icon_foreground.png қайта сал
dart run flutter_launcher_icons       # Android/iOS/Web иконкаларын жаңарту
```

## Release build

```bash
# Web (JS/CanvasKit) — статикалық файлдар build/web/ ішінде
flutter build web --release

# Web (WasmGC — жылдамырақ; екеуі де тексерілген)
flutter build web --release --wasm

# Android (Play үшін app bundle)
flutter build appbundle --release --obfuscate --split-debug-info=build/symbols

# iOS (macOS + Xcode қажет)
flutter build ipa --release --obfuscate --split-debug-info=build/symbols
```

Онлайн/push нұсқасын шығарғанда сол `--dart-define`-дарды build командасына
да қос — немесе дайын `.\build_web_online.ps1` скриптін қолдан.

### Деплой (Web)

`build/web/` — статикалық. Firebase Hosting / Netlify / Vercel-ге жүктеп қой.
Таза URL үшін (`/friends`) хост барлық жолды `index.html`-ге rewrite етуі керек
(бұл платформалар оны конфигпен жасайды). GitHub Pages-та subpath үшін:
`flutter build web --release --base-href "/repo-name/"`.

## Сапа

```bash
flutter analyze     # No issues found!
flutter test        # 40 тест өтеді (қозғалтқыш, фильтр, модельдер, ағын)
```

## Архитектура

Feature-first: `lib/features/<name>/{data,domain,presentation}`. Толығырақ —
[`ARCHITECTURE.md`](ARCHITECTURE.md). UNO ережелері таза Dart қозғалтқышында
(`lib/features/game/domain/game_engine.dart`), толық юнит-тесттелген.

## Экрандар

Splash · Login (опциональды upgrade) · Home · Friends · Lobby · Room ·
Game · Results · Shop · Profile · Settings · Privacy · **Leaderboard**
(жаңа) — бәрі жұмыс істейді (loading/error/empty/data күйлерімен,
телефон/планшет/веб бейімделуімен).
