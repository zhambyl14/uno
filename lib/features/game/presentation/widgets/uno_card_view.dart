import 'package:flutter/material.dart';

import '../../../../core/constants/game_palette.dart';
import '../../../../core/constants/insets.dart';
import '../../domain/uno_card.dart';

/// Draws a single UNO card with pure widgets (no image assets → tiny size).
/// Styled after the physical card: a colored face, a tilted white badge
/// behind the big central symbol, and small corner indices.
class UnoCardView extends StatelessWidget {
  const UnoCardView({
    super.key,
    required this.card,
    this.width = 64,
    this.playable = true,
    this.faceUp = true,
    this.backColor = GamePalette.wild,
  });

  final UnoCard card;
  final double width;
  final bool playable;
  final bool faceUp;

  /// Card-back color, driven by the player's equipped skin.
  final Color backColor;

  static Color colorOf(CardColor color) => switch (color) {
    CardColor.red => GamePalette.red,
    CardColor.yellow => GamePalette.yellow,
    CardColor.green => GamePalette.green,
    CardColor.blue => GamePalette.blue,
    CardColor.wild => GamePalette.wild,
  };

  static String symbolOf(UnoCard card) => switch (card.type) {
    CardType.number => '${card.number}',
    CardType.skip => '🚫',
    CardType.reverse => '🔄',
    CardType.drawTwo => '+2',
    CardType.wild => '🎨',
    CardType.wildFour => '+4',
    CardType.star => '⭐',
    CardType.gift => '🎁',
    CardType.shuffle => '🔀',
    CardType.rainbow => '🌈',
  };

  @override
  Widget build(BuildContext context) {
    final height = width * 1.45;
    if (!faceUp) {
      return _CardBack(width: width, height: height, color: backColor);
    }

    final base = colorOf(card.color);
    final dark = Color.lerp(base, Colors.black, 0.28)!;
    final symbol = symbolOf(card);
    // Number, +2 and +4 render as tinted text; the rest are emoji glyphs.
    const textTypes = {CardType.number, CardType.drawTwo, CardType.wildFour};
    final isText = textTypes.contains(card.type);
    final cornerColor = Colors.white.withValues(alpha: 0.92);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: playable ? 1 : 0.45,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [base, dark],
          ),
          borderRadius: BorderRadius.circular(Corners.card),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Tilted white badge behind the central symbol.
            Transform.rotate(
              angle: -0.35,
              child: Container(
                width: width * 0.62,
                height: height * 0.92,
                decoration: BoxDecoration(
                  color: GamePalette.cardFace,
                  borderRadius: BorderRadius.circular(width * 0.4),
                ),
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding: const EdgeInsets.all(Insets.xs),
                child: Text(
                  symbol,
                  style: TextStyle(
                    fontSize: width * 0.42,
                    fontWeight: FontWeight.w900,
                    color: isText ? GamePalette.cardInk : null,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 4,
              left: 6,
              child: Text(
                symbol,
                style: TextStyle(
                  fontSize: width * 0.15,
                  fontWeight: FontWeight.w900,
                  color: cornerColor,
                ),
              ),
            ),
            Positioned(
              bottom: 4,
              right: 6,
              child: Transform.rotate(
                angle: 3.14159,
                child: Text(
                  symbol,
                  style: TextStyle(
                    fontSize: width * 0.15,
                    fontWeight: FontWeight.w900,
                    color: cornerColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  const _CardBack({
    required this.width,
    required this.height,
    required this.color,
  });
  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final dark = Color.lerp(color, Colors.black, 0.3)!;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, dark],
        ),
        borderRadius: BorderRadius.circular(Corners.card),
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      alignment: Alignment.center,
      child: Transform.rotate(
        angle: -0.35,
        child: Text(
          'UNO',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: width * 0.26,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

/// A small colored dot showing the active color on the table.
class ActiveColorDot extends StatelessWidget {
  const ActiveColorDot({super.key, required this.color, this.size = 28});
  final CardColor color;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (color == CardColor.wild) {
      return SizedBox(width: size, height: size, child: const _RainbowDot());
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: UnoCardView.colorOf(color),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }
}

class _RainbowDot extends StatelessWidget {
  const _RainbowDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: SweepGradient(
          colors: [
            GamePalette.red,
            GamePalette.yellow,
            GamePalette.green,
            GamePalette.blue,
            GamePalette.red,
          ],
        ),
      ),
    );
  }
}
