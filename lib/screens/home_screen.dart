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
  List<Widget>? children;

  List<dynamic> categories = [];

  Future<void> getNotifications() async {
    notification = false;
    List<dynamic> notifications = [];
    notifications = await Api.getFriendRequests(_userId!);
    if (notifications.isNotEmpty) setState(() => notification = true);
    notifications = [];

    notifications = await Api.getCatRequests(_userId!);
    if (notifications.isNotEmpty) setState(() => notification = true);

    setState(() {});
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
    return Builder(builder: (context) {
      children = [
        HomeAppBar(
          profileImg: 'profile.jpg',
          username: _username!,
          notification: notification,
          onPressed: () => Navigator.pushNamed(context, HomeNotificationsScreen.id),
        ),
        Builder(builder: (context) {
          List<Widget> children = [];

          for (var category in categories) {
            HomeCatSelectorBubble child = HomeCatSelectorBubble(
              catName: category['cat_name'],
              selected: false,
              onTap: () {},
            );
            children.add(child);
          }

          return HomeCatSelector(
            children: children,
          );
        }),
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
      ];

      return RefreshIndicator(
        color: kBlack,
        onRefresh: getNotifications,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 12).copyWith(bottom: 100),
          children: children!,
        ),
      );
    });
  }
}
