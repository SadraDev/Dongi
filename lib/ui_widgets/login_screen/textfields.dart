import 'package:flutter/material.dart';

class LoginScaffold extends StatelessWidget {
  const LoginScaffold({Key? key, required this.children}) : super(key: key);
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final dark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: !dark ? const Color(0xfff2f2f2) : const Color(0xff08090A),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 50.0).copyWith(top: 75),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: children,
          ),
        ),
      ),
    );
  }
}

class LoginTextFields extends StatefulWidget {
  const LoginTextFields({Key? key, required this.onUsernameChanged, required this.onPasswordChanged}) : super(key: key);
  final void Function(String)? onUsernameChanged;
  final void Function(String)? onPasswordChanged;

  @override
  State<LoginTextFields> createState() => _LoginTextFieldsState();
}

class _LoginTextFieldsState extends State<LoginTextFields> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    final dark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Column(
      children: <Widget>[
        Text(
          'Let\'s go dutch!',
          style: TextStyle(
            color: dark ? const Color(0xfff2f2f2) : const Color(0xff08090A),
            fontSize: 28,
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 16.0, bottom: 75),
          child: Text(
            'Please sign in to your account',
            style: TextStyle(
              color: Color(0xff585859),
            ),
          ),
        ),
        TextField(
          cursorColor: dark ? const Color(0xffb5b072) : const Color(0xff514E1F),
          style: TextStyle(
            color: dark ? const Color(0xffb5b072) : const Color(0xff514E1F),
            fontSize: 18,
          ),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            hintText: 'username',
            filled: true,
            fillColor: dark ? const Color(0xff2d2e2e) : Colors.grey[300],
            hintStyle: const TextStyle(color: Color(0xff585859)),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent, width: 2),
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent, width: 2),
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
            ),
          ),
          onChanged: widget.onUsernameChanged,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: TextField(
            cursorColor: dark ? const Color(0xffb5b072) : const Color(0xff514E1F),
            obscureText: obscure,
            obscuringCharacter: '*',
            style: TextStyle(
              color: dark ? const Color(0xffb5b072) : const Color(0xff514E1F),
              fontSize: 18,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              hintText: 'password',
              filled: true,
              fillColor: dark ? const Color(0xff2d2e2e) : Colors.grey[300],
              hintStyle: const TextStyle(color: Color(0xff585859)),
              suffixIcon: obscure
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          obscure = !obscure;
                        });
                      },
                      child: Icon(
                        Icons.visibility,
                        color: dark ? const Color(0xffb5b072) : const Color(0xff514E1F),
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        setState(() {
                          obscure = !obscure;
                        });
                      },
                      child: Icon(
                        Icons.visibility_off,
                        color: dark ? const Color(0xffb5b072) : const Color(0xff514E1F),
                      ),
                    ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent, width: 2),
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent, width: 2),
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
              ),
            ),
            onChanged: widget.onPasswordChanged,
          ),
        ),
      ],
    );
  }
}
