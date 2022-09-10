import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_hesab_ketab/constants.dart';

class ProfileAddFriendScreen extends StatefulWidget {
  const ProfileAddFriendScreen({Key? key}) : super(key: key);

  @override
  State<ProfileAddFriendScreen> createState() => _ProfileAddFriendScreenState();
}

class _ProfileAddFriendScreenState extends State<ProfileAddFriendScreen> {
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
          onChanged: (value) {},
          onSubmitted: (value) {},
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
        children: [],
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
