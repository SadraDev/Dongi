import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/home/home_screen.dart';
import 'services/auth_service.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

void main() async {
  // 1. Ensure Flutter is initialized before calling async code
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Check if a token exists in secure storage
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
