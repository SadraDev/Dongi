import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Use 10.0.2.2 for Android Emulator, 127.0.0.1 for iOS Simulator
  // static const String _baseUrl = 'http://10.0.2.2:8000/api';
  static const String _baseUrl = 'http://81.22.134.29:8000/api';
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';

  // Initialize Dio with default options
  static final Dio _dio = Dio(
    BaseOptions(baseUrl: _baseUrl, contentType: Headers.jsonContentType),
  );

  // Initialize Secure Storage
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // --- Cross-Platform Storage Helpers ---

  static Future<void> _writeStorage(String key, String value) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } else {
      await _secureStorage.write(key: key, value: value);
    }
  }

  static Future<String?> _readStorage(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } else {
      return await _secureStorage.read(key: key);
    }
  }

  static Future<void> _deleteStorage(String key) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
    } else {
      await _secureStorage.delete(key: key);
    }
  }

  // --------------------------------------

  // Register
  static Future<String?> register(String username, String password) async {
    try {
      final response = await _dio.post(
        '/users/register/',
        data: {'username': username, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.data['token'];
        final userId = response.data['user']['id'];
        final userName = response.data['user']['username'];

        await _saveToken(token);
        await _saveUserId(userId);
        await _saveUserName(userName);

        return null; // Null means success (no error message)
      }
      return 'An unexpected error occurred.';
    } on DioException catch (e) {
      return _parseErrorMessage(e);
    } catch (e) {
      return 'Registration failed: $e';
    }
  }

  // Login
  static Future<String?> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/users/login/',
        data: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        final token = response.data['token'];
        final userId = response.data['user']['id'];
        final userName = response.data['user']['username'];

        await _saveToken(token);
        await _saveUserId(userId);
        await _saveUserName(userName);
        return null;
      }
      return 'An unexpected error occurred.';
    } on DioException catch (e) {
      return _parseErrorMessage(e);
    } catch (e) {
      return 'Login failed: $e';
    }
  }

  // Logout
  static Future<void> logout() async {
    await _deleteStorage(_tokenKey);
    await _deleteStorage(_userIdKey);
    await _deleteStorage(_userNameKey);
  }

  // Check if logged in
  static Future<bool> isLoggedIn() async {
    final token = await _readStorage(_tokenKey);
    return token != null;
  }

  // Get current token
  static Future<String?> getToken() async {
    return await _readStorage(_tokenKey);
  }

  // Get current user ID
  static Future<int> getCurrentUserId() async {
    final idString = await _readStorage(_userIdKey);
    if (idString != null) {
      return int.tryParse(idString) ?? 0;
    }
    return 0; // Fallback if not found
  }

  // Get current username
  static Future<String?> getCurrentUserName() async {
    return await _readStorage(_userNameKey);
  }

  // Save token securely
  static Future<void> _saveToken(String token) async {
    await _writeStorage(_tokenKey, token);
  }

  // Save User ID securely
  static Future<void> _saveUserId(int userId) async {
    await _writeStorage(_userIdKey, userId.toString());
  }

  static Future<void> _saveUserName(String userName) async {
    await _writeStorage(_userNameKey, userName.toString());
  }

  // Helper to extract errors seamlessly from Django DRF via Dio
  static String _parseErrorMessage(DioException e) {
    if (e.response != null && e.response?.data != null) {
      final data = e.response!.data;

      if (data is Map && data.isNotEmpty) {
        return data.values.first.toString().replaceAll(RegExp(r'[\[\]]'), '');
      }
    } else if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Check your server.';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'Cannot connect to the server. Is Django running?';
    }

    return 'Authentication failed. Please try again.';
  }
}