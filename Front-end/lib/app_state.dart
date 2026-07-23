import 'package:flutter/material.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);
final ValueNotifier<bool> showFriendsNotifier = ValueNotifier(false);
final ValueNotifier<bool> showGroupsNotifier = ValueNotifier(true);
final ValueNotifier<bool> isSuperuserNotifier = ValueNotifier(false);

// Centralized Avatar State
final ValueNotifier<int> avatarNotifier = ValueNotifier(0);

final List<Map<String, dynamic>> animeCharacters = [
  {'name': 'Naruto', 'emoji': '🍥', 'color': const Color(0xFFFF8C00)},
  {'name': 'Goku', 'emoji': '🐉', 'color': const Color(0xFF3B82F6)},
  {'name': 'Luffy', 'emoji': '🏴‍☠️', 'color': const Color(0xFFEF4444)},
  {'name': 'Gojo', 'emoji': '👁️‍🗨️', 'color': const Color(0xFF6366F1)},
  {'name': 'Eren', 'emoji': '🪽', 'color': const Color(0xFF10B981)},
  {'name': 'Pikachu', 'emoji': '💥', 'color': const Color(0xFFEAB308)},
  {'name': 'Tanjiro', 'emoji': '🌊', 'color': const Color(0xFF06B6D4)},
  {'name': 'Spike', 'emoji': '🚀', 'color': const Color(0xFF8B5CF6)},
  {'name': 'Sailor Moon', 'emoji': '🌙', 'color': const Color(0xFFEC4899)},
  {'name': 'Deku', 'emoji': '💚', 'color': const Color(0xFF22C55E)},
  {'name': 'Levi', 'emoji': '⚔️', 'color': const Color(0xFF64748B)},
  {'name': 'Itachi', 'emoji': '🐦‍⬛', 'color': const Color(0xFFDC2626)},
  {'name': 'Dante', 'emoji': '🎸', 'color': const Color(0xFFDC2626)},
  {'name': 'Vergil', 'emoji': '🗡️', 'color': const Color(0xFF4F46E5)},
  {'name': 'Zoro', 'emoji': '🍾', 'color': const Color(0xFF16A34A)},
  {'name': 'Saitama', 'emoji': '👊🏻', 'color': const Color(0xFFEAB308)},
  {'name': 'Kakashi', 'emoji': '🍬', 'color': const Color(0xFF94A3B8)},
  {'name': 'Light', 'emoji': '🍎', 'color': const Color(0xFF7C3AED)},
  {'name': 'Mikasa', 'emoji': '🧣‍', 'color': const Color(0xFFEF4444)},
  {'name': 'Killua', 'emoji': '⚡️', 'color': const Color(0xFF3B82F6)},
  {'name': 'Vegeta', 'emoji': '💪', 'color': const Color(0xFF3B82F6)},
  {'name': 'Lelouch', 'emoji': '♟️', 'color': const Color(0xFF7C3AED)},
  {'name': 'Edward', 'emoji': '⚙️', 'color': const Color(0xFFF59E0B)},
  {'name': 'Nezuko', 'emoji': '🌸', 'color': const Color(0xFFEC4899)},
];