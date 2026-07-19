import '../../../core/constants/strings.dart';
import '../domain/game_state.dart';

/// Maps the last game event to a short, child-friendly announcement.
String? describeEvent(GameState state) {
  final event = state.event;
  if (event == null) return null;
  final actor = state.playerById(event.actorId)?.name ?? '';
  final target = event.targetId == null
      ? ''
      : state.playerById(event.targetId!)?.name ?? '';
  switch (event.type) {
    case GameEventType.saidUno:
      return S.saidUno(actor);
    case GameEventType.unoPenalty:
      return S.unoPenalty(actor);
    case GameEventType.skip:
      return S.playedSkip(target);
    case GameEventType.reverse:
      return S.reversedDirection;
    case GameEventType.drewTwo:
      return S.drewTwo(target);
    case GameEventType.drewFour:
      return S.drewFour(target);
    case GameEventType.timeoutDraw:
      return S.timeoutDraw(actor);
    case GameEventType.passed:
      return S.turnOf(actor);
    case GameEventType.extraTurn:
      return S.extraTurn(actor);
    case GameEventType.gift:
      return S.giftedCard(actor, target);
    case GameEventType.shuffleHands:
      return S.shuffledHands;
    case GameEventType.rainbow:
      return S.rainbowActive;
    case GameEventType.played:
    case GameEventType.drewCard:
    case GameEventType.win:
      return null;
  }
}
