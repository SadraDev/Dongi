import 'package:flutter/material.dart';
import 'package:my_hesab_ketab/constants.dart';
import 'package:my_hesab_ketab/screens/utilities/api.dart';
import 'package:my_hesab_ketab/screens/utilities/shared.dart';
import 'package:my_hesab_ketab/ui_widgets/home_screen/app_bar.dart';
import 'package:my_hesab_ketab/ui_widgets/home_screen/cat_details.dart';
import 'package:my_hesab_ketab/ui_widgets/home_screen/cat_selector.dart';
import 'package:my_hesab_ketab/ui_widgets/home_screen/notifications.dart';
import 'package:my_hesab_ketab/ui_widgets/home_screen/purchase_bubble.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  static const String id = 'home_screen';
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool visible = true;
  bool notification = false;
  String? _username;
  String? _userId;

  Future<void> getNotifications() async {
    List<dynamic> notification = await Api.getFriendRequests(_userId!);
    if (notification.isNotEmpty) setState(() => this.notification = true);
  }

  @override
  void initState() {
    _username = Shared.getUserName();
    _userId = Shared.getUserId();
    getNotifications();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: kBlack,
      onRefresh: getNotifications,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 12).copyWith(bottom: 100),
        children: <Widget>[
          HomeAppBar(
            profileImg: 'profile.jpg',
            username: _username!,
            notification: notification,
            notificationScreenBuilder: (context) => const HomeNotificationsScreen(),
          ),
          const HomeCatSelector(
            children: [
              HomeCatSelectorBubble(
                catName: 'birdan biyanadi',
                priceColor: kGreen,
                price: '30000',
                selected: true,
              ),
              HomeCatSelectorBubble(
                catName: 'da birajanidi',
                priceColor: kRed,
                price: '20000',
                selected: false,
              ),
            ],
          ),
          const HomeCatDetails(
            priceValue: true,
            price: '30000',
            children: [
              HomeCatFriendDetailsBubble(
                priceValue: true,
                friendPrice: '30000',
                friendUsername: 'Mohamad',
              ),
              HomeCatFriendDetailsBubble(
                priceValue: true,
                friendPrice: '0',
                friendUsername: 'AmirHossein',
              ),
            ],
          ),
          HomePurchaseBubble(
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
