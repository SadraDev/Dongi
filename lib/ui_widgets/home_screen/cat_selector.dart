import 'package:flutter/material.dart';
import '../../constants.dart';

class HomeCatSelector extends StatelessWidget {
  const HomeCatSelector({Key? key, required this.children}) : super(key: key);
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
  const HomeCatSelectorBubble({Key? key, required this.catName, required this.selected, required this.onTap})
      : super(key: key);
  final bool? selected;
  final String? catName;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    final dark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: dark
            ? !selected!
                ? kLighterGrey
                : kGrey
            : selected!
                ? kGrey
                : kBlack,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            catName!,
            style: const TextStyle(
              color: kWhite,
            ),
          ),
        ),
      ),
    );
  }
}
