import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/insets.dart';
import '../../../../core/constants/strings.dart';

/// The ONLY way players communicate: a fixed set of safe preset phrases.
/// No free text is possible anywhere (child-safety requirement).
class QuickChatBar extends StatelessWidget {
  const QuickChatBar({super.key, required this.onSend});
  final ValueChanged<String> onSend;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ScrollConfiguration(
        behavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
        ),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: Insets.m),
          itemCount: S.quickChatPhrases.length,
          separatorBuilder: (_, _) => const SizedBox(width: Insets.s),
          itemBuilder: (context, index) {
            final phrase = S.quickChatPhrases[index];
            return ActionChip(
              label: Text(phrase),
              onPressed: () => onSend(phrase),
            );
          },
        ),
      ),
    );
  }
}

/// Transient speech bubble shown when a quick-chat phrase is sent.
class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Insets.m,
        vertical: Insets.s,
      ),
      decoration: BoxDecoration(
        color: scheme.inverseSurface,
        borderRadius: BorderRadius.circular(Corners.l),
      ),
      child: Text(text, style: TextStyle(color: scheme.onInverseSurface)),
    );
  }
}
