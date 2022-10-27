import 'package:flutter/material.dart';

import '../../constants.dart';

class AddDumbCalculate extends StatelessWidget {
  const AddDumbCalculate({Key? key, required this.smartCal, required this.children}) : super(key: key);
  final bool smartCal;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: !smartCal,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: Column(
          children: children,
        ),
      ),
    );
  }
}

class AddIndividualPriceTextField extends StatelessWidget {
  const AddIndividualPriceTextField(
      {Key? key, required this.tripleZero, required this.onSubmitted, required this.username})
      : super(key: key);
  final bool tripleZero;
  final String username;
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
          labelText: username,
          labelStyle: const TextStyle(color: kLighterGrey),
          floatingLabelStyle: const TextStyle(color: kDarkModeBrown),
          suffix: Text(
            tripleZero ? '000' : 'T',
            style: const TextStyle(color: kDarkModeBrown, fontSize: 20),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: kDarkModeBrown),
          ),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: kWhite),
          ),
        ),
        onChanged: onSubmitted,
      ),
    );
  }
}
