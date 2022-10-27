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
  List<dynamic> categories = [];
  List<dynamic> members = [];
  List<dynamic> individualPayment = [];
  String? selected;
  String price = '';
  String description = '';

  Future<void> getCats() async {
    categories = await Api.getCat(Shared.getUserId()!);
    selected = categories[0]['tbl_name'];
    members = categories[0]['members'];
    for (var i in members) {
      individualPayment.add([]);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getCats();
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
            Builder(builder: (context) {
              List<Widget> children = [];

              for (var category in categories) {
                AddCatSelectorBubble cat = AddCatSelectorBubble(
                  catName: category['cat_name'],
                  selected: selected == category['tbl_name'] ? true : false,
                  onTap: () => setState(() {
                    selected = category['tbl_name'];
                    members = category['members'];
                    individualPayment = [];
                    for (var i in members) {
                      individualPayment.add([]);
                    }
                  }),
                );
                children.add(cat);
              }

              children.add(Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20).copyWith(bottom: 10),
                color: kWhite,
                child: InkWell(
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('add new group'),
                  ),
                  onTap: () => Navigator.pushNamed(context, AddAddCategoryScreen.id),
                ),
              ));
              return AddCatSelector(children: children);
            }),
            const Divider(color: kWhite, indent: 12, endIndent: 12),
            AddPriceTextField(
              tripleZero: tripleZero!,
              onTripleZero: () => setState(() => tripleZero = !tripleZero!),
              onSubmitted: (value) {
                tripleZero! ? price = "${value}000" : price = value;
              },
            ),
            AddDescriptionTextField(
              onSubmitted: (value) => description = value,
            ),
            AddSmartCalculate(
              smartCal: smartCal!,
              onChanged: (value) => setState(() => smartCal = !smartCal!),
            ),
            Builder(builder: (context) {
              List<Widget> children = [];
              for (int i = 0; i < members.length; i++) {
                List<dynamic> payment;
                AddIndividualPriceTextField newMember = AddIndividualPriceTextField(
                  username: members[i],
                  tripleZero: tripleZero!,
                  onSubmitted: (value) {
                    tripleZero!
                        ? payment = [members[i], "${value}000", 'pending']
                        : payment = [members[i], value, 'pending'];
                    individualPayment[i] = payment;
                  },
                );
                children.add(newMember);
              }

              return AddDumbCalculate(
                smartCal: smartCal!,
                children: children,
              );
            }),
            AddAddButton(
              onPressed: () async {
                bool go = true;
                if (price == '' || price == '000') {
                  go = false;
                  showDialog(
                    context: context,
                    builder: (context) => const AlertDialog(
                      content: Text('Price field is empty', textAlign: TextAlign.center),
                    ),
                  );
                }

                if (price != '' && smartCal!) {
                  String smartPrice = (int.parse(price) / members.length).round().toString();
                  for (int i = 0; i < members.length; i++) {
                    individualPayment[i] = [members[i], smartPrice, 'pending'];
                  }
                }

                if (price != '' && !smartCal!) {
                  for (List payment in individualPayment) {
                    if (payment.isEmpty) {
                      go = false;
                      showDialog(
                        context: context,
                        builder: (context) => const AlertDialog(
                          content: Text('Price field is empty', textAlign: TextAlign.center),
                        ),
                      );
                    }
                  }
                }

                if (go) {
                  for (var me in individualPayment) {
                    if (me[0] == Shared.getUserName()) me[2] = 'confirmed';
                  }
                  //await Api.setCatTable(selected!, Shared.getUserName()!, description, price, individualPayment);
                  showDialog(
                    context: context,
                    builder: (context) => const AlertDialog(
                      content: Text('Payment Set', textAlign: TextAlign.center),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
