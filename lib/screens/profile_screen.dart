import 'package:my_hesab_ketab/constants.dart';
import 'package:my_hesab_ketab/ui_widgets/profile_screen/balance_info.dart';
import 'package:my_hesab_ketab/ui_widgets/profile_screen/profile_info.dart';
import 'package:my_hesab_ketab/ui_widgets/profile_screen/add_friend.dart';
import 'package:my_hesab_ketab/ui_widgets/profile_screen/Friends.dart';
import 'package:my_hesab_ketab/screens/utilities/shared.dart';
import 'package:my_hesab_ketab/screens/utilities/api.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  static const String id = 'profile_screen';
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Widget>? children = [];
  List<dynamic> friends = [];

  Future<void> getFriends() async {
    friends = await Api.getFriends(Shared.getUserId()!);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getFriends();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      children = [
        const ProfileImage(profileImg: 'profile.jpg'),
        ProfileUsername(username: Shared.getUserName()!),
        const ProfileBalanceInformation(
          payedAmount: 'U',
          earnedAmount: 'U',
          pendingBalance: 'UwU',
          pendingBalanceValue: true,
        ),
        ProfileFriendsText(
          onAddFriendBuilder: (context) => const ProfileAddFriendScreen(),
        ),
      ];

      for (var friend in friends) {
        ProfileFriendBubble newFriend = ProfileFriendBubble(
          friendUsername: friend['friend_username'],
          friendProfileImg: friend['friend_profile_image'],
          amount: friend['friend_balance'],
          amountValue: friend['friend_balance_type'],
          addedDate: friend['friend_add_date'],
        );
        children!.add(newFriend);
      }

      return RefreshIndicator(
        onRefresh: getFriends,
        color: kBlack,
        child: ListView(padding: const EdgeInsets.only(bottom: 100), children: children!),
      );
    });
  }
}
