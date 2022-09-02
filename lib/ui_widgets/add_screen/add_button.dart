import 'package:flutter/material.dart';

import '../../constants.dart';

class AddAddButton extends StatelessWidget {
  const AddAddButton({Key? key, required this.onPressed}) : super(key: key);
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(primary: kDarkModeBrown),
        child: const Text('add'),
      ),
    );
  }
}
