import 'package:flutter/material.dart';

import '../../constants.dart';

class AddSmartCalculate extends StatelessWidget {
  const AddSmartCalculate({Key? key, required this.smartCal, required this.onChanged}) : super(key: key);
  final bool smartCal;
  final void Function(bool?) onChanged;

  @override
  Widget build(BuildContext context) {
    final dark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: CheckboxListTile(
        value: smartCal,
        contentPadding: EdgeInsets.zero,
        onChanged: onChanged,
        activeColor: kDarkModeBrown,
        checkColor: dark ? kBlack : kWhite,
        title: const Text(
          'Smart Calculate',
          style: TextStyle(color: kLighterGrey),
        ),
        subtitle: Text(
          'smart calculate divides total price by number of members and adds the result to each member',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 8,
          ),
        ),
      ),
    );
  }
}
