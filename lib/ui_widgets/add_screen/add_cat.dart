import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:my_hesab_ketab/constants.dart';

class AddAddCategoryScreen extends StatefulWidget {
  const AddAddCategoryScreen({Key? key, required this.children, this.onFABPressed, this.onGroupNameChanged})
      : super(key: key);
  final List<AddFriendBubble> children;
  final void Function()? onFABPressed;
  final void Function(String)? onGroupNameChanged;

  @override
  State<AddAddCategoryScreen> createState() => _AddAddCategoryScreenState();
}

class _AddAddCategoryScreenState extends State<AddAddCategoryScreen> {
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
                floatingActionButton: FloatingActionButton(
                  onPressed: widget.onFABPressed!,
                  backgroundColor: kDarkModeBrown,
                  child: const Icon(Icons.add),
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
                        onChanged: widget.onGroupNameChanged,
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
                    Wrap(
                      children: widget.children,
                    ),
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
  AddFriendBubble(
      {Key? key, required this.onSelected, required this.selected, required this.friendName, required this.friendPP})
      : super(key: key);
  final void Function(bool)? onSelected;
  final String friendName;
  final String friendPP;
  bool selected;

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

    // return Stack(
    //   children: [
    //     Card(
    //       clipBehavior: Clip.antiAliasWithSaveLayer,
    //       color: dark
    //           ? cardSelected
    //               ? kDarkModeBrown
    //               : kWhite
    //           : !cardSelected
    //               ? kBlack
    //               : kLightModeBrown,
    //       child: InkWell(
    //         onTap: onTap,
    //         child: Padding(
    //           padding: const EdgeInsets.all(8.0),
    //           child: Text(
    //             friendName,
    //             textAlign: TextAlign.center,
    //             style: TextStyle(
    //               fontSize: 20,
    //               color: dark ? kBlack : kWhite,
    //             ),
    //           ),
    //         ),
    //       ),
    //     ),
    //   ],
    // );
  }
}
