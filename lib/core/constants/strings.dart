import '../localization/app_locale.dart';

/// Every user-facing string lives here, in three languages (KK/RU/EN).
/// Centralized so switching language (Settings) never needs to touch any
/// screen — screens only ever read `S.xxx`.
abstract final class S {
  /// Set by `LocaleController`; reading it dynamically (not `const`) is
  /// what makes every `S.xxx` getter below react to a language switch.
  static AppLocale locale = AppLocale.kk;

  static T _v<T>({required T kk, required T ru, required T en}) =>
      switch (locale) {
        AppLocale.kk => kk,
        AppLocale.ru => ru,
        AppLocale.en => en,
      };

  // App
  static const appName = 'UNO FAMILY';
  static String get tagline => _v(
    kk: 'Отбасыңмен және достарыңмен қауіпсіз ойна',
    ru: 'Играй безопасно с семьёй и друзьями',
    en: 'Play safely with family and friends',
  );
  static String get languageLabel => _v(kk: 'Тіл', ru: 'Язык', en: 'Language');

  // Common
  static String get retry => _v(kk: 'Қайталау', ru: 'Повторить', en: 'Retry');
  static String get cancel => _v(kk: 'Бас тарту', ru: 'Отмена', en: 'Cancel');
  static String get ok => _v(kk: 'Жарайды', ru: 'Хорошо', en: 'OK');
  static String get save => _v(kk: 'Сақтау', ru: 'Сохранить', en: 'Save');
  static String get close => _v(kk: 'Жабу', ru: 'Закрыть', en: 'Close');
  static String get copied =>
      _v(kk: 'Көшірілді!', ru: 'Скопировано!', en: 'Copied!');
  static String get loading =>
      _v(kk: 'Жүктелуде...', ru: 'Загрузка...', en: 'Loading...');
  static String get unknownError => _v(
    kk: 'Бір қателік болды. Қайталап көріңіз.',
    ru: 'Произошла ошибка. Попробуйте ещё раз.',
    en: 'Something went wrong. Please try again.',
  );
  static String get networkError => _v(
    kk: 'Байланыс қатесі. Интернетті тексеріңіз.',
    ru: 'Ошибка сети. Проверьте интернет.',
    en: 'Network error. Check your connection.',
  );
  static String get notFoundError =>
      _v(kk: 'Табылмады.', ru: 'Не найдено.', en: 'Not found.');
  static String get localModeBadge =>
      _v(kk: 'Локал режим', ru: 'Локальный режим', en: 'Local mode');
  static String get onlineOnlyTitle => _v(
    kk: 'Онлайн режим қосылмаған',
    ru: 'Онлайн-режим не подключён',
    en: 'Online mode not connected',
  );
  static String get onlineOnlyBody => _v(
    kk:
        'Бұл мүмкіндік Supabase серверімен жұмыс істейді. Қазір қосымша локал '
        'режимде: боттармен ойнау, дүкен және тапсырмалар толық жұмыс істейді. '
        'Онлайн режимді қосу жолы README файлында жазылған.',
    ru:
        'Эта функция работает через сервер Supabase. Сейчас приложение в '
        'локальном режиме: игра с ботами, магазин и задания работают '
        'полностью. Как включить онлайн-режим — смотрите README.',
    en:
        'This feature needs a Supabase server. Right now the app runs in '
        'local mode: playing with bots, the shop and missions all work '
        'fully. See the README for how to enable online mode.',
  );

  // Navigation
  static String get navHome => _v(kk: 'Басты', ru: 'Главная', en: 'Home');
  static String get navFriends => _v(kk: 'Достар', ru: 'Друзья', en: 'Friends');
  static String get navShop => _v(kk: 'Дүкен', ru: 'Магазин', en: 'Shop');
  static String get navProfile =>
      _v(kk: 'Профиль', ru: 'Профиль', en: 'Profile');

  // Login
  static String get loginTitle =>
      _v(kk: 'Қош келдің!', ru: 'Добро пожаловать!', en: 'Welcome!');
  static String get loginSubtitle => _v(
    kk: 'Барлық режимдерді ашып, әлем бойынша жарыс',
    ru: 'Открой все режимы и соревнуйся по всему миру',
    en: 'Unlock every mode and compete worldwide',
  );
  static String get unlockPerkModes => _v(
    kk: 'Family, Fast және Team 2v2 режимдері',
    ru: 'Режимы Family, Fast и Team 2v2',
    en: 'Family, Fast and Team 2v2 modes',
  );
  static String get unlockPerkFriends => _v(
    kk: 'Достармен ойнау және шақыру',
    ru: 'Игра и приглашения с друзьями',
    en: 'Play and invite friends',
  );
  static String get unlockPerkLeaderboard => _v(
    kk: 'Әлемдік рейтингте орын алу',
    ru: 'Место в мировом рейтинге',
    en: 'A spot on the world leaderboard',
  );
  static String get unlockPerkSync => _v(
    kk: 'Прогресс кез келген құрылғыда сақталады',
    ru: 'Прогресс сохраняется на любом устройстве',
    en: 'Progress synced across every device',
  );
  static String get signInGoogle => _v(
    kk: 'Google арқылы кіру',
    ru: 'Войти через Google',
    en: 'Sign in with Google',
  );
  static String get signInApple => _v(
    kk: 'Apple арқылы кіру',
    ru: 'Войти через Apple',
    en: 'Sign in with Apple',
  );
  static String get signInEmail => _v(
    kk: 'Email арқылы кіру',
    ru: 'Войти через Email',
    en: 'Sign in with Email',
  );
  static const emailLabel = 'Email';
  static String get passwordLabel =>
      _v(kk: 'Құпиясөз', ru: 'Пароль', en: 'Password');
  static String get signIn => _v(kk: 'Кіру', ru: 'Войти', en: 'Sign in');
  static String get signUp =>
      _v(kk: 'Тіркелу', ru: 'Регистрация', en: 'Sign up');
  static String get noAccountYet => _v(
    kk: 'Аккаунт жоқ па? Тіркелу',
    ru: 'Нет аккаунта? Зарегистрироваться',
    en: 'No account? Sign up',
  );
  static String get haveAccount => _v(
    kk: 'Аккаунт бар ма? Кіру',
    ru: 'Уже есть аккаунт? Войти',
    en: 'Have an account? Sign in',
  );
  static String get invalidEmail =>
      _v(kk: 'Email дұрыс емес', ru: 'Некорректный email', en: 'Invalid email');
  static String get passwordTooShort => _v(
    kk: 'Құпиясөз кемінде 6 таңба',
    ru: 'Пароль минимум 6 символов',
    en: 'Password must be at least 6 characters',
  );
  static String get confirmEmailSent => _v(
    kk:
        'Email-ыңа растау хат жіберілді. Хаттағы сілтемені бас, содан кейін '
        'осы email/құпиясөзбен кір.',
    ru:
        'На твой email отправлено письмо с подтверждением. Перейди по '
        'ссылке в письме, затем войди с этим email и паролем.',
    en:
        'A confirmation email was sent. Click the link in it, then sign '
        'in with this email and password.',
  );
  static String get createProfileTitle =>
      _v(kk: 'Профиль құру', ru: 'Создание профиля', en: 'Create profile');
  static String get nicknameLabel =>
      _v(kk: 'Никнейм', ru: 'Никнейм', en: 'Nickname');
  static String get nicknameHint => _v(
    kk: '3–16 таңба: әріп, сан, _',
    ru: '3–16 символов: буквы, цифры, _',
    en: '3–16 characters: letters, digits, _',
  );
  static String get chooseAvatar =>
      _v(kk: 'Аватар таңда', ru: 'Выбери аватар', en: 'Choose an avatar');
  static String get birthYearLabel =>
      _v(kk: 'Туған жылың', ru: 'Год рождения', en: 'Birth year');
  static String get startPlaying =>
      _v(kk: 'Ойынды бастау', ru: 'Начать игру', en: 'Start playing');
  static String get childModeInfo => _v(
    kk:
        '13 жасқа дейінгі ойыншыларға балалар режимі қосылады: дайын фразалар, '
        'дос қосу тек код арқылы, push-хабарламалар шектеулі.',
    ru:
        'Игрокам младше 13 лет включается детский режим: готовые фразы, '
        'добавление друзей только по коду, push-уведомления ограничены.',
    en:
        'Players under 13 get Child Mode: preset phrases only, friends '
        'added by code only, limited push notifications.',
  );
  static String get childBadge =>
      _v(kk: 'Балалар режимі', ru: 'Детский режим', en: 'Child mode');

  // Nickname filter
  static String get nickTooShort => _v(
    kk: 'Тым қысқа (кемінде 3 таңба)',
    ru: 'Слишком коротко (минимум 3 символа)',
    en: 'Too short (minimum 3 characters)',
  );
  static String get nickTooLong => _v(
    kk: 'Тым ұзын (ең көбі 16 таңба)',
    ru: 'Слишком длинно (максимум 16 символов)',
    en: 'Too long (maximum 16 characters)',
  );
  static String get nickBadChars => _v(
    kk: 'Тек әріп, сан және _ қолдан',
    ru: 'Только буквы, цифры и _',
    en: 'Only letters, digits and _',
  );
  static String get nickBanned => _v(
    kk: 'Бұл никнеймді қолдануға болмайды',
    ru: 'Этот никнейм использовать нельзя',
    en: "This nickname isn't allowed",
  );
  static String get nickNoContacts => _v(
    kk: 'Телефон, сілтеме немесе email қолдануға болмайды',
    ru: 'Нельзя использовать телефон, ссылку или email',
    en: "Phone numbers, links or emails aren't allowed",
  );

  // Home
  static String greeting(String name) =>
      _v(kk: 'Сәлем, $name! 👋', ru: 'Привет, $name! 👋', en: 'Hi, $name! 👋');
  static String get playNow => _v(kk: 'Ойнау', ru: 'Играть', en: 'Play');
  static String get quickPlay =>
      _v(kk: 'Жылдам ойын', ru: 'Быстрая игра', en: 'Quick play');
  static String get playWithFriends => _v(
    kk: 'Достармен ойнау',
    ru: 'Играть с друзьями',
    en: 'Play with friends',
  );
  static String get chooseMode =>
      _v(kk: 'Режим таңда', ru: 'Выбери режим', en: 'Choose a mode');
  static const modeClassic = 'Classic';
  static String get modeClassicDesc => _v(
    kk: 'Кәдімгі UNO + қауіпсіз арнайы карталар',
    ru: 'Классический UNO + безопасные спецкарты',
    en: 'Classic UNO + safe special cards',
  );
  static const modeFamily = 'Family';
  static String get modeFamilyDesc => _v(
    kk: 'Тек стандарт карталар, таймер жоқ',
    ru: 'Только стандартные карты, без таймера',
    en: 'Standard cards only, no timer',
  );
  static const modeFast = 'Fast';
  static String get modeFastDesc => _v(
    kk: '5 карта, 15 секунд — жылдам ойын',
    ru: '5 карт, 15 секунд — быстрая игра',
    en: '5 cards, 15 seconds — a fast round',
  );
  static const modeTeam = 'Team 2v2';
  static String get modeTeamDesc => _v(
    kk: 'Екі топ болып ойнайтын отбасылық режим',
    ru: 'Семейный режим: две команды',
    en: 'A family mode with two teams',
  );
  static String get lockedBadge =>
      _v(kk: 'Құлыпты', ru: 'Закрыто', en: 'Locked');
  static String get guestGateTitle => _v(
    kk: 'Бұл режим тіркелгенге ашылады',
    ru: 'Этот режим открывается после входа',
    en: 'Sign in to unlock this mode',
  );
  static String get guestGateBody => _v(
    kk:
        'Қонақ ретінде тек Classic ойнай аласың. Тіркеліп, Family, Fast, '
        'Team 2v2 режимдерін және әлемдік рейтингті аш.',
    ru:
        'В гостевом режиме доступен только Classic. Войди, чтобы открыть '
        'Family, Fast, Team 2v2 и мировой рейтинг.',
    en:
        'Guests can only play Classic. Sign in to unlock Family, Fast, '
        'Team 2v2 and the world leaderboard.',
  );
  static String get signInNow =>
      _v(kk: 'Қазір кіру', ru: 'Войти сейчас', en: 'Sign in now');
  static String get maybeLater =>
      _v(kk: 'Кейінірек', ru: 'Позже', en: 'Maybe later');
  static String get guestProfileBannerTitle => _v(
    kk: 'Сен қонақ режиміндесің',
    ru: 'Ты в гостевом режиме',
    en: "You're playing as a guest",
  );
  static String get guestProfileBannerBody => _v(
    kk: 'Тіркеліп, барлық режимдер мен әлемдік рейтингті аш',
    ru: 'Войди, чтобы открыть все режимы и мировой рейтинг',
    en: 'Sign in to unlock every mode and the world leaderboard',
  );

  // Missions
  static String get missionsTitle => _v(
    kk: 'Күнделікті тапсырмалар',
    ru: 'Ежедневные задания',
    en: 'Daily missions',
  );
  static String get missionClaim => _v(kk: 'Алу', ru: 'Забрать', en: 'Claim');
  static String get missionClaimed =>
      _v(kk: 'Алынды', ru: 'Забрано', en: 'Claimed');
  static String get missionPlayOne =>
      _v(kk: '1 ойын ойна', ru: 'Сыграй 1 игру', en: 'Play 1 game');
  static String get missionSayUno =>
      _v(kk: '3 рет UNO айт', ru: 'Скажи UNO 3 раза', en: 'Say UNO 3 times');
  static String get missionPlayCards =>
      _v(kk: '15 карта таста', ru: 'Сыграй 15 карт', en: 'Play 15 cards');
  static String get missionWinOne =>
      _v(kk: '1 жеңіске жет', ru: 'Одержи 1 победу', en: 'Get 1 win');
  static String missionReward(int coins) => '+$coins Coins';

  // Rank / season
  static String get rankTitle => _v(kk: 'Рейтинг', ru: 'Рейтинг', en: 'Rank');
  static const rankBronze = 'Bronze';
  static const rankSilver = 'Silver';
  static const rankGold = 'Gold';
  static const rankPlatinum = 'Platinum';
  static const rankDiamond = 'Diamond';
  static String seasonLabel(String month) =>
      _v(kk: '$month маусымы', ru: 'Сезон: $month', en: '$month season');
  static String rankPointsLabel(int points) =>
      _v(kk: '$points ұпай', ru: '$points очков', en: '$points points');
  static String get leaderboardTitle =>
      _v(kk: 'Әлемдік рейтинг', ru: 'Мировой рейтинг', en: 'World leaderboard');
  static String get leaderboardEmpty => _v(
    kk: 'Әзірге ешкім ойнаған жоқ',
    ru: 'Пока никто не играл',
    en: 'No one has played yet',
  );
  static String get leaderboardYou => _v(kk: 'Сен', ru: 'Ты', en: 'You');
  static List<String> get monthNames => _v(
    kk: const [
      'Қаңтар',
      'Ақпан',
      'Наурыз',
      'Сәуір',
      'Мамыр',
      'Маусым',
      'Шілде',
      'Тамыз',
      'Қыркүйек',
      'Қазан',
      'Қараша',
      'Желтоқсан',
    ],
    ru: const [
      'Январь',
      'Февраль',
      'Март',
      'Апрель',
      'Май',
      'Июнь',
      'Июль',
      'Август',
      'Сентябрь',
      'Октябрь',
      'Ноябрь',
      'Декабрь',
    ],
    en: const [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ],
  );

  // Friends
  static String get friendsTitle =>
      _v(kk: 'Достар', ru: 'Друзья', en: 'Friends');
  static String get yourFriendCode =>
      _v(kk: 'Сенің дос кодың', ru: 'Твой код друга', en: 'Your friend code');
  static String get friendCodeExplain => _v(
    kk: 'Дос қосу тек осы код арқылы. Кодты тек таныс адамдарға бер.',
    ru: 'Друга можно добавить только по этому коду. Делись им только со знакомыми.',
    en: 'Friends can only be added with this code. Only share it with people you know.',
  );
  static String get addFriend =>
      _v(kk: 'Дос қосу', ru: 'Добавить друга', en: 'Add friend');
  static const friendCodeHint = 'UNO-1234-5678';
  static String get add => _v(kk: 'Қосу', ru: 'Добавить', en: 'Add');
  static String get friendAdded => _v(
    kk: 'Дос қосылды! 🎉',
    ru: 'Друг добавлен! 🎉',
    en: 'Friend added! 🎉',
  );
  static String get invalidFriendCode => _v(
    kk: 'Код форматы дұрыс емес',
    ru: 'Неверный формат кода',
    en: 'Invalid code format',
  );
  static String get friendNotFound => _v(
    kk: 'Бұл кодпен ойыншы табылмады',
    ru: 'Игрок с этим кодом не найден',
    en: 'No player found with this code',
  );
  static String get cantAddSelf => _v(
    kk: 'Өз кодыңды қоса алмайсың 😄',
    ru: 'Нельзя добавить самого себя 😄',
    en: "You can't add yourself 😄",
  );
  static String get alreadyFriends => _v(
    kk: 'Бұл ойыншы досың ғой',
    ru: 'Этот игрок уже твой друг',
    en: 'This player is already your friend',
  );
  static String get noFriendsYet =>
      _v(kk: 'Әзірге дос жоқ', ru: 'Пока нет друзей', en: 'No friends yet');
  static String get noFriendsHint => _v(
    kk: 'Досыңның кодын енгізіп, бірге ойнауды баста!',
    ru: 'Введи код друга и начни играть вместе!',
    en: "Enter a friend's code to start playing together!",
  );
  static String get inviteToGame =>
      _v(kk: 'Ойынға шақыру', ru: 'Пригласить в игру', en: 'Invite to game');
  static String get inviteSent => _v(
    kk: 'Шақыру жіберілді!',
    ru: 'Приглашение отправлено!',
    en: 'Invite sent!',
  );
  static String get inviteFriend =>
      _v(kk: 'Досты шақыру', ru: 'Пригласить друга', en: 'Invite a friend');
  static String get inviteFriendSubtitle => _v(
    kk: 'Досың тікелей осы бөлмеге кіреді',
    ru: 'Друг зайдёт прямо в эту комнату',
    en: 'Your friend joins this room directly',
  );
  static String get noFriendsToInvite => _v(
    kk: 'Әзірге шақыратын дос жоқ. Алдымен дос қос!',
    ru: 'Пока некого приглашать. Сначала добавь друга!',
    en: 'No friends to invite yet. Add a friend first!',
  );
  static String get inviteReceivedTitle => _v(
    kk: 'Ойынға шақыру! 🎉',
    ru: 'Приглашение в игру! 🎉',
    en: 'Game invite! 🎉',
  );
  static String inviteReceivedBody(String name) => _v(
    kk: '$name сені ойынға шақырды',
    ru: '$name приглашает тебя в игру',
    en: '$name invited you to play',
  );
  static String get inviteReceivedGeneric => _v(
    kk: 'Досың сені ойынға шақырды',
    ru: 'Друг приглашает тебя в игру',
    en: 'A friend invited you to play',
  );
  static String get removeFriend =>
      _v(kk: 'Достан шығару', ru: 'Удалить из друзей', en: 'Remove friend');
  static String removeFriendConfirm(String name) => _v(
    kk: '$name досыңнан шығарылсын ба?',
    ru: 'Удалить $name из друзей?',
    en: 'Remove $name from your friends?',
  );
  static String placeholderFriendName(String suffix) =>
      _v(kk: 'Дос $suffix', ru: 'Друг $suffix', en: 'Friend $suffix');

  // Lobby
  static String get lobbyTitle => _v(kk: 'Лобби', ru: 'Лобби', en: 'Lobby');
  static String get createRoom =>
      _v(kk: 'Бөлме құру', ru: 'Создать комнату', en: 'Create room');
  static String get publicRoom =>
      _v(kk: 'Ашық бөлме', ru: 'Открытая комната', en: 'Public room');
  static String get publicRoomDesc => _v(
    kk: 'Кез келген ойыншы қосыла алады',
    ru: 'Может присоединиться любой игрок',
    en: 'Any player can join',
  );
  static String get privateRoom =>
      _v(kk: 'Жабық бөлме', ru: 'Закрытая комната', en: 'Private room');
  static String get privateRoomDesc => _v(
    kk: 'Тек код білетін достар кіреді',
    ru: 'Заходят только те, кто знает код',
    en: 'Only people with the code can join',
  );
  static String get joinByCode =>
      _v(kk: 'Кодпен қосылу', ru: 'Войти по коду', en: 'Join by code');
  static const roomCodeHint = 'ABCD12';
  static String get join => _v(kk: 'Қосылу', ru: 'Войти', en: 'Join');
  static String get invalidRoomCode => _v(
    kk: 'Бөлме коды 6 таңба болу керек',
    ru: 'Код комнаты должен быть из 6 символов',
    en: 'Room code must be 6 characters',
  );
  static String get roomNotFound => _v(
    kk: 'Бөлме табылмады немесе ойын басталып кеткен',
    ru: 'Комната не найдена или игра уже началась',
    en: "Room not found, or the game has already started",
  );
  static String get playersLabel =>
      _v(kk: 'Ойыншылар', ru: 'Игроки', en: 'Players');
  static String get playVsBots =>
      _v(kk: 'Боттармен ойнау', ru: 'Играть с ботами', en: 'Play vs bots');
  static String get botsDesc => _v(
    kk: 'Интернетсіз бірден ойна',
    ru: 'Играй сразу, без интернета',
    en: 'Play instantly, no internet needed',
  );

  // Room (waiting)
  static String get waitingRoom =>
      _v(kk: 'Күту бөлмесі', ru: 'Комната ожидания', en: 'Waiting room');
  static String get roomCodeLabel =>
      _v(kk: 'Бөлме коды', ru: 'Код комнаты', en: 'Room code');
  static String get shareCodeHint => _v(
    kk: 'Осы кодты досыңа айт — ол «Кодпен қосылу» арқылы кіреді.',
    ru: 'Скажи этот код другу — он войдёт через «Войти по коду».',
    en: 'Share this code with a friend — they join via "Join by code".',
  );
  static String get startGame =>
      _v(kk: 'Ойынды бастау', ru: 'Начать игру', en: 'Start game');
  static String get waitingForHost => _v(
    kk: 'Хост ойынды бастағанын күтеміз...',
    ru: 'Ждём, пока хост начнёт игру...',
    en: 'Waiting for the host to start...',
  );
  static String get hostBadge => _v(kk: 'Хост', ru: 'Хост', en: 'Host');
  static String get youLabel => _v(kk: 'Сен', ru: 'Ты', en: 'You');
  static String get leaveRoom => _v(kk: 'Шығу', ru: 'Выйти', en: 'Leave');
  static String get needTwoPlayers => _v(
    kk: 'Бастау үшін кемінде 2 ойыншы керек',
    ru: 'Для старта нужно минимум 2 игрока',
    en: 'At least 2 players are needed to start',
  );
  static String get roomClosed =>
      _v(kk: 'Бөлме жабылды', ru: 'Комната закрыта', en: 'Room closed');
  static String get addBot =>
      _v(kk: 'Бот қосу', ru: 'Добавить бота', en: 'Add bot');

  // Game
  static String get yourTurn =>
      _v(kk: 'Сенің кезегің!', ru: 'Твой ход!', en: 'Your turn!');
  static String turnOf(String name) =>
      _v(kk: '$name жүреді', ru: 'Ходит $name', en: "$name's turn");
  static const unoButton = 'UNO!';
  static String get drawCard =>
      _v(kk: 'Карта алу', ru: 'Взять карту', en: 'Draw card');
  static String get finishTurn =>
      _v(kk: 'Кезекті аяқтау', ru: 'Завершить ход', en: 'End turn');
  static String get drawnCardHint => _v(
    kk: 'Түскен картаны ойна немесе кезекті аяқта',
    ru: 'Сыграй взятую карту или заверши ход',
    en: 'Play the drawn card or end your turn',
  );
  static String saidUno(String name) => '$name: UNO! 🔥';
  static String unoPenalty(String name) => _v(
    kk: '$name UNO айтуды ұмытты: +2 карта',
    ru: '$name забыл сказать UNO: +2 карты',
    en: '$name forgot to say UNO: +2 cards',
  );
  static String cardsCount(int n) =>
      _v(kk: '$n карта', ru: '$n карт', en: '$n cards');
  static String get chooseColor =>
      _v(kk: 'Түс таңда', ru: 'Выбери цвет', en: 'Choose a color');
  static String get quickChat =>
      _v(kk: 'Жылдам чат', ru: 'Быстрый чат', en: 'Quick chat');
  static String timeoutDraw(String name) => _v(
    kk: '$name үлгермеді — 1 карта алды',
    ru: '$name не успел — взял 1 карту',
    en: '$name ran out of time — drew 1 card',
  );
  static String playedSkip(String name) => _v(
    kk: '$name кезекті өткізеді',
    ru: '$name пропускает ход',
    en: '$name skips a turn',
  );
  static String get reversedDirection => _v(
    kk: 'Бағыт өзгерді! 🔄',
    ru: 'Направление изменилось! 🔄',
    en: 'Direction reversed! 🔄',
  );
  static String drewTwo(String name) => _v(
    kk: '$name +2 карта алды',
    ru: '$name взял +2 карты',
    en: '$name drew +2 cards',
  );
  static String drewFour(String name) => _v(
    kk: '$name +4 карта алды',
    ru: '$name взял +4 карты',
    en: '$name drew +4 cards',
  );
  static String extraTurn(String name) => _v(
    kk: '⭐ $name тағы бір рет жүреді',
    ru: '⭐ $name ходит ещё раз',
    en: '⭐ $name goes again',
  );
  static String giftedCard(String from, String to) => _v(
    kk: '🎁 $from → $to: 1 карта сыйлады',
    ru: '🎁 $from → $to: подарил 1 карту',
    en: '🎁 $from → $to: gifted 1 card',
  );
  static String get shuffledHands => _v(
    kk: '🔄 Барлық карталар араласып, қайта үлестірілді',
    ru: '🔄 Все карты перемешаны и розданы заново',
    en: "🔄 Everyone's cards were shuffled and redealt",
  );
  static String get rainbowActive => _v(
    kk: '🌈 Кез келген түсті тастауға болады!',
    ru: '🌈 Можно скидывать любой цвет!',
    en: '🌈 Any color can be played now!',
  );
  static String get leaveGameTitle =>
      _v(kk: 'Ойыннан шығу', ru: 'Выйти из игры', en: 'Leave game');
  static String get leaveGameConfirm => _v(
    kk: 'Ойыннан шықсаң, ол саған жеңіліс болып саналады. Шығасың ба?',
    ru: 'Если выйдешь из игры, это будет засчитано как поражение. Выйти?',
    en: "If you leave now, it'll count as a loss. Leave anyway?",
  );
  static String get leave => _v(kk: 'Шығу', ru: 'Выйти', en: 'Leave');
  static String get stay => _v(kk: 'Қалу', ru: 'Остаться', en: 'Stay');
  static String get drawPileLabel =>
      _v(kk: 'Колода', ru: 'Колода', en: 'Draw pile');

  // Quick chat phrases (the ONLY things players can "say")
  static List<String> get quickChatPhrases => _v(
    kk: const [
      '👋 Сәлем!',
      '🍀 Сәттілік!',
      '😄 Жақсы жүріс!',
      '🎉 Тамаша!',
      '👍 Керемет!',
      '🤝 Ойын үшін рақмет!',
    ],
    ru: const [
      '👋 Привет!',
      '🍀 Удачи!',
      '😄 Хороший ход!',
      '🎉 Отлично!',
      '👍 Класс!',
      '🤝 Спасибо за игру!',
    ],
    en: const [
      '👋 Hi!',
      '🍀 Good luck!',
      '😄 Nice move!',
      '🎉 Awesome!',
      '👍 Great!',
      '🤝 Thanks for the game!',
    ],
  );

  // Results
  static String get winTitle =>
      _v(kk: '🎉 Жеңіс!', ru: '🎉 Победа!', en: '🎉 Victory!');
  static String get goodGameTitle =>
      _v(kk: 'Жақсы ойын! 🤝', ru: 'Хорошая игра! 🤝', en: 'Good game! 🤝');
  static String winnerLabel(String name) =>
      _v(kk: 'Жеңімпаз: $name', ru: 'Победитель: $name', en: 'Winner: $name');
  static String teamWinLabel(String names) => _v(
    kk: 'Жеңімпаз топ: $names',
    ru: 'Команда-победитель: $names',
    en: 'Winning team: $names',
  );
  static String get standings =>
      _v(kk: 'Нәтижелер', ru: 'Результаты', en: 'Standings');
  static String xpGained(int xp) => '+$xp XP';
  static String coinsGained(int coins) => '+$coins Coins';
  static String rankGained(int p) => _v(
    kk: '+$p рейтинг ұпайы',
    ru: '+$p очков рейтинга',
    en: '+$p rank points',
  );
  static String get playAgain =>
      _v(kk: 'Тағы ойнау', ru: 'Играть снова', en: 'Play again');
  static String get goHome =>
      _v(kk: 'Басты бетке', ru: 'На главную', en: 'Go home');

  // Shop
  static String get shopTitle => _v(kk: 'Дүкен', ru: 'Магазин', en: 'Shop');
  static String get shopSubtitle => _v(
    kk: 'Тек косметика: нақты баға, нақты зат. Loot box жоқ.',
    ru: 'Только косметика: честная цена, честный товар. Loot box нет.',
    en: 'Cosmetics only: fixed price, exact item. No loot boxes.',
  );
  static String get catAvatars =>
      _v(kk: 'Аватарлар', ru: 'Аватары', en: 'Avatars');
  static String get catCardSkins =>
      _v(kk: 'Карта скиндері', ru: 'Скины карт', en: 'Card skins');
  static String get catTableThemes =>
      _v(kk: 'Үстел темалары', ru: 'Темы стола', en: 'Table themes');
  static String get catEmojiPacks =>
      _v(kk: 'Эмодзи топтамалары', ru: 'Наборы эмодзи', en: 'Emoji packs');

  // Shop item names (avatar packs / card skins / table themes)
  static String get itemJungle =>
      _v(kk: 'Джунгли', ru: 'Джунгли', en: 'Jungle');
  static String get itemSea => _v(kk: 'Теңіз', ru: 'Море', en: 'Sea');
  static String get itemSweets =>
      _v(kk: 'Тәттілер', ru: 'Сладости', en: 'Sweets');
  static String get itemNight => _v(kk: 'Түнгі', ru: 'Ночной', en: 'Night');
  static String get itemCandy => _v(kk: 'Кәмпит', ru: 'Конфетти', en: 'Candy');
  static String get itemBlueTable =>
      _v(kk: 'Көк үстел', ru: 'Синий стол', en: 'Blue table');
  static String get itemPurpleTable =>
      _v(kk: 'Күлгін үстел', ru: 'Фиолетовый стол', en: 'Purple table');
  static String get itemSunset =>
      _v(kk: 'Күн батысы', ru: 'Закат', en: 'Sunset');

  static String get buy => _v(kk: 'Сатып алу', ru: 'Купить', en: 'Buy');
  static String get equip => _v(kk: 'Қолдану', ru: 'Применить', en: 'Equip');
  static String get equipped =>
      _v(kk: 'Қолданулы', ru: 'Применено', en: 'Equipped');
  static String get ownedLabel =>
      _v(kk: 'Сенде бар', ru: 'У тебя есть', en: 'Owned');
  static String get notEnoughCoins => _v(
    kk: 'Coins жеткіліксіз. Ойнап жина! 🎮',
    ru: 'Недостаточно Coins. Играй и зарабатывай! 🎮',
    en: 'Not enough Coins. Play to earn more! 🎮',
  );
  static String get purchased =>
      _v(kk: 'Сатып алынды! 🎉', ru: 'Куплено! 🎉', en: 'Purchased! 🎉');

  // Profile
  static String get profileTitle =>
      _v(kk: 'Профиль', ru: 'Профиль', en: 'Profile');
  static String get levelLabel => _v(kk: 'Деңгей', ru: 'Уровень', en: 'Level');
  static String get statsTitle =>
      _v(kk: 'Статистика', ru: 'Статистика', en: 'Statistics');
  static String get gamesPlayed => _v(kk: 'Ойындар', ru: 'Игры', en: 'Games');
  static String get wins => _v(kk: 'Жеңістер', ru: 'Победы', en: 'Wins');
  static String get winRate => _v(kk: 'Жеңіс %', ru: 'Победы %', en: 'Win %');
  static String get editProfile => _v(
    kk: 'Профильді өзгерту',
    ru: 'Редактировать профиль',
    en: 'Edit profile',
  );
  static String get guestLabel => _v(kk: 'Қонақ', ru: 'Гость', en: 'Guest');

  // Settings
  static String get settingsTitle =>
      _v(kk: 'Баптаулар', ru: 'Настройки', en: 'Settings');
  static String get appearance =>
      _v(kk: 'Көрініс', ru: 'Внешний вид', en: 'Appearance');
  static String get themeSystem =>
      _v(kk: 'Жүйе', ru: 'Системная', en: 'System');
  static String get themeLight => _v(kk: 'Ашық', ru: 'Светлая', en: 'Light');
  static String get themeDark => _v(kk: 'Қараңғы', ru: 'Тёмная', en: 'Dark');
  static String get soundLabel =>
      _v(kk: 'Дыбыс пен діріл', ru: 'Звук и вибрация', en: 'Sound & vibration');
  static String get notificationsTitle =>
      _v(kk: 'Хабарламалар', ru: 'Уведомления', en: 'Notifications');
  static String get notifInvites => _v(
    kk: 'Достың шақыруы',
    ru: 'Приглашение от друга',
    en: 'Friend invites',
  );
  static String get notifDaily =>
      _v(kk: 'Күнделікті сыйлық', ru: 'Ежедневный подарок', en: 'Daily gift');
  static String get notifSeason =>
      _v(kk: 'Жаңа маусым', ru: 'Новый сезон', en: 'New season');
  static String get pushNotConfigured => _v(
    kk: 'Push-хабарламалар Firebase қосылғанда жұмыс істейді (README қараңыз).',
    ru: 'Push-уведомления заработают после подключения Firebase (см. README).',
    en: 'Push notifications will work once Firebase is connected (see README).',
  );
  static String get privacyPolicy => _v(
    kk: 'Құпиялылық саясаты',
    ru: 'Политика конфиденциальности',
    en: 'Privacy policy',
  );
  static String get aboutTitle =>
      _v(kk: 'Қосымша туралы', ru: 'О приложении', en: 'About');
  static String get signOut =>
      _v(kk: 'Аккаунттан шығу', ru: 'Выйти из аккаунта', en: 'Sign out');
  static String get signOutConfirm => _v(
    kk: 'Аккаунттан шығасың ба? Локал прогресс осы құрылғыда сақталады.',
    ru: 'Выйти из аккаунта? Локальный прогресс сохранится на этом устройстве.',
    en: 'Sign out? Local progress stays on this device.',
  );
  static String versionLabel(String v) =>
      _v(kk: 'Нұсқа $v', ru: 'Версия $v', en: 'Version $v');

  // Privacy policy (shown in-app, required by stores)
  static String get privacyBody => _v(
    kk: '''
UNO FAMILY — балалар мен отбасыларға арналған қауіпсіз онлайн карта ойыны.

1. Жеке хабарлама жоқ. Ойыншылар бір-біріне еркін мәтін жаза алмайды — тек алдын ала дайындалған қауіпсіз фразалар қолданылады.

2. Пайдаланушы контенті жүктелмейді. Фото, видео немесе өз суретін қою мүмкін емес. Аватарлар — тек дайын суреттер.

3. Деректер тек ойын прогресі үшін сақталады: никнейм, аватар, деңгей, ұпайлар және дос коды. Орналасқан жер, контактілер немесе құрылғыдағы файлдар жиналмайды.

4. Достар тек арнайы код арқылы қосылады. Бейтаныс адамдарды іздеу, ұсыну немесе оларға хабарласу мүмкіндігі жоқ.

5. Балалар режимі. 13 жасқа дейінгі ойыншыларға қосымша шектеулер қолданылады: push-хабарламалар шектеулі, барлық қарым-қатынас дайын фразалармен ғана.

6. Монетизация тек косметикаға қатысты: ұтыс мүмкіндігін арттыратын сатып алулар мен loot box жоқ.

7. Сұрақтар болса: support@unofamily.app
''',
    ru: '''
UNO FAMILY — безопасная онлайн карточная игра для детей и семей.

1. Никаких личных сообщений. Игроки не могут писать друг другу свободный текст — используются только заранее подготовленные безопасные фразы.

2. Пользовательский контент не загружается. Нельзя добавить фото, видео или своё изображение. Аватары — только готовые картинки.

3. Данные сохраняются только для игрового прогресса: никнейм, аватар, уровень, очки и код друга. Геолокация, контакты или файлы с устройства не собираются.

4. Друзья добавляются только по специальному коду. Поиск незнакомцев, рекомендации или связь с ними невозможны.

5. Детский режим. Для игроков младше 13 лет действуют дополнительные ограничения: push-уведомления ограничены, всё общение — только готовыми фразами.

6. Монетизация касается только косметики: покупок, повышающих шанс на победу, и loot box нет.

7. Вопросы: support@unofamily.app
''',
    en: '''
UNO FAMILY is a safe online card game for children and families.

1. No private messaging. Players cannot write free text to each other — only pre-approved safe phrases are used.

2. No user content is uploaded. Photos, videos or custom pictures cannot be added. Avatars are preset images only.

3. Data is stored only for game progress: nickname, avatar, level, points and friend code. Location, contacts or on-device files are never collected.

4. Friends are added only via a special code. Searching for strangers, suggestions or contacting them is not possible.

5. Child Mode. Players under 13 have extra restrictions: push notifications are limited, and all communication uses preset phrases only.

6. Monetization is cosmetic only: no purchases that improve your chance of winning, and no loot boxes.

7. Questions: support@unofamily.app
''',
  );

  // Mini-games (Home "Other games" section)
  static String get otherGames =>
      _v(kk: 'Басқа ойындар', ru: 'Другие игры', en: 'Other games');
  static String get memoryTitle =>
      _v(kk: 'Есте сақтау', ru: 'Память', en: 'Memory');
  static String get memoryDesc => _v(
    kk: 'Жұп карталарды тауып, есте сақта',
    ru: 'Находи пары карт и запоминай',
    en: 'Find the matching pairs',
  );
  static String get snapTitle => _v(kk: 'Тап!', ru: 'Хвать!', en: 'Snap!');
  static String get snapDesc => _v(
    kk: 'Бірдей карта шықса — бірінші бас!',
    ru: 'Одинаковые карты — жми первым!',
    en: 'Matching cards? Tap first!',
  );
  static String get crazy8sTitle =>
      _v(kk: 'Ако (8-лер)', ru: 'Восьмёрки', en: 'Crazy 8s');
  static String get crazy8sDesc => _v(
    kk: 'Түсі не саны сай карта таста, 8 — джокер',
    ru: 'Клади по масти или числу, 8 — джокер',
    en: 'Match suit or rank; 8s are wild',
  );

  // Memory game
  static String get moves => _v(kk: 'Жүріс', ru: 'Ходы', en: 'Moves');
  static String memoryWon(int moves) => _v(
    kk: '$moves жүрісте бітірдің! 🎉',
    ru: 'Готово за $moves ходов! 🎉',
    en: 'Done in $moves moves! 🎉',
  );
  static String get difficulty =>
      _v(kk: 'Деңгей', ru: 'Уровень', en: 'Difficulty');
  static String get easy => _v(kk: 'Оңай', ru: 'Легко', en: 'Easy');
  static String get medium => _v(kk: 'Орташа', ru: 'Средне', en: 'Medium');
  static String get hard => _v(kk: 'Қиын', ru: 'Сложно', en: 'Hard');

  // Snap game
  static String get snapButton => _v(kk: 'ТАП!', ru: 'ХВАТЬ!', en: 'SNAP!');
  static String get snapYourPile =>
      _v(kk: 'Сенің дестең', ru: 'Твоя стопка', en: 'Your pile');
  static String get snapBotPile =>
      _v(kk: 'Бот дестесі', ru: 'Стопка бота', en: 'Bot pile');
  static String get snapTooSoon =>
      _v(kk: 'Әлі емес!', ru: 'Рано!', en: 'Too soon!');
  static String get snapBotWon =>
      _v(kk: 'Бот бірінші болды', ru: 'Бот успел первым', en: 'Bot snapped first');
  static String get snapYouWon =>
      _v(kk: 'Дестені алдың!', ru: 'Стопка твоя!', en: 'You took the pile!');
  static String get snapTapWhenMatch => _v(
    kk: 'Екі бірдей карта шықса — ТАП баса ғой',
    ru: 'Две одинаковые карты — жми ХВАТЬ',
    en: 'Two matching cards? Hit SNAP',
  );
  static String get youWon => _v(kk: 'Сен жеңдің! 🏆', ru: 'Ты выиграл! 🏆', en: 'You won! 🏆');
  static String get botWon =>
      _v(kk: 'Бот жеңді', ru: 'Бот выиграл', en: 'Bot won');

  // Crazy 8s
  static String get yourTurnShort =>
      _v(kk: 'Сенің кезегің', ru: 'Твой ход', en: 'Your turn');
  static String get botThinking =>
      _v(kk: 'Бот ойлануда…', ru: 'Бот думает…', en: 'Bot is thinking…');
  static String get drawCard => _v(kk: 'Карта ал', ru: 'Взять карту', en: 'Draw');
  static String get chooseSuit =>
      _v(kk: 'Масть таңда', ru: 'Выбери масть', en: 'Choose a suit');
}
