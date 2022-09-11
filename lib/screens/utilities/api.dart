import 'dart:convert';
import 'package:http/http.dart';
import 'package:my_hesab_ketab/constants.dart';

class Api {
  static Future<String> login(String username, String password) async {
    Uri url = Uri.parse(kLoginUrl);
    try {
      Response response = await post(url, body: {'username': username, 'password': password});
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data['result'] == true) return "true";
        try {
          if (data['result'] == false) return data['error'];
        } catch (e) {
          if (data['result'] == false) return data['error'][0];
        }
      }
      return "false";
    } catch (e) {
      return "NETWORK_ERROR";
    }
  }

  static Future<String> register(String username, String password) async {
    Uri url = Uri.parse(kRegisterUrl);
    Response response = await post(
      url,
      body: {'username': username, 'password': password, 'profile_image': '', 'friends': ''},
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      if (data['result'] == true) return 'true';
      try {
        if (data['result'] == false) return data['error'];
      } catch (e) {
        if (data['result'] == false) return data['error'][0];
      }
    }
    return 'false';
  }
}
