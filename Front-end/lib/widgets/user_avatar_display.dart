import 'package:flutter/material.dart';
import '../app_state.dart';

class UserAvatarDisplay extends StatelessWidget {
  final int avatarIndex;
  final bool isSuperuser;
  final double radius;

  const UserAvatarDisplay({
    super.key,
    required this.avatarIndex,
    this.isSuperuser = false,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context) {
    final safeIndex = (avatarIndex >= 0 && avatarIndex < animeCharacters.length)
        ? avatarIndex
        : 0;
    final char = animeCharacters[safeIndex];
    final charColor = char['color'] as Color;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark
        ? const Color(0xFF0D1321).withValues(alpha: 0.85)
        : Colors.white.withValues(alpha: 0.95);
    final emoji = isSuperuser ? '👑' : char['emoji'] as String;

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [charColor, charColor.withValues(alpha: 0.5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: card,
        child: Text(
          emoji,
          style: TextStyle(fontSize: radius * 1.1),
        ),
      ),
    );
  }
}