import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:my_hesab_ketab/constants.dart';

class HomeNotificationBubble extends StatelessWidget {
  const HomeNotificationBubble({
    Key? key,
    required this.requesterProfileImg,
    required this.requesterUsername,
    required this.requestedCatName,
    required this.catRequest,
    required this.onAccept,
    required this.onDeny,
  }) : super(key: key);
  final String requesterProfileImg;
  final String requesterUsername;
  final String requestedCatName;
  final bool catRequest;
  final void Function()? onAccept;
  final void Function()? onDeny;

  @override
  Widget build(BuildContext context) {
    final dark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Card(
      color: dark ? kGrey : kLighterGrey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/images/$requesterProfileImg',
                    height: 80,
                    width: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  Text(
                    requesterUsername,
                    style: TextStyle(
                      color: dark ? kWhite : kBlack,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 15),
                  catRequest
                      ? Text(
                          'Group req : \n $requestedCatName',
                          style: TextStyle(
                            color: dark ? kWhite : kBlack,
                            fontSize: 14,
                          ),
                        )
                      : Text(
                          'Friend request',
                          style: TextStyle(
                            color: dark ? kLighterGrey : kGrey,
                            fontSize: 14,
                          ),
                        ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              children: <Widget>[
                IconButton(
                  onPressed: onDeny,
                  icon: const Icon(FontAwesomeIcons.xmark, color: kRed),
                ),
                IconButton(
                  onPressed: onAccept,
                  icon: const Icon(FontAwesomeIcons.check, color: kGreen),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
