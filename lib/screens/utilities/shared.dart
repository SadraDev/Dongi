import 'package:shared_preferences/shared_preferences.dart';

class Shared {
  static SharedPreferences? _preferences;
  static const _userName = 'userName';
  static const _userPassword = 'userPassword';
  static const _userId = 'userId';

  static Future init() async => _preferences = await SharedPreferences.getInstance();

  static Future setUserName(String userName) async => await _preferences!.setString(_userName, userName);

  static String? getUserName() => _preferences!.getString(_userName);

  static Future setUserPassword(String password) async => await _preferences!.setString(_userPassword, password);

  static String? getUserPassword() => _preferences!.getString(_userPassword);

  static Future setUserId(String userId) async => await _preferences!.setString(_userId, userId);

  static String? getUserId() => _preferences!.getString(_userId);
}
