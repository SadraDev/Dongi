import 'package:flutter/material.dart';
import 'package:my_hesab_ketab/constants.dart';
import 'package:my_hesab_ketab/screens/flow_screen.dart';
import 'package:my_hesab_ketab/screens/login_screen.dart';
import 'package:my_hesab_ketab/screens/utilities/api.dart';
import 'package:my_hesab_ketab/screens/utilities/shared.dart';
import 'package:url_launcher/url_launcher.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  static const String id = 'splash_screen';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? loggedIn;
  final String _username = Shared.getUserName() ?? '';
  final String _password = Shared.getUserPassword() ?? 'password';

  checkLogin() async {
    String? loggedIn = await Api.login(_username, _password);

    if (loggedIn == 'true') this.loggedIn = 'true';
    if (loggedIn == 'username required') this.loggedIn = 'false';
    if (loggedIn == 'NETWORK_ERROR') this.loggedIn = 'network error';
    login();
  }

  login() {
    if (loggedIn! == 'true') Navigator.popAndPushNamed(context, FlowScreen.id);
    if (loggedIn! == 'false') Navigator.popAndPushNamed(context, LoginScreen.id);
    if (loggedIn! == 'network error') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          duration: Duration(seconds: 5),
          backgroundColor: Colors.white,
          content: Text(
            'please check your connection.',
            textAlign: TextAlign.center,
            style: TextStyle(color: kBlack),
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    checkLogin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBlack,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Card(
              color: kBlack,
              elevation: 0,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(25))),
              child: Image.asset('assets/images/logop.png', height: 150, width: 150),
            ),
            GestureDetector(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: const <Widget>[
                    Text(
                      'Developed by :       ',
                      style: TextStyle(
                        color: kGrey,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'SadraDev',
                      style: TextStyle(
                        color: kWhite,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                onTap: () async => await launch(Uri.encodeFull('https://sadra-dev.web.app/')))
          ],
        ),
      ),
    );
  }
}
