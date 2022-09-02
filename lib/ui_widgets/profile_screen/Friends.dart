import 'package:flutter/material.dart';

import '../../constants.dart';

class ProfileFriendBubble extends StatelessWidget {
  const ProfileFriendBubble(
      {Key? key,
      required this.friendProfileImg,
      required this.friendUsername,
      required this.addedDate,
      required this.amount,
      required this.amountValue})
      : super(key: key);
  final String friendProfileImg;
  final String friendUsername;
  final String addedDate;
  final String amount;
  final bool amountValue;

  @override
  Widget build(BuildContext context) {
    final dark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24).copyWith(top: 5.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/$friendProfileImg',
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  friendUsername,
                  style: TextStyle(
                    fontSize: 18,
                    color: dark ? kWhite : kBlack,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    'added at $addedDate',
                    style: const TextStyle(
                      fontSize: 12,
                      color: kLighterGrey,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0).copyWith(top: 5.0),
          child: Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              color: amountValue ? kGreen : kRed,
            ),
          ),
        )
      ],
    );
  }
}

class ProfileFriendsText extends StatelessWidget {
  const ProfileFriendsText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return SizedBox(
      width: MediaQuery.of(context).size.width - 24,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 24),
        child: Text(
          'Friends',
          style: TextStyle(
            color: dark ? kWhite : kBlack,
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}
