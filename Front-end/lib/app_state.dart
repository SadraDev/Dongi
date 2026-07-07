import 'package:flutter/material.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

final ValueNotifier<bool> showFriendsNotifier = ValueNotifier(true);
final ValueNotifier<bool> showGroupsNotifier = ValueNotifier(true);