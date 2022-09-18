import 'package:flutter/material.dart';
import 'package:my_hesab_ketab/screens/utilities/api.dart';
import 'package:my_hesab_ketab/screens/utilities/shared.dart';
import 'package:my_hesab_ketab/ui_widgets/add_screen/add_button.dart';
import 'package:my_hesab_ketab/ui_widgets/add_screen/add_cat.dart';
import 'package:my_hesab_ketab/ui_widgets/add_screen/cat_selector.dart';
import 'package:my_hesab_ketab/ui_widgets/add_screen/description_textfield.dart';
import 'package:my_hesab_ketab/ui_widgets/add_screen/dumb_cal.dart';
import 'package:my_hesab_ketab/ui_widgets/add_screen/price_textfield.dart';
import 'package:my_hesab_ketab/ui_widgets/add_screen/smart_cal.dart';
import '../constants.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({Key? key}) : super(key: key);
  static const String id = 'add_screen';

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  bool? tripleZero = true;
  bool? smartCal = true;
  List<AddFriendBubble> friends = [];

  Future<void> getFriends() async {
    List<dynamic> friends = await Api.getFriends(Shared.getUserId()!);
    for (int i = 0; i < friends.length; i++) {
      bool selected = false;
      String friendUsername = friends[i]['friend_username'];
      String friendPP = friends[i]['friend_profile_image'];
      AddFriendBubble friendBubble = AddFriendBubble(
        friendName: friendUsername,
        friendPP: friendPP,
        selected: selected,
        onSelected: (value) {
          if (this.friends[i].selected) {
            this.friends[i].selected = false;
          } else if (this.friends[i].selected == false) {
            this.friends[i].selected = true;
          }
          print(this.friends[i].selected);
        },
      );

      this.friends.add(friendBubble);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getFriends();
  }

  @override
  Widget build(BuildContext context) {
    final dark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 100).copyWith(bottom: 180),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: dark ? kGrey : kBlack,
        child: ListView(
          children: <Widget>[
            AddCatSelector(
              children: <Widget>[
                AddCatSelectorBubble(
                  catName: 'birdan biyanadi',
                  onTap: () {},
                  selected: true,
                ),
                AddAddCategoryScreen(
                  children: friends,
                  onFABPressed: () {
                    print('${friends[0].selected} ${friends[0].friendName}');
                    print('${friends[1].selected} ${friends[1].friendName}');
                  },
                  onGroupNameChanged: (value) {},
                ),
              ],
            ),
            const Divider(color: kWhite, indent: 12, endIndent: 12),
            AddPriceTextField(
              tripleZero: tripleZero!,
              onTripleZero: () => setState(() => tripleZero = !tripleZero!),
              onSubmitted: (value) {},
            ),
            AddDescriptionTextField(
              onSubmitted: (value) {},
            ),
            AddSmartCalculate(
              smartCal: smartCal!,
              onChanged: (value) => setState(() => smartCal = !smartCal!),
            ),
            AddDumbCalculate(
              smartCal: smartCal!,
              children: [
                AddIndividualPriceTextField(
                  username: 'Mohamad',
                  tripleZero: tripleZero!,
                  onSubmitted: (value) {},
                ),
                AddIndividualPriceTextField(
                  username: 'AmirHossein',
                  tripleZero: tripleZero!,
                  onSubmitted: (value) {},
                )
              ],
            ),
            AddAddButton(
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
