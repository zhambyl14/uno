import 'package:flutter/material.dart';

import '../constants/catalog.dart';

class AvatarCircle extends StatelessWidget {
  const AvatarCircle({
    super.key,
    required this.avatarId,
    this.size = 48,
    this.selected = false,
  });

  final String avatarId;
  final double size;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final avatar = Avatars.byId(avatarId);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: avatar.background,
        shape: BoxShape.circle,
        border: selected
            ? Border.all(color: Theme.of(context).colorScheme.primary, width: 3)
            : null,
      ),
      alignment: Alignment.center,
      child: Text(avatar.emoji, style: TextStyle(fontSize: size * 0.52)),
    );
  }
}
