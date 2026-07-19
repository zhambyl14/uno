import 'game_state.dart';
import 'uno_card.dart';

/// Shared, official UNO legality checks.
///
/// Keeping this in one place prevents the board, bots and host engine from
/// disagreeing about which cards are playable.
abstract final class UnoRules {
  static bool canPlayCard(GameState state, UnoCard card) {
    // After drawing, UNO only allows the drawn card to be played.
    final drawnCardId = state.drawnCardId;
    if (drawnCardId != null && drawnCardId != card.id) return false;

    if (!card.matches(
      activeColor: state.activeColor,
      top: state.topCard,
      rainbowFree: state.rainbowFree,
    )) {
      return false;
    }

    // Official UNO: Wild Draw Four is legal only when the player has no
    // other card matching the current color. Matching the top symbol/number
    // is still allowed; only the active color matters here.
    if (card.type == CardType.wildFour) {
      final hasMatchingColor = state.currentPlayer.hand.any(
        (candidate) =>
            candidate.id != card.id &&
            !candidate.isWildType &&
            candidate.color == state.activeColor,
      );
      if (hasMatchingColor) return false;
    }

    return true;
  }
}
