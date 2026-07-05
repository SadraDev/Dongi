import 'package:dio/dio.dart';
import 'auth_service.dart';

class FriendService {
  static final Dio _dio = Dio(
    BaseOptions(
      // baseUrl: 'http://10.0.2.2:8000/api',
      baseUrl: 'http://81.22.134.29:8000/api',
    ),
  );

  // Helper to get headers with the auth token
  static Future<Options> _getAuthOptions() async {
    final token = await AuthService.getToken();
    return Options(headers: {'Authorization': 'Token $token'});
  }

  // 1. Send a friend request
  static Future<void> sendFriendRequest(String username) async {
    final options = await _getAuthOptions();
    await _dio.post(
      '/friends/send/',
      data: {'receiver': username},
      options: options,
    );
  }

  // 2. Get list of received pending friend requests
  static Future<List<dynamic>> getPendingRequests() async {
    final options = await _getAuthOptions();
    final response = await _dio.get('/friends/requests/', options: options);
    return response.data; // Returns a list of JSON objects
  }

  // 3. Accept a friend request
  static Future<void> acceptFriendRequest(int requestId) async {
    final options = await _getAuthOptions();
    await _dio.put('/friends/accept/$requestId/', options: options);
  }

  // 4. Reject a friend request
  static Future<void> rejectFriendRequest(int requestId) async {
    final options = await _getAuthOptions();
    await _dio.delete('/friends/reject/$requestId/', options: options);
  }

  // Add these to your FriendService class
  static Future<List<dynamic>> searchUsers(String query) async {
    final options = await _getAuthOptions();
    final response = await _dio.get(
      '/users/search/?q=$query',
      options: options,
    );
    return response.data;
  }

  static Future<List<dynamic>> getFriends() async {
    final options = await _getAuthOptions();
    final response = await _dio.get('/friends/list/', options: options);
    return response.data;
  }

  static Future<void> removeFriend(int friendshipId) async {
    final options = await _getAuthOptions();
    await _dio.delete('/friends/remove/$friendshipId/', options: options);
  }
}
