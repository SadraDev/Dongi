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
      body: {'username': username, 'password': password, 'profile_image': 'profile.jpg', 'friends': '[]'},
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

  static Future<List<dynamic>> getFriendRequests(String userId) async {
    Uri url = Uri.parse(kFriendRequestUrl);
    Response response = await post(
      url,
      body: {'type': 'pull', 'user_id': userId},
    );

    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  static Future<bool> sendFriendRequest(String targetId, List<dynamic> request) async {
    Uri url = Uri.parse(kFriendRequestUrl);
    Response response = await post(url, body: {'type': 'push', 'target_id': targetId, 'request': jsonEncode(request)});

    if (response.statusCode == 200) return true;
    return false;
  }

  static Future<List<dynamic>> getFriends(String targetId) async {
    Uri url = Uri.parse(kGetFriendsUrl);
    Response response = await post(
      url,
      body: {'type': 'pull', 'target_id': targetId},
    );

    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  static Future<bool> setFriends(String targetId, List<dynamic> friends) async {
    Uri url = Uri.parse(kGetFriendsUrl);
    Response response = await post(
      url,
      body: {'type': 'push', 'target_id': targetId, 'friends': jsonEncode(friends)},
    );

    if (response.statusCode == 200) return true;
    return false;
  }

  static Future<List<dynamic>> getCatRequests(String userId) async {
    Uri url = Uri.parse(kGetCatRequestUrl);
    Response response = await post(
      url,
      body: {'type': 'pull', 'user_id': userId},
    );

    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  static Future<bool> setCatRequest(String targetId, List<dynamic> request) async {
    Uri url = Uri.parse(kGetCatRequestUrl);
    Response response = await post(url, body: {'type': 'push', 'target_id': targetId, 'request': jsonEncode(request)});

    if (response.statusCode == 200) return true;
    return false;
  }

  static Future<List<dynamic>> getCat(String targetId) async {
    Uri url = Uri.parse(kGetCatsUrl);
    Response response = await post(url, body: {'type': 'pull', 'target_id': targetId});

    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  static Future<bool> setCat(String userId, List<dynamic> request, String tblName) async {
    Uri url = Uri.parse(kGetCatsUrl);
    Response response = await post(url,
        body: {'type': 'push', 'target_id': userId, 'request': jsonEncode(request), 'tbl_name': tblName});

    if (response.statusCode == 200) return true;
    return false;
  }

  static Future<List<dynamic>> getCatTable(String tblName) async {
    Uri url = Uri.parse(kGetCatTable);
    Response response = await post(url, body: {'type': 'get', 'tbl_name': tblName});

    if (response.statusCode == 200) return jsonDecode(response.body);
    return [];
  }

  static Future<bool> setCatTable(String tblName, String motherBuyer, String purchaseDes, String purchasePrice,
      List<dynamic> individualPayments) async {
    Uri url = Uri.parse(kGetCatTable);
    Response response = await post(url, body: {
      'type': 'set',
      'tbl_name': tblName,
      'mother_buyer': motherBuyer,
      'purchase_description': purchaseDes,
      'purchase_price': purchasePrice,
      'individual_payments': jsonEncode(individualPayments)
    });

    if (response.statusCode == 200) return true;
    return false;
  }

  static Future<bool> updateCatTable(String tblName, List<dynamic> individualPayments, String status, String id) async {
    Uri url = Uri.parse(kGetCatTable);
    Response response = await post(url, body: {
      'type': 'update',
      'tbl_name': tblName,
      'individual_payments': jsonEncode(individualPayments),
      'status': status,
      'id': id
    });

    if (response.statusCode == 200) return true;
    return false;
  }
}
