import 'uno_card.dart';

/// Player intents. The engine validates every action — invalid actions are
/// ignored, which makes the remote (host-authoritative) mode cheat-tolerant.
sealed class GameAction {
  const GameAction(this.playerId);
  final String playerId;

  Map<String, dynamic> toJson();

  static GameAction fromJson(Map<String, dynamic> json) {
    final playerId = json['p'] as String;
    switch (json['k'] as String) {
      case 'play':
        return PlayCardAction(
          playerId,
          cardId: json['card'] as String,
          chosenColor: json['color'] == null
              ? null
              : CardColor.values[json['color'] as int],
        );
      case 'draw':
        return DrawCardAction(playerId);
      case 'uno':
        return SayUnoAction(playerId);
      case 'timeout':
        return TimeoutAction(playerId);
      case 'leave':
        return LeaveAction(playerId);
      default:
        throw FormatException('Unknown action: ${json['k']}');
    }
  }
}

class PlayCardAction extends GameAction {
  const PlayCardAction(
    super.playerId, {
    required this.cardId,
    this.chosenColor,
  });
  final String cardId;
  final CardColor? chosenColor;

  @override
  Map<String, dynamic> toJson() => {
    'k': 'play',
    'p': playerId,
    'card': cardId,
    'color': chosenColor?.index,
  };
}

class DrawCardAction extends GameAction {
  const DrawCardAction(super.playerId);
  @override
  Map<String, dynamic> toJson() => {'k': 'draw', 'p': playerId};
}

class SayUnoAction extends GameAction {
  const SayUnoAction(super.playerId);
  @override
  Map<String, dynamic> toJson() => {'k': 'uno', 'p': playerId};
}

/// Applied by the session timer when the turn clock runs out.
class TimeoutAction extends GameAction {
  const TimeoutAction(super.playerId);
  @override
  Map<String, dynamic> toJson() => {'k': 'timeout', 'p': playerId};
}

/// A player left mid-game: their seat is handed to a bot so the game
/// continues for everyone else.
class LeaveAction extends GameAction {
  const LeaveAction(super.playerId);
  @override
  Map<String, dynamic> toJson() => {'k': 'leave', 'p': playerId};
}
