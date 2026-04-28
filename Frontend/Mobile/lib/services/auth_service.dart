import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/config/api_constants.dart';
import 'token_storage_service.dart';

class AuthService {
  static const Duration _timeout = Duration(seconds: 15);

  Future<String> register({
    required String name,
    required String email,
    required String gender,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse(ApiConstants.register),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'gender': gender,
          'password': password,
        }),
      )
          .timeout(_timeout);

      print('REG ${response.statusCode}');

      final body = response.body.trim();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      }

      throw Exception(_extractErrorMessage(body, 'Registration failed'));
    } on TimeoutException {
      print('REG timeout');
      throw Exception('Connection timeout');
    } catch (e) {
      print('REG error');
      throw Exception(_cleanException(e));
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse(ApiConstants.login),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      )
          .timeout(_timeout);

      print('LOGIN ${response.statusCode}');

      final body = response.body.trim();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (!body.startsWith('{')) {
          throw Exception('Invalid response');
        }

        final decoded = jsonDecode(body);

        final accessToken = decoded['accessToken'];
        final refreshToken = decoded['refreshToken'];

        if (accessToken == null || refreshToken == null) {
          throw Exception('Missing tokens');
        }

        await TokenStorageService.saveTokens(
          accessToken: accessToken,
          refreshToken: refreshToken,
        );

        print('LOGIN ok');
        return;
      }

      throw Exception(_extractErrorMessage(body, 'Login failed'));
    } on TimeoutException {
      print('LOGIN timeout');
      throw Exception('Connection timeout');
    } catch (e) {
      print('LOGIN error');
      throw Exception(_cleanException(e));
    }
  }

  Future<bool> refreshToken() async {
    try {
      final oldRefreshToken = await TokenStorageService.getRefreshToken();

      if (oldRefreshToken == null || oldRefreshToken.isEmpty) {
        return false;
      }

      final response = await http
          .post(
        Uri.parse(ApiConstants.refresh),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'refreshToken': oldRefreshToken,
        }),
      )
          .timeout(_timeout);

      print('REF ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = response.body.trim();

        if (!body.startsWith('{')) {
          return false;
        }

        final decoded = jsonDecode(body);

        final newAccessToken = decoded['accessToken'];
        final newRefreshToken = decoded['refreshToken'];

        if (newAccessToken == null || newRefreshToken == null) {
          return false;
        }

        await TokenStorageService.saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        print('REF ok');
        return true;
      }

      return false;
    } catch (e) {
      print('REF error');
      return false;
    }
  }

  Future<void> logout() async {
    await TokenStorageService.clearTokens();
    print('LOGOUT');
  }

  String _extractErrorMessage(String body, String fallback) {
    try {
      final decoded = jsonDecode(body);

      if (decoded is Map<String, dynamic>) {
        return (decoded['message'] ?? decoded['error'] ?? fallback).toString();
      }
    } catch (_) {}

    return body.isEmpty ? fallback : body;
  }

  String _cleanException(Object error) {
    String message = error.toString();

    if (message.startsWith('Exception: ')) {
      message = message.replaceFirst('Exception: ', '');
    }

    return message;
  }
}