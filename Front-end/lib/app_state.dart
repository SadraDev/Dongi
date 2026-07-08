import 'package:flutter/material.dart';

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

final ValueNotifier<bool> showFriendsNotifier = ValueNotifier(false);
final ValueNotifier<bool> showGroupsNotifier = ValueNotifier(true);