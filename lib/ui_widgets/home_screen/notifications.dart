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
  List<Widget>? notifications = [];
  List<dynamic> friendRequests = [];
  List<dynamic> catRequests = [];
  bool loading = false;

  Future<void> getFriendNotifications() async {
    friendRequests = [];
    friendRequests = await Api.getFriendRequests(Shared.getUserId().toString());
    setState(() => loading = false);
  }

  Future<void> getCatNotifications() async {
    catRequests = [];
    catRequests = await Api.getCatRequests(Shared.getUserId().toString());
    setState(() => loading = false);
  }

  Future<void> getNotifications() async {
    getFriendNotifications();
    getCatNotifications();
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

  Map<String, dynamic> newCat(String tblName, String catName, List<dynamic> members) {
    return {'tbl_name': tblName, 'cat_name': catName, 'members': members};
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
          notifications = [];
          for (int i = 0; i < friendRequests.length; i++) {
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
                  if (friend['friend_id'] == requesterId) {
                    ok = false;
                    getFriendNotifications();
                    dialog(false, 'Accepted');
                  }
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
                  getFriendNotifications();
                  dialog(true, 'Accepted');
                }
              },
              onDeny: () async {
                setState(() => loading = true);
                friendRequests.remove(friendRequests[i]);
                await Api.sendFriendRequest(Shared.getUserId()!, friendRequests);
                getFriendNotifications();
              },
            );
            notifications!.add(newBubble);
          }
          for (int i = 0; i < catRequests.length; i++) {
            bool showReq = true;
            String requesterUsername = catRequests[i]['username'];
            String requesterPI = catRequests[i]['profile_image'];
            String requestedCatName = catRequests[i]['cat_name'];

            for (String req in catRequests[i]['accepted']) {
              if (req == Shared.getUserName()!) showReq = false;
            }

            if (showReq) {
              HomeNotificationBubble newBubble = HomeNotificationBubble(
                catRequest: true,
                requesterUsername: requesterUsername,
                requestedCatName: requestedCatName,
                requesterProfileImg: requesterPI,
                onAccept: () async {
                  List<dynamic> pending = [];
                  List<dynamic> accepted = [];
                  List<dynamic> members = [];
                  pending = catRequests[i]['pending'];
                  accepted = catRequests[i]['accepted'];
                  members = pending + accepted;
                  members.remove(catRequests[i]['username']);

                  setState(() => loading = true);
                  pending.remove(Shared.getUserName()!);
                  accepted.add(Shared.getUserName()!);

                  for (var member in members) {
                    String id = await Api.getId(member);
                    List<dynamic> catRequests = [];
                    catRequests = await Api.getCatRequests(id);
                    for (int counter = 0; counter < catRequests.length; counter++) {
                      if (catRequests[counter]['id'] == this.catRequests[i]['id']) {
                        List<dynamic> pending = [];
                        List<dynamic> accepted = [];
                        pending = catRequests[counter]['pending'];
                        accepted = catRequests[counter]['accepted'];

                        pending.remove(Shared.getUserName()!);
                        accepted.add(Shared.getUserName()!);

                        await Api.setCatRequest(id, catRequests);
                      }
                    }
                  }

                  if (pending.isNotEmpty) {
                    getCatNotifications();
                    dialog(true, 'Accepted');
                  }

                  if (pending.isEmpty) {
                    DateTime tblName = DateTime.now();
                    for (var member in accepted) {
                      String id = await Api.getId(member);
                      List<dynamic> cats = await Api.getCat(id);
                      cats.add(newCat(tblName.toString(), catRequests[i]['cat_name'], accepted));
                      await Api.setCat(id, cats, tblName.toString());
                    }

                    for (var member in members) {
                      String id = await Api.getId(member);
                      List<dynamic> catRequests = [];
                      catRequests = await Api.getCatRequests(id);
                      for (int counter = 0; counter < catRequests.length; counter++) {
                        if (catRequests[counter]['id'] == this.catRequests[i]['id']) {
                          catRequests.remove(catRequests[counter]);
                          await Api.setCatRequest(id, catRequests);
                        }
                      }
                    }

                    getCatNotifications();
                    dialog(true, 'Accepted');
                  }
                },
                onDeny: () {},
              );
              notifications!.add(newBubble);
            }
          }

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12).copyWith(bottom: 100),
            children: notifications!,
          );
        }),
      ),
    );
  }
}
