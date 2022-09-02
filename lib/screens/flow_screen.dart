import 'package:flutter/material.dart';
import 'package:my_hesab_ketab/screens/add_screen.dart';
import 'package:my_hesab_ketab/screens/profile_screen.dart';
import '../constants.dart';
import 'home_screen.dart';

class FlowScreen extends StatefulWidget {
  const FlowScreen({Key? key}) : super(key: key);
  static const String id = 'flow_screen';

  @override
  State<FlowScreen> createState() => _FlowScreenState();
}

class _FlowScreenState extends State<FlowScreen> {
  int index = 0;

  _screens(int index) {
    if (index == 0) {
      return const HomeScreen();
    } else if (index == 1) {
      return const AddScreen();
    } else if (index == 2) {
      return const ProfileScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: dark ? kBlack : kWhite,
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          _screens(index),
          Card(
            margin: const EdgeInsets.all(20).copyWith(top: 0),
            elevation: 5,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              backgroundColor: dark ? kGrey : kBlack,
              selectedIconTheme: const IconThemeData(color: kWhite),
              unselectedIconTheme: const IconThemeData(color: kLighterGrey),
              showSelectedLabels: false,
              showUnselectedLabels: false,
              currentIndex: index,
              onTap: (context) => setState(() => index = context),
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: ImageIcon(AssetImage('assets/images/home.png')),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.add,
                    size: 37,
                  ),
                  label: '',
                ),
                BottomNavigationBarItem(
                  icon: ImageIcon(
                    AssetImage('assets/images/account.png'),
                    size: 30,
                  ),
                  label: '',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
