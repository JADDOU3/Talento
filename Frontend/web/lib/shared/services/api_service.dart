import 'package:flutter/foundation.dart';

class ApiService {
  static const String baseUrl = 'http://13.37.240.125/api';

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String gender,
    required String password,
  }) async {
    // TODO: implement with http package
    debugPrint('register called');
    return {'success': true, 'message': 'registered'};
  }

  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    // TODO: implement with http package
    debugPrint('login called');
    return {'success': true};
  }

  static Future<bool> refreshToken() async => false;

  static Future<String?> getAccessToken() async => null;
}