import 'package:flutter/material.dart';
import '../../constants.dart';

class AddDescriptionTextField extends StatelessWidget {
  const AddDescriptionTextField({Key? key, required this.onSubmitted}) : super(key: key);
  final void Function(String) onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 18.0),
      child: TextField(
        cursorColor: kDarkModeBrown,
        style: const TextStyle(color: kDarkModeBrown, fontSize: 16),
        decoration: InputDecoration(
          labelText: 'Description',
          labelStyle: const TextStyle(color: kLighterGrey),
          floatingLabelStyle: const TextStyle(color: kDarkModeBrown),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kDarkModeBrown),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kWhite),
          ),
        ),
        onSubmitted: onSubmitted,
        onChanged: onSubmitted,
      ),
    );
  }
}
