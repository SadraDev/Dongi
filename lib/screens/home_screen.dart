// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:my_hesab_ketab/constants.dart';
import 'package:my_hesab_ketab/ui_widgets/home_screen/app_bar.dart';
import 'package:my_hesab_ketab/ui_widgets/home_screen/cat_details.dart';
import 'package:my_hesab_ketab/ui_widgets/home_screen/cat_selector.dart';
import 'package:my_hesab_ketab/ui_widgets/home_screen/purchase_bubble.dart';

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
          HomeAppBar(
            dark: dark,
            profileImg: 'profile.jpg',
            username: 'sadra',
            iconButton: () {},
          ),
          HomeCatSelector(
            dark: dark,
            children: [
              HomeCatSelectorBubble(
                catName: 'birdan biyanadi',
                priceColor: kGreen,
                price: '30000',
                selected: true,
                dark: dark,
              ),
              HomeCatSelectorBubble(
                catName: 'da birajanidi',
                priceColor: kRed,
                price: '20000',
                selected: false,
                dark: dark,
              ),
            ],
          ),
          HomeCatDetails(
            dark: dark,
            priceValue: true,
            price: '30000',
            children: [
              HomeCatFriendDetailsBubble(
                dark: dark,
                priceValue: true,
                friendPrice: '30000',
                friendUsername: 'Mohamad',
              ),
              HomeCatFriendDetailsBubble(
                dark: dark,
                priceValue: true,
                friendPrice: '0',
                friendUsername: 'AmirHossein',
              ),
            ],
          ),
          HomePurchaseBubble(
            dark: dark,
            onTapForCollapse: () => setState(() => visible = !visible),
            motherBuyer: 'Sadra',
            purchaseDescription: 'Los Pollos hermanos',
            purchasePrice: '90000',
            visible: visible,
            children: [
              HomePurchaseBubbleIndividualDetails(
                userProfile: 'profile.jpg',
                username: 'Sadra',
                paymentStatus: true,
                individualPayment: '30000',
                onPaymentComplete: () {},
              ),
              HomePurchaseBubbleIndividualDetails(
                userProfile: 'profile.jpg',
                username: 'Mohamad',
                paymentStatus: false,
                individualPayment: '30000',
                onPaymentComplete: () {},
              ),
              HomePurchaseBubbleIndividualDetails(
                userProfile: 'profile.jpg',
                username: 'AmirHossein',
                paymentStatus: true,
                individualPayment: '30000',
                onPaymentComplete: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
