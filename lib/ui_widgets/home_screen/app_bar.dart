import 'package:flutter/material.dart';
import 'package:my_hesab_ketab/constants.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({
    Key? key,
    required this.profileImg,
    required this.username,
    required this.notification,
    required this.onPressed,
  }) : super(key: key);
  final String profileImg;
  final String username;
  final bool notification;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final dark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/$profileImg',
                height: 60,
                width: 60,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Hello, $username',
                    style: TextStyle(
                      fontSize: 24,
                      color: !dark ? kBlack : kWhite,
                    ),
                  ),
                  const Text(
                    'Welcome back to Dongi',
                    style: TextStyle(
                      fontSize: 12,
                      color: kGrey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Stack(
          alignment: Alignment.topRight,
          children: [
            Visibility(
              visible: notification,
              child: Container(
                margin: const EdgeInsets.only(top: 10, right: 10),
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(25)),
                  color: Colors.red,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.notifications, color: !dark ? kBlack : kWhite),
              onPressed: onPressed,
            )
          ],
        ),
      ],
    );
  }
}
