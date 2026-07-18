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

## Екі жұмыс режимі

| Режим | Қашан | Не істейді |
|---|---|---|
| **Local** (әдепкі) | Кілттерсіз | Қонақ профилі, боттармен ойын (4 режим), дүкен, тапсырмалар, рейтинг — бәрі офлайн |
| **Online** | Supabase кілттерімен | + нақты авторизация, кодпен достар, публичный matchmaking, жабық бөлмелер, **realtime** мультиплеер |

Push (FCM) тек Firebase конфигурацияланғанда қосылады — ешқашан қосымшаны бөгемейді.

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

**Anonymous auth қосу.** Тексердім: дәл қазір `anonymous_users: false`.
Dashboard → Authentication → Sign In / Providers → **Anonymous** → қос.
Бұл қонақ ретінде («Қонақ ретінде ойнау») кіру үшін міндетті — өшірулі
тұрса, guest sign-in қатемен аяқталады. Бұл жалғыз MCP арқылы автоматты
қойылмайтын баптау (auth config — SQL емес, dashboard toggle). Google/Apple
provider де әзірге өшірулі — солар керек болса, сол жерден қос (Client
ID/Secret қажет болады).

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

### Firebase жобасын ашу — нақты мәндер

Firebase Console → Add app баспас бұрын `com.company.appname` орнына
**осы жобаның нақты ID-лерін** жаз:

| Платформа | Өріс | Мән |
|---|---|---|
| Android | Package name | `com.example.uno_family` |
| iOS | Bundle ID | `com.example.unoFamily` |
| Web | (жеке "Web app" ретінде тіркеу керек — push үшін ол да қажет) | — |

- "App nickname" — кез келген атау (мыс. "UNO Family Android"), міндетті емес.
- "App Store ID" — әзірге бос қалдыр (App Store-ге шыққанда толтырасың).
- `google-services.json` / `GoogleService-Info.plist` жүктеудің **қажеті
  жоқ** — қосымша Firebase-ті `--dart-define` арқылы қолмен инициализациялайды
  (`FcmPushService.init()`), нативті конфиг файлдары репозиторийге түспейді.
- Әр 3 платформаны тіркегеннен кейін Project settings → General бетінен
  **Web app**-тың конфигін аш: сол жерден `apiKey`, `appId`,
  `messagingSenderId`, `projectId` мәндерін ал (үшеуі де платформалар
  арасында ортақ, бір Firebase жобасы жеткілікті).
- Push жіберу үшін: Project settings → Service accounts → **Generate new
  private key** (JSON). Осы JSON-ды Supabase-ке сала: `supabase secrets set
  FCM_SERVICE_ACCOUNT='<json мазмұны>'`, содан кейін `supabase functions
  deploy send-push`. Толығырақ — `supabase/functions/send-push/index.ts`
  файлының басындағы түсініктемеде.

Кілттерді алғаннан кейін `run_online.ps1` / `build_web_online.ps1`
ішіндегі commented Firebase жолдарын ашып, мәндерді қой.

Хабарламалар тек жұмсақ: «Досың шақырды», «Күнделікті сыйлық дайын», «Жаңа маусым».

## Тілдер

Қазақша / Русский / English — Settings → Тіл. Барлық мәтін
`lib/core/constants/strings.dart` файлында үш тілде орталықтандырылған
(`S.xxx` getter-лері ағымдағы тілге қарай мән қайтарады); тіл таңдауы
құрылғыда сақталады. Жаңа тіл қосу үшін сол файлдағы `_v(kk:, ru:, en:)`
үлгісіне төртінші тілді қосып, `AppLocale` enum-ын кеңейту жеткілікті.

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

Splash · Login · Home · Friends · Lobby · Room · Game · Results · Shop ·
Profile · Settings · Privacy — бәрі жұмыс істейді (loading/error/empty/data
күйлерімен, телефон/планшет/веб бейімделуімен).
