import 'package:flutter/material.dart';
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
                Card(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20).copyWith(bottom: 10),
                  color: kWhite,
                  child: InkWell(
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('add new group'),
                    ),
                    onTap: () => Navigator.pushNamed(context, AddAddCategoryScreen.id),
                  ),
                )
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
