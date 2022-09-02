// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import '../constants.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({Key? key}) : super(key: key);
  static const String id = 'add_screen';

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  bool? tripleZero = true;
  bool? smartCal = true;

  @override
  Widget build(BuildContext context) {
    final dark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 100).copyWith(bottom: 180),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: dark ? kGrey : kBlack,
        child: ListView(
          children: <Widget>[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20).copyWith(bottom: 10),
                    color: kLighterGrey,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Cat Name'),
                    ),
                  ),
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20).copyWith(bottom: 10),
                    color: kWhite,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('cat'),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20).copyWith(bottom: 10),
                    color: kWhite,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Dog Name'),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 20).copyWith(bottom: 10),
                    color: kWhite,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Dog Name'),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: kWhite, indent: 12, endIndent: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: TextField(
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                cursorColor: kDarkModeBrown,
                style: TextStyle(color: kDarkModeBrown, fontSize: 20),
                decoration: InputDecoration(
                  labelText: 'Price',
                  labelStyle: TextStyle(color: kLighterGrey),
                  floatingLabelStyle: TextStyle(color: kDarkModeBrown),
                  suffix: GestureDetector(
                    onTap: () => setState(() => tripleZero = !tripleZero!),
                    child: Text(
                      tripleZero! ? '000' : 'T',
                      style: TextStyle(color: kDarkModeBrown, fontSize: 20),
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: kDarkModeBrown),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: kWhite),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 18.0),
              child: TextField(
                cursorColor: kDarkModeBrown,
                style: TextStyle(color: kDarkModeBrown, fontSize: 16),
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: kLighterGrey),
                  floatingLabelStyle: TextStyle(color: kDarkModeBrown),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 24),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: kDarkModeBrown),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: kWhite),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: CheckboxListTile(
                value: smartCal!,
                contentPadding: EdgeInsets.zero,
                onChanged: (value) => setState(() => smartCal = !smartCal!),
                activeColor: kDarkModeBrown,
                checkColor: dark ? kBlack : kWhite,
                title: Text(
                  'Smart Calculate',
                  style: TextStyle(color: kLighterGrey),
                ),
                subtitle: Text(
                  'smart calculate divides total price by number of members and adds the result to each member',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 8,
                  ),
                ),
              ),
            ),
            Visibility(
              visible: !smartCal!,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      child: TextField(
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        cursorColor: kDarkModeBrown,
                        style: TextStyle(color: kDarkModeBrown, fontSize: 20),
                        decoration: InputDecoration(
                          labelText: 'Mohamad',
                          labelStyle: TextStyle(color: kLighterGrey),
                          floatingLabelStyle: TextStyle(color: kDarkModeBrown),
                          suffix: GestureDetector(
                            //onTap: () => setState(() => tripleZero = !tripleZero!),
                            child: Text(
                              tripleZero! ? '000' : 'T',
                              style: TextStyle(color: kDarkModeBrown, fontSize: 20),
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: kDarkModeBrown),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: kWhite),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                      child: TextField(
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        cursorColor: kDarkModeBrown,
                        style: TextStyle(color: kDarkModeBrown, fontSize: 20),
                        decoration: InputDecoration(
                          labelText: 'AmirHossein',
                          labelStyle: TextStyle(color: kLighterGrey),
                          floatingLabelStyle: TextStyle(color: kDarkModeBrown),
                          suffix: GestureDetector(
                            //onTap: () => setState(() => tripleZero = !tripleZero!),
                            child: Text(
                              tripleZero! ? '000' : 'T',
                              style: TextStyle(color: kDarkModeBrown, fontSize: 20),
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: kDarkModeBrown),
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: kWhite),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(primary: kDarkModeBrown),
                child: Text('add'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
