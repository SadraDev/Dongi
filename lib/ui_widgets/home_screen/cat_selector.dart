import 'package:flutter/material.dart';
import '../../constants.dart';

class HomeCatSelector extends StatelessWidget {
  const HomeCatSelector({Key? key, required this.dark, required this.children}) : super(key: key);
  final bool dark;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: children,
        ),
      ),
    );
  }
}

class HomeCatSelectorBubble extends StatelessWidget {
  const HomeCatSelectorBubble(
      {Key? key,
      this.dark,
      required this.catName,
      required this.priceColor,
      required this.price,
      required this.selected})
      : super(key: key);
  final bool? dark;
  final bool? selected;
  final String? catName;
  final String? price;
  final Color? priceColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: dark!
          ? selected!
              ? kLighterGrey
              : kGrey
          : selected!
              ? kGrey
              : kBlack,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            Text(
              catName!,
              style: const TextStyle(
                color: kWhite,
              ),
            ),
            Text(
              price!,
              style: TextStyle(
                color: priceColor!,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
