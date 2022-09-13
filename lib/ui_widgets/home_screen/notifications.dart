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

  Future<void> getNotifications() async {
    notifications = [];

    List<dynamic> friendRequests = [];
    friendRequests = await Api.getFriendRequests(Shared.getUserId().toString());
    for (var friendRequest in friendRequests) {
      HomeNotificationBubble newBubble = HomeNotificationBubble(
        requesterProfileImg: friendRequest['requester_profile_image'],
        requesterUsername: friendRequest['requester_username'],
        requestedCatName: '',
        catRequest: false,
        onAccept: () {},
        onDeny: () {},
      );
      notifications!.add(newBubble);
    }
    setState(() {});
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
