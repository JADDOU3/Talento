import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/api_constants.dart';

class AuthService {
  Future<String> register({
    required String name,
    required String email,
    required String gender,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.register),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'name': name,
        'email': email,
        'gender': gender,
        'password': password,
      }),
    );

    final body = response.body.trim();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      throw Exception(body.isNotEmpty ? body : 'Registration failed');
    }
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConstants.login),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    print('LOGIN STATUS: ${response.statusCode}');
    print('LOGIN BODY: ${response.body}');

    final body = response.body.trim();
    final normalizedBody = body.toLowerCase();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (normalizedBody == 'not authenticated') {
        throw Exception('not authenticated');
      }

      return body;
    } else {
      throw Exception(body.isNotEmpty ? body : 'Login failed');
    }
  }
}