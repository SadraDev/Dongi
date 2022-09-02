// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:my_hesab_ketab/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static const String id = 'home_screen';
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool visible = true;

  Future<void> refresh() async {}

  @override
  Widget build(BuildContext context) {
    final dark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return RefreshIndicator(
      color: kBlack,
      onRefresh: refresh,
      child: ListView(
        padding: EdgeInsets.symmetric(vertical: 48, horizontal: 12).copyWith(bottom: 100),
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/images/profile.jpg',
                      height: 60,
                      width: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Hello, Sadra',
                          style: TextStyle(
                            fontSize: 24,
                            color: !dark ? kBlack : kWhite,
                          ),
                        ),
                        Text(
                          'Welcome back to My Hesab Ketab',
                          style: TextStyle(
                            fontSize: 12,
                            color: kGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.notifications,
                  color: !dark ? kBlack : kWhite,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 18, bottom: 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  Card(
                    color: dark ? kLighterGrey : kGrey,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            'gor got dar',
                            style: TextStyle(
                              color: kWhite,
                            ),
                          ),
                          Text(
                            '27500',
                            style: TextStyle(
                              color: kRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    color: dark ? kGrey : kBlack,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            'batar lar',
                            style: TextStyle(
                              color: kWhite,
                            ),
                          ),
                          Text(
                            '12000',
                            style: TextStyle(
                              color: kGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    color: dark ? kGrey : kBlack,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            'birdan biyanadi',
                            style: TextStyle(
                              color: kWhite,
                            ),
                          ),
                          Text(
                            '10000',
                            style: TextStyle(
                              color: kRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    color: dark ? kGrey : kBlack,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            'birajanidi',
                            style: TextStyle(
                              color: kWhite,
                            ),
                          ),
                          Text(
                            '100000',
                            style: TextStyle(
                              color: kGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
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
                      '27500',
                      style: TextStyle(
                        fontSize: 46,
                        color: kRed,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 24.0, bottom: 24.0),
                    child: Text(
                      'you owe some money :((',
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
                        children: <Widget>[
                          Card(
                            color: dark ? kBlack : kWhite,
                            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20).copyWith(top: 0),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    'mmd',
                                    style: TextStyle(fontSize: 18, color: dark ? kWhite : kBlack),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    '10000',
                                    style: TextStyle(color: kRed, fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Card(
                            color: dark ? kBlack : kWhite,
                            margin: EdgeInsets.only(left: 10, bottom: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                              child: Row(
                                children: <Widget>[
                                  Text(
                                    'amirhosen',
                                    style: TextStyle(fontSize: 18, color: dark ? kWhite : kBlack),
                                  ),
                                  SizedBox(width: 12),
                                  Text(
                                    '17500',
                                    style: TextStyle(color: kRed, fontSize: 18),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Card(
              color: dark ? kGrey : kBlack,
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        visible = !visible;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0).copyWith(bottom: 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'sadra',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: kWhite,
                                ),
                              ),
                              Text(
                                'some description',
                                style: TextStyle(
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
                            '90000',
                            style: TextStyle(
                              fontSize: 20,
                              color: kRed,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(color: kWhite),
                  Visibility(
                    visible: visible,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24).copyWith(top: 5.0),
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
                                      'sadra',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: kWhite,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        'confirmed',
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
                            Row(
                              children: <Widget>[
                                Visibility(
                                  visible: false,
                                  child: Card(
                                    elevation: 0,
                                    shape: const CircleBorder(),
                                    color: dark ? kGrey : kBlack,
                                    child: InkWell(
                                      onLongPress: () {},
                                      child: dark
                                          ? const Icon(Icons.check, color: Colors.black)
                                          : const Icon(Icons.check, color: Colors.white),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(12.0, 5.0, 24.0, 12.0),
                                  child: Text(
                                    '30000',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: kGreen,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24).copyWith(top: 5.0),
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
                                      'mmd',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: kWhite,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        'pending',
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
                            Row(
                              children: <Widget>[
                                Visibility(
                                  visible: true,
                                  child: Card(
                                    elevation: 0,
                                    shape: const CircleBorder(),
                                    color: dark ? kGrey : kBlack,
                                    child: InkWell(
                                      onLongPress: () {},
                                      child: dark
                                          ? const Icon(Icons.check, color: Colors.black)
                                          : const Icon(Icons.check, color: Colors.white),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0).copyWith(top: 5.0),
                                  child: Text(
                                    '30000',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: kYellow,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24).copyWith(top: 5.0),
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
                                      'amirhosen',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: kWhite,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(
                                        'confirmed',
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
                            Row(
                              children: <Widget>[
                                Visibility(
                                  visible: false,
                                  child: Card(
                                    elevation: 0,
                                    shape: const CircleBorder(),
                                    color: dark ? kGrey : kBlack,
                                    child: InkWell(
                                      onLongPress: () {},
                                      child: dark
                                          ? const Icon(Icons.check, color: Colors.black)
                                          : const Icon(Icons.check, color: Colors.white),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0).copyWith(top: 5.0),
                                  child: Text(
                                    '30000',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: kGreen,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Card(
              color: dark ? kGrey : kBlack,
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0).copyWith(bottom: 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              'amirhosen',
                              style: TextStyle(
                                fontSize: 20,
                                color: kWhite,
                              ),
                            ),
                            Text(
                              'some description',
                              style: TextStyle(
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
                          '50750',
                          style: TextStyle(
                            fontSize: 20,
                            color: kGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Divider(color: kWhite),
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
                                'sadra',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: kWhite,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  'pending',
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
                          '17500',
                          style: TextStyle(
                            fontSize: 18,
                            color: kYellow,
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
                                'mmd',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: kWhite,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  'confirmed',
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
                          '11250',
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
                                'amirhosen',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: kWhite,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  'confirmed',
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
                          '22000',
                          style: TextStyle(
                            fontSize: 18,
                            color: kRed,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
          Card(
            color: dark ? kGrey : kBlack,
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0).copyWith(bottom: 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'mmd',
                            style: TextStyle(
                              fontSize: 20,
                              color: kWhite,
                            ),
                          ),
                          Text(
                            'some description',
                            style: TextStyle(
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
                        '120000',
                        style: TextStyle(
                          fontSize: 20,
                          color: kGreen,
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(color: kWhite),
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
                              'sadra',
                              style: TextStyle(
                                fontSize: 18,
                                color: kWhite,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                'pending',
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
                        '40000',
                        style: TextStyle(
                          fontSize: 18,
                          color: kYellow,
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
                              'mmd',
                              style: TextStyle(
                                fontSize: 18,
                                color: kWhite,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                'confirmed',
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
                        '40000',
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
                              'amirhosen',
                              style: TextStyle(
                                fontSize: 18,
                                color: kWhite,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Text(
                                'pending',
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
                        '40000',
                        style: TextStyle(
                          fontSize: 18,
                          color: kYellow,
                        ),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
