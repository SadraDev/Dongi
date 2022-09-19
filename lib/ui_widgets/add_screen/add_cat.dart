import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_hesab_ketab/constants.dart';
import 'package:my_hesab_ketab/screens/utilities/api.dart';
import 'package:my_hesab_ketab/screens/utilities/shared.dart';

class AddAddCategoryScreen extends StatefulWidget {
  const AddAddCategoryScreen({Key? key}) : super(key: key);
  static const String id = 'add_add_category_screen';

  @override
  State<AddAddCategoryScreen> createState() => _AddAddCategoryScreenState();
}

class _AddAddCategoryScreenState extends State<AddAddCategoryScreen> {
  List<dynamic> friends = [];
  List<String> selectedFriends = [];
  List<AddFriendBubble> children = [];
  String catName = '';
  bool loading = false;

  Future<void> getFriends() async {
    friends = await Api.getFriends(Shared.getUserId()!);
    setState(() => loading = false);
  }

  Map<String, dynamic> catReq() {
    return {
      'id': Shared.getUserId(),
      'username': Shared.getUserName(),
      'profile_image': 'profile.jpg',
      'cat_name': catName,
      'accepted': [Shared.getUserName()!],
      'pending': selectedFriends
    };
  }

  @override
  void initState() {
    super.initState();
    getFriends();
  }

  @override
  Widget build(BuildContext context) {
    final dark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (selectedFriends.isNotEmpty && catName != '') {
            setState(() => loading = true);
            for (var friend in selectedFriends) {
              String friendId = await Api.getId(friend);
              List<dynamic> catRequests = await Api.getCatRequests(friendId);
              catRequests.add(catReq());
              await Api.setCatRequest(friendId, catRequests);
            }
            getFriends();
          }
        },
        backgroundColor: kDarkModeBrown,
        child: loading ? const CircularProgressIndicator(color: kBlack) : const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      resizeToAvoidBottomInset: false,
      backgroundColor: dark ? kBlack : kWhite,
      appBar: AppBar(
        backgroundColor: dark ? kBlack : kWhite,
        title: Text(
          'Add New Group',
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
      body: ListView(
        padding: const EdgeInsets.all(12.0),
        children: <Widget>[
          Text(
            'Group Name',
            style: TextStyle(
              color: dark ? kWhite : kBlack,
              fontSize: 35,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 70),
            child: TextField(
              maxLength: 15,
              textAlign: TextAlign.center,
              cursorColor: kDarkModeBrown,
              cursorHeight: 24,
              style: TextStyle(color: dark ? kDarkModeBrown : kLightModeBrown, fontSize: 24),
              decoration: InputDecoration(
                counterStyle: TextStyle(color: dark ? kWhite : kBlack),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: dark ? kWhite : kBlack),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: kDarkModeBrown),
                ),
              ),
              onChanged: (value) => catName = value,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 50),
            child: Text(
              'Select Members',
              style: TextStyle(
                color: dark ? kWhite : kBlack,
                fontSize: 35,
              ),
            ),
          ),
          Divider(thickness: 1, color: dark ? kWhite : kBlack),
          Builder(builder: (context) {
            children = [];
            for (var friend in friends) {
              String friendUsername = friend['friend_username'];
              String friendPP = friend['friend_profile_image'];
              AddFriendBubble friendBubble = AddFriendBubble(
                friendName: friendUsername,
                friendPP: friendPP,
                selected: false,
                onSelected: (value) => setState(() {
                  selectedFriends.add(friend['friend_username']);
                }),
              );
              children.add(friendBubble);
            }

            int counter = 0;
            for (var child in children) {
              for (var selected in selectedFriends) {
                if (child.friendName == selected) {
                  AddFriendBubble friendBubble = AddFriendBubble(
                    friendName: child.friendName,
                    friendPP: child.friendPP,
                    selected: true,
                    onSelected: (value) => setState(() {
                      selectedFriends.remove(child.friendName);
                    }),
                  );
                  children[counter] = friendBubble;
                }
              }
              counter++;
            }
            return Wrap(children: children);
          }),
        ],
      ),
    );
  }
}

class AddFriendBubble extends StatelessWidget {
  const AddFriendBubble(
      {Key? key, required this.onSelected, required this.selected, required this.friendName, required this.friendPP})
      : super(key: key);
  final void Function(bool)? onSelected;
  final String friendName;
  final String friendPP;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final dark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: FilterChip(
        selected: selected,
        labelPadding: const EdgeInsets.all(8.0),
        onSelected: onSelected,
        selectedColor: kDarkModeBrown,
        avatar: CircleAvatar(backgroundImage: AssetImage('assets/images/$friendPP')),
        label: Text(
          friendName,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, color: dark ? kBlack : kWhite),
        ),
      ),
    );
  }
}
