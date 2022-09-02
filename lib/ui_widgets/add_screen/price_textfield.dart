import 'package:flutter/material.dart';

import '../../constants.dart';

class AddPriceTextField extends StatelessWidget {
  const AddPriceTextField({Key? key, required this.tripleZero, required this.onTripleZero, required this.onSubmitted})
      : super(key: key);
  final bool tripleZero;
  final void Function() onTripleZero;
  final void Function(String) onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: TextField(
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        cursorColor: kDarkModeBrown,
        style: const TextStyle(color: kDarkModeBrown, fontSize: 20),
        decoration: InputDecoration(
          labelText: 'Price',
          labelStyle: const TextStyle(color: kLighterGrey),
          floatingLabelStyle: const TextStyle(color: kDarkModeBrown),
          suffix: GestureDetector(
            onTap: onTripleZero,
            child: Text(
              tripleZero ? '000' : 'T',
              style: const TextStyle(color: kDarkModeBrown, fontSize: 20),
            ),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: kDarkModeBrown),
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: kWhite),
          ),
        ),
        onSubmitted: onSubmitted,
        onChanged: onSubmitted,
      ),
    );
  }
}
