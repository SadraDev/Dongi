// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:my_hesab_ketab/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  static const String id = 'profile_screen';
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final dark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return ListView(
      padding: EdgeInsets.only(bottom: 100),
      children: <Widget>[
        Padding(
          padding: EdgeInsets.symmetric(vertical: 100.0, horizontal: MediaQuery.of(context).size.width / 3)
              .copyWith(bottom: 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/profile.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12.0, bottom: 35),
          child: Text(
            'SadraDev',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: dark ? kWhite : kBlack,
              fontSize: 30,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0),
          child: Card(
            color: !dark ? kLighterGrey : kGrey, //TODO
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(12.0),
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
                        '220,000',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: kRed, fontSize: 30),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Text(
                        '440,000',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: kGreen, fontSize: 30),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Pending Balance',
                    style: TextStyle(color: kWhite, fontSize: 24),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    '220,000',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: kRed, fontSize: 30),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: MediaQuery.of(context).size.width - 24,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 24),
            child: Text(
              'Friends',
              style: TextStyle(
                color: dark ? kWhite : kBlack,
                fontSize: 24,
              ),
            ),
          ),
        ),
        Row(
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
                      'assets/images/profile.jpg',
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
                      'Mohamad',
                      style: TextStyle(
                        fontSize: 18,
                        color: dark ? kWhite : kBlack,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'added at 2022 06 16',
                        style: TextStyle(
                          fontSize: 12,
                          color: kLighterGrey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0).copyWith(top: 5.0),
              child: Text(
                '60000',
                style: TextStyle(
                  fontSize: 18,
                  color: kRed,
                ),
              ),
            )
          ],
        ),
        Row(
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
                      'assets/images/profile.jpg',
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
                      'AmirMmd',
                      style: TextStyle(
                        fontSize: 18,
                        color: dark ? kWhite : kBlack,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'added at 2022 06 16',
                        style: TextStyle(
                          fontSize: 12,
                          color: kLighterGrey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0).copyWith(top: 5.0),
              child: Text(
                '70000',
                style: TextStyle(
                  fontSize: 18,
                  color: kRed,
                ),
              ),
            )
          ],
        ),
        Row(
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
                      'assets/images/profile.jpg',
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
                      'AmirHossein',
                      style: TextStyle(
                        fontSize: 18,
                        color: dark ? kWhite : kBlack,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        'added at 2022 06 16',
                        style: TextStyle(
                          fontSize: 12,
                          color: kLighterGrey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0).copyWith(top: 5.0),
              child: Text(
                '90000',
                style: TextStyle(
                  fontSize: 18,
                  color: kRed,
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}
