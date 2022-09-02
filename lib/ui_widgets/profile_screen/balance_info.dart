import 'package:flutter/material.dart';
import '../../constants.dart';

class ProfileBalanceInformation extends StatelessWidget {
  const ProfileBalanceInformation(
      {Key? key,
      required this.payedAmount,
      required this.earnedAmount,
      required this.pendingBalance,
      required this.pendingBalanceValue})
      : super(key: key);
  final String payedAmount;
  final String earnedAmount;
  final String pendingBalance;
  final bool pendingBalanceValue;

  @override
  Widget build(BuildContext context) {
    final dark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Card(
        color: !dark ? kLighterGrey : kGrey, //TODO
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                'Total Balance History',
                style: TextStyle(color: kWhite, fontSize: 24),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    payedAmount,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: kRed, fontSize: 30),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    earnedAmount,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: kGreen, fontSize: 30),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text(
                'Pending Balance',
                style: TextStyle(color: kWhite, fontSize: 24),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Text(
                pendingBalance,
                textAlign: TextAlign.center,
                style: TextStyle(color: pendingBalanceValue ? kGreen : kRed, fontSize: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
