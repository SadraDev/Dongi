import 'package:flutter/material.dart';
import 'package:my_hesab_ketab/screens/add_screen.dart';
import 'package:my_hesab_ketab/screens/flow_screen.dart';
import 'package:my_hesab_ketab/screens/home_screen.dart';
import 'package:my_hesab_ketab/screens/login_screen.dart';
import 'package:my_hesab_ketab/screens/profile_screen.dart';
import 'package:my_hesab_ketab/screens/splash_screen.dart';
import 'package:my_hesab_ketab/screens/utilities/shared.dart';
import 'package:my_hesab_ketab/ui_widgets/add_screen/add_cat.dart';
import 'package:my_hesab_ketab/ui_widgets/home_screen/notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Shared.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'poppins'),
      initialRoute: SplashScreen.id,
      routes: {
        LoginScreen.id: (context) => const LoginScreen(),
        HomeScreen.id: (context) => const HomeScreen(),
        AddScreen.id: (context) => const AddScreen(),
        ProfileScreen.id: (context) => const ProfileScreen(),
        FlowScreen.id: (context) => const FlowScreen(),
        SplashScreen.id: (context) => const SplashScreen(),
        AddAddCategoryScreen.id: (context) => const AddAddCategoryScreen(),
        HomeNotificationsScreen.id: (context) => const HomeNotificationsScreen(),
      },
    );
  }
}
