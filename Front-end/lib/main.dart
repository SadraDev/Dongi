import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/home/home_screen.dart';
import 'services/auth_service.dart';
import 'services/settings_service.dart';
import './app_state.dart';


void main() async {
  // Ensure Flutter is initialized before calling async code
  WidgetsFlutterBinding.ensureInitialized();

  // Load all saved settings before starting the app
  await SettingsService.loadSettings(
    themeNotifier: themeNotifier,
    friendsNotifier: showFriendsNotifier,
    groupsNotifier: showGroupsNotifier,
  );

  // Check if a token exists in secure storage
  final bool isLoggedIn = await AuthService.isLoggedIn();

  runApp(DongiCloneApp(isLoggedIn: isLoggedIn));
}

class DongiCloneApp extends StatelessWidget {
  final bool isLoggedIn;
  const DongiCloneApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Dongi',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          home: isLoggedIn ? const HomeScreen() : const AuthScreen(),
        );
      },
    );
  }
}
