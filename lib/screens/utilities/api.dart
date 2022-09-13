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

  static Future<String> getId(String username) async {
    Uri url = Uri.parse(kGetUserIdUrl);
    Response response = await post(url, body: {'username': username});

    if (response.statusCode == 200) return jsonDecode(response.body).toString();
    return '0';
  }

  static Future<List<dynamic>> search(String username) async {
    Uri url = Uri.parse(kSearchUrl);
    Response response = await post(
      url,
      body: {'username': '$username%'},
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data;
    }
    return [];
  }

  static Future<bool> sendFriendRequest(String targetId, List<dynamic> request) async {
    Uri url = Uri.parse(kFriendRequestUrl);
    Response response = await post(url, body: {'type': 'push', 'target_id': targetId, 'request': jsonEncode(request)});

    if (response.statusCode == 200) return true;
    return false;
  }

  static Future<List<dynamic>> getFriendRequests(String userId) async {
    Uri url = Uri.parse(kFriendRequestUrl);
    Response response = await post(
      url,
      body: {'type': 'pull', 'user_id': userId},
    );

    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }
}
