import 'package:flutter_test/flutter_test.dart';
import 'package:uno_family/core/utils/code_gen.dart';
import 'package:uno_family/core/utils/rank.dart';
import 'package:uno_family/features/auth/domain/player_profile.dart';
import 'package:uno_family/features/game/domain/game_mode.dart';
import 'package:uno_family/features/game/domain/game_state.dart';
import 'package:uno_family/features/game/domain/uno_card.dart';

void main() {
  group('PlayerProfile', () {
    test('json round-trips', () {
      const profile = PlayerProfile(
        id: 'u1',
        nickname: 'Aru',
        avatarId: 'fox',
        friendCode: 'UNO-1234-5678',
        xp: 250,
        coins: 80,
        rankPoints: 120,
        ownedItems: {'pack_sea', 'skin_night'},
      );
      final restored = PlayerProfile.fromJson(profile.toJson());
      expect(restored.nickname, 'Aru');
      expect(restored.avatarId, 'fox');
      expect(restored.rankPoints, 120);
      expect(restored.ownedItems, contains('pack_sea'));
    });

    test('level and win rate derive correctly', () {
      const profile = PlayerProfile(
        id: 'u',
        nickname: 'n',
        avatarId: 'cat',
        friendCode: 'UNO-0000-0000',
        xp: 250,
        gamesPlayed: 4,
        wins: 3,
      );
      expect(profile.level, 3); // 250 ~/ 100 + 1
      expect(profile.winRatePercent, 75);
    });

    test('afterMatch accumulates rewards', () {
      const profile = PlayerProfile(
        id: 'u',
        nickname: 'n',
        avatarId: 'cat',
        friendCode: 'UNO-0000-0000',
      );
      final next = profile.afterMatch(
        won: true,
        xpGain: 25,
        coinGain: 10,
        rankGain: 15,
      );
      expect(next.xp, 25);
      expect(next.wins, 1);
      expect(next.gamesPlayed, 1);
    });
  });

  group('GameState json', () {
    test('round-trips a small state', () {
      const s = GameState(
        roomId: 'r',
        mode: GameMode.family,
        players: [
          GamePlayer(
            id: 'a',
            name: 'A',
            avatarId: 'cat',
            isBot: false,
            hand: [
              UnoCard(
                id: 'c1',
                color: CardColor.red,
                type: CardType.number,
                number: 4,
              ),
            ],
          ),
        ],
        drawPile: [],
        discardPile: [
          UnoCard(id: 't', color: CardColor.green, type: CardType.skip),
        ],
        activeColor: CardColor.green,
        currentIndex: 0,
        direction: 1,
      );
      final restored = GameState.fromJson(s.toJson());
      expect(restored.mode, GameMode.family);
      expect(restored.topCard.type, CardType.skip);
      expect(restored.players.single.hand.single.number, 4);
    });
  });

  group('CodeGen', () {
    test('friend codes match the expected pattern', () {
      for (var i = 0; i < 50; i++) {
        expect(
          CodeGen.friendCodePattern.hasMatch(CodeGen.friendCode()),
          isTrue,
        );
      }
    });

    test('room codes are 6 safe characters', () {
      for (var i = 0; i < 50; i++) {
        final code = CodeGen.roomCode();
        expect(CodeGen.roomCodePattern.hasMatch(code), isTrue);
        expect(code.contains('0'), isFalse);
        expect(code.contains('O'), isFalse);
      }
    });
  });

  group('RankTier', () {
    test('maps points to tiers', () {
      expect(RankTier.fromPoints(0), RankTier.bronze);
      expect(RankTier.fromPoints(150), RankTier.silver);
      expect(RankTier.fromPoints(1000), RankTier.diamond);
    });

    test('progress is clamped between 0 and 1', () {
      expect(RankTier.progress(0), inInclusiveRange(0, 1));
      expect(RankTier.progress(950), 1);
    });
  });
}
