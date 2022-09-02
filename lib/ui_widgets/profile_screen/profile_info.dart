import 'package:flutter/material.dart';

import '../../constants.dart';

class ProfileImage extends StatelessWidget {
  const ProfileImage({Key? key, required this.profileImg}) : super(key: key);
  final String profileImg;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(vertical: 100.0, horizontal: MediaQuery.of(context).size.width / 3).copyWith(bottom: 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/images/$profileImg',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class ProfileUsername extends StatelessWidget {
  const ProfileUsername({Key? key, required this.username}) : super(key: key);
  final String username;

  @override
  Widget build(BuildContext context) {
    final dark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 35),
      child: Text(
        username,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: dark ? kWhite : kBlack,
          fontSize: 30,
        ),
      ),
    );
  }
}
