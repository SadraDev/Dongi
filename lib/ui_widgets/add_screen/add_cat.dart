import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_hesab_ketab/constants.dart';

class AddAddCategoryScreen extends StatelessWidget {
  const AddAddCategoryScreen({Key? key, required this.friendSelectorChildren, required this.onGroupNameChanged})
      : super(key: key);
  final List<Widget> friendSelectorChildren;
  final void Function(String) onGroupNameChanged;

  @override
  Widget build(BuildContext context) {
    final dark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20).copyWith(bottom: 10),
      color: kWhite,
      child: InkWell(
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('add new group'),
        ),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) {
              return Scaffold(
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
                        onChanged: onGroupNameChanged,
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
                    Wrap(children: friendSelectorChildren)
                  ],
                ),
              );
            },
          ));
        },
      ),
    );
  }
}

class AddFriendBubble extends StatelessWidget {
  const AddFriendBubble({Key? key, required this.onTap, required this.cardSelected, required this.friendName})
      : super(key: key);
  final void Function()? onTap;
  final String friendName;
  final bool cardSelected;

  @override
  Widget build(BuildContext context) {
    final dark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Stack(
      children: [
        Card(
          clipBehavior: Clip.antiAliasWithSaveLayer,
          color: dark
              ? cardSelected
                  ? kDarkModeBrown
                  : kWhite
              : !cardSelected
                  ? kBlack
                  : kLightModeBrown,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                friendName,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  color: dark ? kBlack : kWhite,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
