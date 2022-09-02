import 'package:flutter/material.dart';
import '../../constants.dart';

class AddCatSelector extends StatelessWidget {
  const AddCatSelector({Key? key, required this.children}) : super(key: key);
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: children,
      ),
    );
  }
}

class AddCatSelectorBubble extends StatelessWidget {
  const AddCatSelectorBubble({Key? key, required this.catName, required this.onTap, required this.selected})
      : super(key: key);
  final String catName;
  final void Function() onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20).copyWith(bottom: 10),
        color: selected ? kLighterGrey : kWhite,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(catName),
        ),
      ),
    );
  }
}
