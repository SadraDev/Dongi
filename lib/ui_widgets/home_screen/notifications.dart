import 'package:my_hesab_ketab/ui_widgets/home_screen/notification_bubble.dart';
import 'package:my_hesab_ketab/screens/utilities/shared.dart';
import 'package:my_hesab_ketab/screens/utilities/api.dart';
import 'package:my_hesab_ketab/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeNotificationsScreen extends StatefulWidget {
  const HomeNotificationsScreen({Key? key}) : super(key: key);
  static const String id = 'home_notifications_screen';

  @override
  State<HomeNotificationsScreen> createState() => _HomeNotificationsScreenState();
}

class _HomeNotificationsScreenState extends State<HomeNotificationsScreen> {
  List<Widget>? children = [];
  List<dynamic> friendRequests = [];
  bool loading = false;

  Future<void> getNotifications() async {
    friendRequests = [];
    friendRequests = await Api.getFriendRequests(Shared.getUserId().toString());
    setState(() => loading = false);
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> dialog(bool accepted, String status) {
    return accepted
        ? ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(status, textAlign: TextAlign.center),
            ),
          )
        : ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Already $status', textAlign: TextAlign.center),
            ),
          );
  }

  Map<String, dynamic> newFriend(String friendId, String friendUsername, String friendPP, String addedDate) {
    return {
      'friend_id': friendId,
      'friend_username': friendUsername,
      'friend_profile_image': friendPP,
      'friend_balance': '',
      'friend_balance_type': true,
      'friend_add_date': addedDate
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerTop,
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
        child: Builder(builder: (context) {
          children = [];
          for (int i = 0; i < friendRequests.length; i++) {
            //for cat, create whole new for() and add new list to end of this list
            List<dynamic> friendsList = [];
            String requesterId = friendRequests[i]['requester_id'].toString();
            String requesterUsername = friendRequests[i]['requester_username'];
            String requesterPI = friendRequests[i]['requester_profile_image'];

            HomeNotificationBubble newBubble = HomeNotificationBubble(
              requesterProfileImg: requesterPI,
              requesterUsername: requesterUsername,
              requestedCatName: 'dog',
              catRequest: false,
              onAccept: () async {
                bool ok = true;
                DateTime now = DateTime.now();
                String formattedDate = DateFormat('yyyy-MM-dd').format(now);

                setState(() => loading = true);
                friendsList = await Api.getFriends(Shared.getUserId()!);
                for (var friend in friendsList) {
                  if (friend['friend_id'] == requesterId) ok = false;
                  getNotifications();
                  dialog(false, 'Accepted');
                }
                if (ok) {
                  friendsList.add(newFriend(requesterId, requesterUsername, requesterPI, formattedDate));
                  await Api.setFriends(Shared.getUserId()!, friendsList);
                  friendsList = [];

                  friendsList = await Api.getFriends(requesterId);
                  friendsList.add(newFriend(Shared.getUserId()!, Shared.getUserName()!, 'profile.jpg', formattedDate));
                  await Api.setFriends(requesterId, friendsList);

                  friendRequests.remove(friendRequests[i]);
                  await Api.sendFriendRequest(Shared.getUserId()!, friendRequests);
                  getNotifications();
                  dialog(true, 'Accepted');
                }
              },
              onDeny: () async {
                setState(() => loading = true);
                friendRequests.remove(friendRequests[i]);
                await Api.sendFriendRequest(Shared.getUserId()!, friendRequests);
                getNotifications();
              },
            );
            children!.add(newBubble);
          }
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12).copyWith(bottom: 100),
            children: children!,
          );
        }),
      ),
    );
  }
}
