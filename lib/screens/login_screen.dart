import 'package:flutter/material.dart';
import 'package:my_hesab_ketab/ui_widgets/login_screen/buttons.dart';
import 'package:my_hesab_ketab/ui_widgets/login_screen/textfields.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  static const String id = 'login_screen';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool loginLoading = false;
  bool registerLoading = false;
  String? _username;
  String? _password;

  @override
  Widget build(BuildContext context) {
    return LoginScaffold(
      children: <Widget>[
        LoginTextFields(
          onUsernameSubmitted: (value) => _username = value,
          onPasswordSubmitted: (value) => _password = value,
        ),
        LoginButtons(
          loginLoading: loginLoading,
          registerLoading: registerLoading,
          onLogin: () {},
          onRegister: () {},
        ),
      ],
    );
  }
}
