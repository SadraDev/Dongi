import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_hesab_ketab/constants.dart';
import 'package:my_hesab_ketab/screens/utilities/api.dart';
import 'package:my_hesab_ketab/screens/utilities/shared.dart';

class ProfileAddFriendScreen extends StatefulWidget {
  const ProfileAddFriendScreen({Key? key}) : super(key: key);

  @override
  State<ProfileAddFriendScreen> createState() => _ProfileAddFriendScreenState();
}

class _ProfileAddFriendScreenState extends State<ProfileAddFriendScreen> {
  List<Widget> searchChildren = [];

  Future<void> search(username) async {
    List<dynamic> searchResult = await Api.search(username);
    searchChildren = [];
    for (var result in searchResult) {
      ProfileAddFriendBubble newBubble = ProfileAddFriendBubble(
        username: result['username'],
        profileImg: result['profile_image'],
        onAdd: () async {
          bool? sendIt = true;
          List<dynamic> friendRequests = await Api.getFriendRequests(result['id'].toString());
          for (var friendRequest in friendRequests) {
            if (friendRequest['requester_id'] == Shared.getUserId()) sendIt = false;
          }
          if (sendIt!) {
            friendRequests.add(newRequest(result['profile_image']));
            await Api.sendFriendRequest(result['id'].toString(), friendRequests);
            showDialog(
              context: context,
              builder: (context) => const AlertDialog(content: Text('request sent', textAlign: TextAlign.center)),
            );
          }
          if (!sendIt) {
            showDialog(
              context: context,
              builder: (context) =>
                  const AlertDialog(content: Text('request already sent', textAlign: TextAlign.center)),
            );
          }
        },
      );
      searchChildren.add(newBubble);
    }
    setState(() {});
  }

  Map<String, dynamic> newRequest(String profileImage) {
    return {
      "requester_id": Shared.getUserId(),
      "requester_username": Shared.getUserName(),
      "requester_profile_image": profileImage,
      "status": "unapproved"
    };
  }

  @override
  Widget build(BuildContext context) {
    final dark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: dark ? kBlack : kWhite,
      appBar: AppBar(
        backgroundColor: dark ? kBlack : kWhite,
        title: TextField(
          style: TextStyle(color: dark ? kWhite : kBlack, fontSize: 18),
          cursorColor: kDarkModeBrown,
          decoration: InputDecoration(
            hintText: 'search username',
            hintStyle: const TextStyle(color: kLighterGrey, fontSize: 18),
            enabledBorder: UnderlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: kWhite),
            ),
            focusedBorder: UnderlineInputBorder(
              borderRadius: BorderRadius.circular(0),
              borderSide: const BorderSide(color: kDarkModeBrown),
            ),
          ),
          onChanged: (value) async => await search(value),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            CupertinoIcons.back,
            color: dark ? kWhite : kBlack,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
        children: searchChildren,
      ),
    );
  }
}

class ProfileAddFriendBubble extends StatelessWidget {
  const ProfileAddFriendBubble({Key? key, required this.profileImg, required this.username, required this.onAdd})
      : super(key: key);
  final String? profileImg;
  final String? username;
  final void Function() onAdd;

  @override
  Widget build(BuildContext context) {
    final dark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Card(
      color: dark ? kGrey : kLighterGrey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/$profileImg',
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Text(
                username!,
                style: TextStyle(
                  color: dark ? kWhite : kBlack,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: onAdd,
                  icon: const Icon(FontAwesomeIcons.plus, color: kWhite),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
