import 'package:flutter/material.dart';
import 'package:my_hesab_ketab/screens/utilities/shared.dart';

import '../../constants.dart';

class HomePurchaseBubble extends StatelessWidget {
  const HomePurchaseBubble(
      {Key? key,
      required this.onTapForCollapse,
      required this.motherBuyer,
      required this.purchaseDescription,
      required this.purchasePrice,
      required this.visible,
      required this.children,
      required this.isMe})
      : super(key: key);
  final bool visible;
  final bool isMe;
  final void Function() onTapForCollapse;
  final List<Widget> children;
  final String motherBuyer;
  final String purchaseDescription;
  final String purchasePrice;

  @override
  Widget build(BuildContext context) {
    final dark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        color: dark ? kGrey : kBlack,
        child: Column(
          children: <Widget>[
            GestureDetector(
              onTap: onTapForCollapse,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0).copyWith(bottom: 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          motherBuyer,
                          style: const TextStyle(
                            fontSize: 20,
                            color: kDarkModeBrown,
                          ),
                        ),
                        Text(
                          purchaseDescription,
                          style: const TextStyle(
                            fontSize: 12,
                            color: kLighterGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    child: Text(
                      purchasePrice,
                      style: TextStyle(
                        fontSize: 20,
                        color: isMe ? kRed : kDarkModeBrown,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: kWhite),
            Visibility(
              visible: visible,
              child: Column(
                children: children,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class HomePurchaseBubbleIndividualDetails extends StatelessWidget {
  const HomePurchaseBubbleIndividualDetails(
      {Key? key,
      required this.userProfile,
      required this.username,
      required this.paymentStatus,
      required this.individualPayment,
      required this.onPaymentComplete,
      required this.isMe})
      : super(key: key);
  final String userProfile;
  final String username;
  final bool paymentStatus;
  final bool isMe;
  final String individualPayment;
  final void Function() onPaymentComplete;

  @override
  Widget build(BuildContext context) {
    final dark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24).copyWith(top: 5.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/$userProfile',
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 18,
                    color: kDarkModeBrown,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    paymentStatus ? 'confirmed' : 'pending',
                    style: const TextStyle(
                      fontSize: 12,
                      color: kLighterGrey,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Visibility(
              visible: isMe,
              child: Visibility(
                visible: !paymentStatus,
                child: Card(
                  elevation: 0,
                  shape: const CircleBorder(),
                  color: dark ? kGrey : kBlack,
                  child: InkWell(
                    onTap: onPaymentComplete,
                    child: dark
                        ? const Icon(Icons.check, color: Colors.black)
                        : const Icon(Icons.check, color: Colors.white),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12.0, 5.0, 24.0, 12.0),
              child: Text(
                individualPayment,
                style: TextStyle(
                  fontSize: 18,
                  color: isMe
                      ? paymentStatus
                          ? kGreen
                          : kYellow
                      : username == Shared.getUserName()
                          ? paymentStatus
                              ? kRed
                              : kYellow
                          : paymentStatus
                              ? kDarkModeBrown
                              : kYellow,
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}
