import 'package:dio/dio.dart';
import 'auth_service.dart';

class NotificationService {
  // static final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000/api'));
  static final Dio _dio = Dio(BaseOptions(baseUrl: 'http://81.22.134.29:8000/api'));

  static Future<List<dynamic>> fetchNotifications() async {
    final token = await AuthService.getToken();
    final response = await _dio.get(
      '/notifications/',
      options: Options(headers: {'Authorization': 'Token $token'}),
    );
    return response.data;
  }

  static Future<void> markAsRead(int id) async {
    final token = await AuthService.getToken();
    await _dio.patch(
      '/notifications/$id/',
      data: {'is_read': true},
      options: Options(headers: {'Authorization': 'Token $token'}),
    );
  }

  static Future<int> getUnreadCount() async {
    final token = await AuthService.getToken();
    final response = await _dio.get(
      '/notifications/unread-count/',
      options: Options(headers: {'Authorization': 'Token $token'}),
    );
    return response.data['count'];
  }

  /// Sends a "Pay Up!" payment reminder to a specific group member
  static Future<void> sendPaymentReminder({
    required int recipientId,
    required int groupId,
  }) async {
    final token = await AuthService.getToken();
    await _dio.post(
      '/notifications/remind/',
      data: {'recipient_id': recipientId, 'group_id': groupId},
      options: Options(headers: {'Authorization': 'Token $token'}),
    );
  }
}
