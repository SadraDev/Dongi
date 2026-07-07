import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const FlutterSecureStorage _secureStorage =
  FlutterSecureStorage();

  static const _themeModeKey = 'theme_mode';
  static const _showFriendsKey = 'show_friends';
  static const _showGroupsKey = 'show_groups';

  // Cross-platform storage helpers

  static Future<void> _write(String key, String value) async {
    // await _secureStorage.write(key: key, value: value);
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } else {
      await _secureStorage.write(key: key, value: value);
    }
  }

  static Future<String?> _read(String key) async {
    // return await _secureStorage.read(key: key);
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } else {
      return await _secureStorage.read(key: key);
    }
  }

  // Theme

  static Future<void> saveThemeMode(ThemeMode mode) async {
    await _write(_themeModeKey, mode.name);
  }

  static Future<ThemeMode> loadThemeMode() async {
    final value = await _read(_themeModeKey);

    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  // Friends

  static Future<void> saveShowFriends(bool value) async {
    await _write(_showFriendsKey, value.toString());
  }

  static Future<bool> loadShowFriends() async {
    return (await _read(_showFriendsKey)) == 'false'
        ? false
        : true;
  }

  // Groups

  static Future<void> saveShowGroups(bool value) async {
    await _write(_showGroupsKey, value.toString());
  }

  static Future<bool> loadShowGroups() async {
    return (await _read(_showGroupsKey)) == 'false'
        ? false
        : true;
  }

  static Future<void> loadSettings({
    required ValueNotifier<ThemeMode> themeNotifier,
    required ValueNotifier<bool> friendsNotifier,
    required ValueNotifier<bool> groupsNotifier,
  }) async {
    themeNotifier.value = await loadThemeMode();
    friendsNotifier.value = await loadShowFriends();
    groupsNotifier.value = await loadShowGroups();
  }
}