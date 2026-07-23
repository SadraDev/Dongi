import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../app_state.dart';
import '../services/auth_service.dart';

class GlobalAvatar extends StatefulWidget {
  const GlobalAvatar({super.key});

  @override
  State<GlobalAvatar> createState() => _GlobalAvatarState();
}

class _GlobalAvatarState extends State<GlobalAvatar> with SingleTickerProviderStateMixin {
  late AnimationController _avatarController;

  @override
  void initState() {
    super.initState();
    _avatarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _avatarController.dispose();
    super.dispose();
  }

  void _showCharacterPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? const Color(0xFF0D1321).withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.95);
    final subtle = isDark ? const Color(0xFF151C2C).withValues(alpha: 0.8) : const Color(0xFFE2E8F0).withValues(alpha: 0.6);
    final text = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF020617);
    final subText = isDark ? const Color(0xFF64748B) : const Color(0xFF475569);
    final border = isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useSafeArea: false,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          final bottomInset = MediaQuery.of(context).padding.bottom;

          return Container(
            decoration: BoxDecoration(
              color: card,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.08),
                  blurRadius: 30,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'Choose Your Avatar',
                          style: GoogleFonts.sora(fontSize: 18, fontWeight: FontWeight.w700, color: text),
                        ),
                      ),
                      Divider(color: border, height: 1),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final char = animeCharacters[index];
                      final charColor = char['color'] as Color;

                      return ValueListenableBuilder<bool>(
                        valueListenable: isSuperuserNotifier,
                        builder: (context, isSuperuser, _) {
                          return ValueListenableBuilder<int>(
                            valueListenable: avatarNotifier,
                            builder: (context, currentIndex, _) {
                              final isSelected = index == currentIndex;
                              final displayEmoji = isSuperuser ? '👑' : char['emoji'] as String;

                              return InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  HapticFeedback.lightImpact();
                                  avatarNotifier.value = index;
                                  AuthService.updateAvatarIndex(index);
                                  Navigator.pop(context);
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: isSelected ? charColor.withValues(alpha: isDark ? 0.15 : 0.12) : subtle,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: isSelected ? charColor : border,
                                      width: isSelected ? 2.5 : 1,
                                    ),
                                    boxShadow: isSelected
                                        ? [BoxShadow(color: charColor.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))]
                                        : null,
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(displayEmoji, style: const TextStyle(fontSize: 32)),
                                      const SizedBox(height: 4),
                                      Text(
                                        char['name'] as String,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.outfit(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected ? charColor : subText,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    }, childCount: animeCharacters.length),
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: bottomInset + 20)),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? const Color(0xFF0D1321).withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.95);
    final border = isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1);

    return ValueListenableBuilder<bool>(
      valueListenable: isSuperuserNotifier,
      builder: (context, isSuperuser, _) {
        return ValueListenableBuilder<int>(
          valueListenable: avatarNotifier,
          builder: (context, index, _) {
            final safeIndex = (index >= 0 && index < animeCharacters.length) ? index : 0;
            final char = animeCharacters[safeIndex];
            final charColor = char['color'] as Color;
            final emoji = isSuperuser ? '👑' : char['emoji'] as String;

            return AnimatedBuilder(
              animation: _avatarController,
              builder: (context, child) {
                final scale = 1.0 + (_avatarController.value * 0.08);
                final rotation = math.sin(_avatarController.value * 2 * math.pi) * 0.05;
                return Transform.scale(
                  scale: scale,
                  child: Transform.rotate(angle: rotation, child: child),
                );
              },
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  _showCharacterPicker();
                },
                child: Container(
                  width: 48,
                  height: 48,
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [charColor, charColor.withValues(alpha: 0.5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(color: charColor.withValues(alpha: 0.5), blurRadius: 12, spreadRadius: 1),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: card,
                      border: Border.all(color: border, width: 1),
                    ),
                    alignment: Alignment.center,
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}