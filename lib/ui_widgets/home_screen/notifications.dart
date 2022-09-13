import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_hesab_ketab/constants.dart';
import 'package:my_hesab_ketab/screens/utilities/api.dart';
import 'package:my_hesab_ketab/screens/utilities/shared.dart';
import 'package:my_hesab_ketab/ui_widgets/home_screen/notification_bubble.dart';

class HomeNotificationsScreen extends StatefulWidget {
  const HomeNotificationsScreen({Key? key}) : super(key: key);

  @override
  State<HomeNotificationsScreen> createState() => _HomeNotificationsScreenState();
}

class _HomeNotificationsScreenState extends State<HomeNotificationsScreen> {
  List<Widget>? notifications;
  bool loading = false;

  Future<void> getNotifications() async {
    notifications = [];

    List<dynamic> friendRequests = [];
    List<dynamic> onHandFriendRequests = await Api.getFriendRequests(Shared.getUserId().toString());
    for (var friendRequest in onHandFriendRequests) {
      if (friendRequest['status'] == 'unapproved') friendRequests.add(friendRequest);
    }
    for (var friendRequest in friendRequests) {
      int counter = 0;
      List<dynamic> friendsList;
      String targetId = friendRequest['requester_id'].toString();
      String targetUsername = friendRequest['requester_username'];
      String targetPP = friendRequest['requester_profile_image'];

      HomeNotificationBubble newBubble = HomeNotificationBubble(
        requesterProfileImg: targetPP,
        requesterUsername: targetUsername,
        requestedCatName: 'dog',
        catRequest: false,
        onAccept: () async {
          setState(() => loading = true);
          friendsList = await Api.getFriends(targetId);
          friendsList.add(newFriend(Shared.getUserId()!, Shared.getUserName()!, 'profile.jpg'));
          await Api.setFriends(targetId, friendsList);
          friendsList = [];

          friendsList = await Api.getFriends(Shared.getUserId().toString());
          friendsList.add(newFriend(targetId, targetUsername, targetPP));
          await Api.setFriends(Shared.getUserId()!, friendsList);

          friendRequests[counter] = updateRequest(targetId, targetUsername, targetPP);
          await Api.sendFriendRequest(Shared.getUserId()!, friendRequests);
          setState(() => loading = false);
        },
        onDeny: () {},
      );

      notifications!.add(newBubble);
    }
    setState(() {});
  }

  Map<String, dynamic> newFriend(String friendId, String friendUsername, String friendPP) {
    return {
      'friend_id': friendId,
      'friend_username': friendUsername,
      'friend_profile_image': friendPP,
      'friend_balance': '',
      'friend_balance_type': true
    };
  }

  Map<String, dynamic> updateRequest(String requesterId, String requesterUsername, String requesterImage) {
    return {
      "requester_id": requesterId,
      "requester_username": requesterUsername,
      "requester_profile_image": requesterImage,
      "status": 'approved'
    };
  }

  @override
  void initState() {
    super.initState();
    getNotifications();
  }

  @override
  Widget build(BuildContext context) {
    final dark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      floatingActionButton:
          loading ? CircularProgressIndicator(color: dark ? kDarkModeBrown : kLightModeBrown) : Container(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      resizeToAvoidBottomInset: false,
      backgroundColor: dark ? kBlack : kWhite,
      appBar: AppBar(
        backgroundColor: dark ? kBlack : kWhite,
        title: Text(
          'Notifications',
          style: TextStyle(
            color: !dark ? kBlack : kWhite,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            CupertinoIcons.back,
            color: dark ? kWhite : kBlack,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: kBlack,
        onRefresh: getNotifications,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12).copyWith(bottom: 100),
          children: notifications!,
        ),
      ),
    );
  }
}
