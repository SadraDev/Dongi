import 'package:dio/dio.dart';
import '../models/group_model.dart';
import 'auth_service.dart';

class GroupService {
  static final Dio _dio = Dio(
    BaseOptions(
      // baseUrl: 'http://10.0.2.2:8000/api',
      baseUrl: 'http://81.22.134.29:8000/api',
    ),
  );

  static Future<List<Group>> fetchGroups() async {
    final token = await AuthService.getToken();
    final response = await _dio.get(
      '/expenses/groups/',
      options: Options(headers: {'Authorization': 'Token $token'}),
    );

    if (response.statusCode == 200) {
      List<dynamic> data = response.data;
      return data.map((json) => Group.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load groups');
    }
  }

  static Future<void> createGroup(String name, List<String> members) async {
    final token = await AuthService.getToken();
    await _dio.post(
      '/expenses/groups/create/',
      data: {'name': name, 'members': members},
      options: Options(headers: {'Authorization': 'Token $token'}),
    );
  }

  static Future<void> acceptGroupInvite(int groupId) async {
    final token = await AuthService.getToken();
    try {
      await _dio.post(
        '/expenses/groups/$groupId/accept/',
        options: Options(headers: {'Authorization': 'Token $token'}),
      );
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        final data = e.response!.data;
        if (data['error'] != null) {
          throw Exception(data['error']);
        }
      }
      throw Exception('Failed to accept group invite.');
    }
  }

  static Future<void> rejectGroupInvite(int groupId) async {
    final token = await AuthService.getToken();
    try {
      await _dio.delete(
        '/expenses/groups/$groupId/reject/',
        options: Options(headers: {'Authorization': 'Token $token'}),
      );
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        final data = e.response!.data;
        if (data['error'] != null) {
          throw Exception(data['error']);
        }
      }
      throw Exception('Failed to reject group invite.');
    }
  }

  static Future<void> deleteGroup(int groupId) async {
    final token = await AuthService.getToken();
    try {
      await _dio.delete(
        '/expenses/groups/$groupId/delete/',
        options: Options(headers: {'Authorization': 'Token $token'}),
      );
    } on DioException catch (e) {
      if (e.response != null && e.response!.data is Map) {
        final data = e.response!.data;
        if (data['error'] != null) {
          throw Exception(data['error']);
        }
      }
      throw Exception('Failed to delete group.');
    }
  }

  static Future<Map<String, dynamic>> getGroupDetails(int groupId) async {
    final token = await AuthService.getToken();
    final response = await _dio.get(
      '/expenses/groups/$groupId/',
      options: Options(headers: {'Authorization': 'Token $token'}),
    );
    return response.data;
  }

  static Future<void> addExpense({
    int? groupId,
    int? friendId,
    required String description,
    required double totalAmount,
    required bool divideEqually,
    List<Map<String, dynamic>>? customSplits,
  }) async {
    final token = await AuthService.getToken();

    final Map<String, dynamic> data = {
      'description': description,
      'total_amount': totalAmount,
      'divide_equally': divideEqually,
      'custom_splits': customSplits,
    };

    if (groupId != null) data['group'] = groupId;
    if (friendId != null) data['friend_id'] = friendId;

    await _dio.post(
      '/expenses/expenses/create/',
      data: data,
      options: Options(headers: {'Authorization': 'Token $token'}),
    );
  }

  static Future<void> toggleExpenseSplitStatus(int splitId, bool isPaid) async {
    final token = await AuthService.getToken();
    final url = '/expenses/splits/$splitId/settle/';

    try {
      await _dio.post(
        url,
        data: {'is_paid': isPaid},
        options: Options(headers: {'Authorization': 'Token $token'}),
      );
    } on DioException catch (e) {
      throw Exception('Failed to update status: ${e.message}');
    }
  }

  // Sends a group request to an individual friend to join an existing group
  static Future<void> inviteFriendToGroup(int groupId, String username) async {
    final token = await AuthService.getToken();
    try {
      await _dio.post(
        '/expenses/groups/$groupId/invite/',
        data: {'username': username},
        options: Options(headers: {'Authorization': 'Token $token'}),
      );
    } on DioException catch (e) {
      if (e.response != null) {
        final int? statusCode = e.response!.statusCode;
        final data = e.response!.data;

        // 1. Handle 400s (Custom backend errors like "User does not exist" or "Invitation already sent")
        if (statusCode == 400 && data['error'] != null) {
          throw Exception(data['error']);
        }

        // 2. Handle 401/403s (Authentication/Permission issues)
        if ((statusCode == 401 || statusCode == 403) && data['detail'] != null) {
          throw Exception(data['detail']);
        }

        // 3. Handle 404s (Generic not found)
        if (statusCode == 404 && data['detail'] != null) {
          throw Exception(data['detail']);
        }

        // Fallback just in case
        throw Exception('An unexpected error occurred');
      } else {
        // If e.response is null, it means the internet dropped or the server is completely down
        throw Exception('No internet connection or server is unreachable.');
      }
    }
  }
}
