import 'package:flutter/material.dart';

class LoginButtons extends StatelessWidget {
  const LoginButtons(
      {Key? key,
      required this.loginLoading,
      required this.registerLoading,
      required this.onLogin,
      required this.onRegister})
      : super(key: key);
  final bool loginLoading;
  final bool registerLoading;
  final void Function()? onLogin;
  final void Function()? onRegister;

  @override
  Widget build(BuildContext context) {
    final dark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Card(
          color: dark ? const Color(0xffb5b072) : const Color(0xff514E1F),
          margin: const EdgeInsets.symmetric(horizontal: 26),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          child: InkWell(
            onTap: onLogin,
            child: Center(
              child: Ink(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: !loginLoading
                    ? const Text(
                        'Login',
                        style: TextStyle(
                          color: Color(0xfff2f2f2),
                          fontSize: 18,
                        ),
                      )
                    : const SizedBox(
                        height: 27,
                        width: 27,
                        child: CircularProgressIndicator(color: Color(0xfff2f2f2)),
                      ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Card(
            color: dark ? const Color(0xffb5b072) : const Color(0xff514E1F),
            margin: const EdgeInsets.symmetric(horizontal: 26),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
            child: InkWell(
              onTap: onRegister,
              child: Center(
                child: Ink(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: !registerLoading
                      ? const Text(
                          'Register',
                          style: TextStyle(
                            color: Color(0xfff2f2f2),
                            fontSize: 18,
                          ),
                        )
                      : const SizedBox(
                          height: 27,
                          width: 27,
                          child: CircularProgressIndicator(color: Color(0xfff2f2f2)),
                        ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
