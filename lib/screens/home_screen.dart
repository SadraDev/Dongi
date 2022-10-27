import 'dart:convert';
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
  bool notification = false;
  List<dynamic> categories = [];
  List<dynamic> table = [];
  String? selected;

  Future<void> getNotifications() async {
    notification = false;
    List<dynamic> notifications = [];
    notifications = await Api.getFriendRequests(Shared.getUserId()!);
    if (notifications.isNotEmpty) setState(() => notification = true);
    notifications = [];

    notifications = await Api.getCatRequests(Shared.getUserId()!);
    if (notifications.isNotEmpty) {
      for (var notification in notifications) {
        for (var member in notification['pending']) {
          if (member == Shared.getUserName()!) this.notification = true;
        }
      }
    }

    setState(() {});
  }

  Future<void> getCats() async {
    categories = await Api.getCat(Shared.getUserId()!);
    selected = categories[0]['tbl_name'];
    getTable(selected!);
    setState(() {});
  }

  Future<void> getTable(String selected) async {
    table = await Api.getCatTable(selected);
  }

  Future<void> getInitials() async {
    getNotifications();
    getCats();
  }

  Future<void> _refresh() async {
    categories = await Api.getCat(Shared.getUserId()!);
    getNotifications();
    getTable(selected!);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getInitials();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      List<Widget> children;
      children = [
        HomeAppBar(
          profileImg: 'profile.jpg',
          username: Shared.getUserName()!,
          notification: notification,
          onPressed: () => Navigator.pushNamed(context, HomeNotificationsScreen.id),
        ),
        Builder(builder: (context) {
          List<Widget> children = [];
          if (categories.isNotEmpty) {
            for (var category in categories) {
              HomeCatSelectorBubble child = HomeCatSelectorBubble(
                catName: category['cat_name'],
                selected: selected == category['tbl_name'] ? true : false,
                onTap: () async {
                  table = [];
                  selected = category['tbl_name'];
                  await getTable(selected!);
                  setState(() {});
                },
              );
              children.add(child);
            }
          }

          return HomeCatSelector(
            children: children,
          );
        }),
        Builder(builder: (context) {
          List<Widget> children = [];
          int credit = 0;
          int dept = 0;
          List<dynamic> members = [];
          List<dynamic> membersStatus = [];

          if (table.isNotEmpty) {
            for (var data in jsonDecode(table[0]['individual_payments'])) {
              members.add(data[0]);
            }
            for (var member in members) {
              membersStatus.add([member, 0]);
            }

            for (var data in table) {
              List<dynamic> individualPayments = jsonDecode(data['individual_payments']);
              if (data['mother_buyer'] == Shared.getUserName()) {
                credit += int.parse(data['purchase_price']);
                for (var individualPayment in individualPayments) {
                  if (individualPayment[2] == 'confirmed') {
                    credit -= int.parse(individualPayment[1]);
                  }
                }
              }
              if (data['mother_buyer'] != Shared.getUserName()) {
                for (var individualPayment in individualPayments) {
                  if (individualPayment[0] == Shared.getUserName() && individualPayment[2] == 'pending') {
                    dept += int.parse(individualPayment[1]);
                  }
                }
              }

              if (data['mother_buyer'] == Shared.getUserName()) {
                for (int i = 0; i < individualPayments.length; i++) {
                  if (individualPayments[i][2] == 'pending') {
                    membersStatus[i][1] += int.parse(individualPayments[i][1]);
                  }
                }
              }
              for (int i = 0; i < members.length; i++) {
                if (data['mother_buyer'] == members[i] && data['mother_buyer'] != Shared.getUserName()) {
                  for (var payment in individualPayments) {
                    if (payment[0] == Shared.getUserName() && payment[2] == 'pending') {
                      membersStatus[i][1] -= int.parse(payment[1]);
                    }
                  }
                }
              }
            }

            for (var data in membersStatus) {
              HomeCatFriendDetailsBubble child = HomeCatFriendDetailsBubble(
                friendUsername: data[0],
                friendPrice: data[1].toString(),
                priceValue: data[1] >= 0,
              );
              if (child.friendUsername != Shared.getUserName()) children.add(child);
            }
          }

          return HomeCatDetails(
            priceValue: credit >= dept,
            price: (credit - dept).toString(),
            children: children,
          );
        }),
      ];

      for (var data in table.reversed) {
        List<Widget> detailsChildren = [];
        List<dynamic> onHandData = jsonDecode(data['individual_payments']);
        List<dynamic> payments = jsonDecode(data['individual_payments']);
        for (int i = 0; i < payments.length; i++) {
          HomePurchaseBubbleIndividualDetails child = HomePurchaseBubbleIndividualDetails(
            username: payments[i][0],
            individualPayment: payments[i][1],
            paymentStatus: payments[i][2] == 'confirmed',
            isMe: data['mother_buyer'] == Shared.getUserName(),
            userProfile: 'profile.jpg',
            onPaymentComplete: () {
              showDialog(
                context: context,
                builder: (context) => Directionality(
                  textDirection: TextDirection.rtl,
                  child: AlertDialog(
                    content: const Text('پرداخت انحام شد؟'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'خیر',
                          style: TextStyle(color: kRed),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          String status = 'invisible';
                          onHandData[i][2] = 'confirmed';
                          for (var data in onHandData) {
                            if (data[2] == 'pending') status = 'visible';
                          }
                          await Api.updateCatTable(selected!, onHandData, status, data['id'].toString());
                          await getTable(selected!);
                          Navigator.pop(context);
                          setState(() {});
                        },
                        child: const Text('بله'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
          detailsChildren.add(child);
        }

        HomePurchaseBubble bubble = HomePurchaseBubble(
          motherBuyer: data['mother_buyer'],
          purchaseDescription: data['purchase_description'],
          purchasePrice: data['purchase_price'],
          isMe: data['mother_buyer'] == Shared.getUserName(),
          visible: data['status'] == 'visible',
          onTapForCollapse: () async {
            List<dynamic> individualPayments = jsonDecode(data['individual_payments']);
            data['status'] == 'visible'
                ? await Api.updateCatTable(selected!, individualPayments, 'invisible', data['id'].toString())
                : await Api.updateCatTable(selected!, individualPayments, 'visible', data['id'].toString());
            await getTable(selected!);
            setState(() {});
          },
          children: detailsChildren,
        );
        children.add(bubble);
      }

      return RefreshIndicator(
        color: kBlack,
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 12).copyWith(bottom: 100),
          children: children,
        ),
      );
    });
  }
}
