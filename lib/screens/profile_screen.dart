import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_hesab_ketab/ui_widgets/profile_screen/Friends.dart';
import 'package:my_hesab_ketab/ui_widgets/profile_screen/add_friend.dart';
import 'package:my_hesab_ketab/ui_widgets/profile_screen/balance_info.dart';
import 'package:my_hesab_ketab/ui_widgets/profile_screen/profile_info.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  static const String id = 'profile_screen';
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: <Widget>[
        const ProfileImage(profileImg: 'profile.jpg'),
        const ProfileUsername(username: 'SadraDev'),
        const ProfileBalanceInformation(
          payedAmount: '410,000',
          earnedAmount: '665,000',
          pendingBalance: '255,000',
          pendingBalanceValue: false,
        ),
        ProfileFriendsText(
          onAddFriendBuilder: (context) => const ProfileAddFriendScreen(),
        ),
        const ProfileFriendBubble(
          friendProfileImg: 'profile.jpg',
          friendUsername: 'Mohamad',
          addedDate: '2022 06 16',
          amount: '60000',
          amountValue: false,
        ),
        const ProfileFriendBubble(
          friendProfileImg: 'profile.jpg',
          friendUsername: 'Amir',
          addedDate: '2022 06 16',
          amount: '70000',
          amountValue: false,
        ),
        const ProfileFriendBubble(
          friendProfileImg: 'profile.jpg',
          friendUsername: 'AmirHossein',
          addedDate: '2022 06 16',
          amount: '125000',
          amountValue: false,
        ),
      ],
    );
  }
}
