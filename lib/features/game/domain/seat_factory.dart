import 'dart:math';

import '../../../core/constants/catalog.dart';
import '../../auth/domain/player_profile.dart';
import 'game_state.dart';

/// Builds the seat list for a match: the human plus friendly bots to fill
/// the table. Also used to top up a room with bots.
abstract final class SeatFactory {
  static const int defaultBotCount = 3;

  static List<GamePlayer> withBots({
    required PlayerProfile me,
    required int botCount,
    Random? random,
  }) {
    final rng = random ?? Random();
    final names = [...BotNames.all]..shuffle(rng);
    final avatars = [...Avatars.free]..shuffle(rng);
    return [
      GamePlayer(
        id: me.id,
        name: me.nickname,
        avatarId: me.avatarId,
        isBot: false,
      ),
      for (var i = 0; i < botCount; i++)
        GamePlayer(
          id: 'bot_$i',
          name: names[i % names.length],
          avatarId: avatars[i % avatars.length].id,
          isBot: true,
        ),
    ];
  }

  /// Fills [humans] up to [targetSeats] with bots (used by lobby host).
  static List<GamePlayer> fillWithBots({
    required List<GamePlayer> humans,
    required int targetSeats,
    Random? random,
  }) {
    final rng = random ?? Random();
    final names = [...BotNames.all]..shuffle(rng);
    final avatars = [...Avatars.free]..shuffle(rng);
    final seats = [...humans];
    var i = 0;
    while (seats.length < targetSeats) {
      seats.add(
        GamePlayer(
          id: 'bot_$i',
          name: names[i % names.length],
          avatarId: avatars[i % avatars.length].id,
          isBot: true,
        ),
      );
      i++;
    }
    return seats;
  }
}
