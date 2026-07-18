/// The player. Data-minimal by design: no email/phone/photo is ever stored
/// here — only game progress. Birth year is never persisted, only the
/// derived [isChild] flag (COPPA-friendly).
class PlayerProfile {
  const PlayerProfile({
    required this.id,
    required this.nickname,
    required this.avatarId,
    required this.friendCode,
    this.xp = 0,
    this.coins = 100,
    this.rankPoints = 0,
    this.isChild = false,
    this.isGuest = false,
    this.gamesPlayed = 0,
    this.wins = 0,
    this.ownedItems = const {},
    this.cardSkinId = 'skin_classic',
    this.tableThemeId = 'theme_green',
  });

  final String id;
  final String nickname;
  final String avatarId;
  final String friendCode;
  final int xp;
  final int coins;
  final int rankPoints;
  final bool isChild;
  final bool isGuest;
  final int gamesPlayed;
  final int wins;
  final Set<String> ownedItems;
  final String cardSkinId;
  final String tableThemeId;

  static const int xpPerLevel = 100;
  int get level => xp ~/ xpPerLevel + 1;
  double get levelProgress => (xp % xpPerLevel) / xpPerLevel;
  int get winRatePercent =>
      gamesPlayed == 0 ? 0 : (wins * 100 / gamesPlayed).round();

  PlayerProfile copyWith({
    String? nickname,
    String? avatarId,
    int? xp,
    int? coins,
    int? rankPoints,
    int? gamesPlayed,
    int? wins,
    Set<String>? ownedItems,
    String? cardSkinId,
    String? tableThemeId,
  }) => PlayerProfile(
    id: id,
    nickname: nickname ?? this.nickname,
    avatarId: avatarId ?? this.avatarId,
    friendCode: friendCode,
    xp: xp ?? this.xp,
    coins: coins ?? this.coins,
    rankPoints: rankPoints ?? this.rankPoints,
    isChild: isChild,
    isGuest: isGuest,
    gamesPlayed: gamesPlayed ?? this.gamesPlayed,
    wins: wins ?? this.wins,
    ownedItems: ownedItems ?? this.ownedItems,
    cardSkinId: cardSkinId ?? this.cardSkinId,
    tableThemeId: tableThemeId ?? this.tableThemeId,
  );

  PlayerProfile afterMatch({
    required bool won,
    required int xpGain,
    required int coinGain,
    required int rankGain,
  }) => copyWith(
    xp: xp + xpGain,
    coins: coins + coinGain,
    rankPoints: rankPoints + rankGain,
    gamesPlayed: gamesPlayed + 1,
    wins: wins + (won ? 1 : 0),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'nickname': nickname,
    'avatar_id': avatarId,
    'friend_code': friendCode,
    'xp': xp,
    'coins': coins,
    'rank_points': rankPoints,
    'is_child': isChild,
    'is_guest': isGuest,
    'games': gamesPlayed,
    'wins': wins,
    'owned_items': ownedItems.toList(),
    'card_skin': cardSkinId,
    'table_theme': tableThemeId,
  };

  factory PlayerProfile.fromJson(Map<String, dynamic> json) => PlayerProfile(
    id: json['id'] as String,
    nickname: json['nickname'] as String,
    avatarId: json['avatar_id'] as String? ?? 'cat',
    friendCode: json['friend_code'] as String,
    xp: json['xp'] as int? ?? 0,
    coins: json['coins'] as int? ?? 0,
    rankPoints: json['rank_points'] as int? ?? 0,
    isChild: json['is_child'] as bool? ?? false,
    isGuest: json['is_guest'] as bool? ?? false,
    gamesPlayed: json['games'] as int? ?? 0,
    wins: json['wins'] as int? ?? 0,
    ownedItems: {
      for (final item in json['owned_items'] as List? ?? const [])
        item as String,
    },
    cardSkinId: json['card_skin'] as String? ?? 'skin_classic',
    tableThemeId: json['table_theme'] as String? ?? 'theme_green',
  );
}
