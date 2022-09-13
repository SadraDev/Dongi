import 'package:flutter/material.dart';
import 'package:my_hesab_ketab/screens/flow_screen.dart';
import 'package:my_hesab_ketab/screens/utilities/api.dart';
import 'package:my_hesab_ketab/screens/utilities/shared.dart';
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
  String? _userId;

  login() => Navigator.popAndPushNamed(context, FlowScreen.id);

  @override
  Widget build(BuildContext context) {
    return LoginScaffold(
      children: <Widget>[
        LoginTextFields(
          onUsernameChanged: (value) => _username = value,
          onPasswordChanged: (value) => _password = value,
        ),
        LoginButtons(
          loginLoading: loginLoading,
          registerLoading: registerLoading,
          onLogin: () async {
            setState(() => loginLoading = true);
            String logged = await Api.login(_username!, _password!);
            _userId = await Api.getId(_username!);
            setState(() => loginLoading = false);
            if (logged == 'true') {
              Shared.setUserName(_username!);
              Shared.setUserPassword(_password!);
              Shared.setUserId(_userId!);
              login();
            } else {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  content: Text(
                    logged,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
          },
          onRegister: () async {
            setState(() => registerLoading = true);
            String logged = await Api.register(_username!, _password!);
            _userId = await Api.getId(_username!);
            setState(() => registerLoading = false);
            if (logged == 'true') {
              Shared.setUserName(_username!);
              Shared.setUserPassword(_password!);
              Shared.setUserId(_userId!);
              login();
            } else {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  content: Text(
                    logged,
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
