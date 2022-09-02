import 'package:flutter/material.dart';
import 'package:my_hesab_ketab/screens/add_screen.dart';
import 'package:my_hesab_ketab/screens/flow_screen.dart';
import 'package:my_hesab_ketab/screens/home_screen.dart';
import 'package:my_hesab_ketab/screens/login_screen.dart';
import 'package:my_hesab_ketab/screens/profile_screen.dart';

void main() {
  //WidgetsFlutterBinding.ensureInitialized();
  //await Shared.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'poppins'),
      initialRoute: FlowScreen.id,
      routes: {
        LoginScreen.id: (context) => const LoginScreen(),
        HomeScreen.id: (context) => const HomeScreen(),
        AddScreen.id: (context) => const AddScreen(),
        ProfileScreen.id: (context) => const ProfileScreen(),
        FlowScreen.id: (context) => const FlowScreen(),
      },
    );
  }
}
