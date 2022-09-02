import 'package:flutter/material.dart';

import '../../constants.dart';

class HomeCatDetails extends StatelessWidget {
  const HomeCatDetails({
    Key? key,
    required this.dark,
    required this.priceValue,
    required this.price,
    required this.children,
  }) : super(key: key);
  final bool dark;
  final bool priceValue;
  final String price;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Card(
        color: dark ? kGrey : kBlack,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0).copyWith(bottom: 0),
              child: Text(
                price,
                style: TextStyle(
                  fontSize: 46,
                  color: priceValue ? kGreen : kRed,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 24.0, bottom: 24.0),
              child: Text(
                !priceValue ? 'you owe some money :((' : 'you are in the lead baby ;))',
                style: TextStyle(
                  fontSize: 14,
                  color: dark ? kLighterGrey : kGrey,
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  children: children,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class HomeCatFriendDetailsBubble extends StatelessWidget {
  const HomeCatFriendDetailsBubble(
      {Key? key, required this.dark, required this.priceValue, required this.friendPrice, required this.friendUsername})
      : super(key: key);
  final bool dark;
  final bool priceValue;
  final String friendPrice;
  final String friendUsername;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: dark ? kBlack : kWhite,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20).copyWith(top: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Row(
          children: <Widget>[
            Text(
              friendUsername,
              style: TextStyle(fontSize: 18, color: dark ? kWhite : kBlack),
            ),
            const SizedBox(width: 12),
            Text(
              friendPrice,
              style: TextStyle(color: priceValue ? kGreen : kRed, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
