import 'package:shared_preferences/shared_preferences.dart';

class Shared {
  static SharedPreferences? _preferences;
  static const _userName = 'userName';
  static const _userPassword = 'userPassword';

  static Future init() async => _preferences = await SharedPreferences.getInstance();

  static Future setUserName(String userName) async => await _preferences!.setString(_userName, userName);

  static String? getUserName() => _preferences!.getString(_userName);

  static Future setUserPassword(String password) async => await _preferences!.setString(_userPassword, password);

  static String? getUserPassword() => _preferences!.getString(_userPassword);
}
