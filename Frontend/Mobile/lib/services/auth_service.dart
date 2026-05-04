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
        headers: _headers,
        body: jsonEncode({
          'name': name,
          'email': email,
          'gender': gender,
          'password': password,
        }),
      )
          .timeout(_timeout);

      final body = response.body.trim();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body;
      }

      throw Exception(_extractErrorMessage(body, 'Registration failed'));
    } on TimeoutException {
      throw Exception('Connection timeout');
    } catch (e) {
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
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      )
          .timeout(_timeout);

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

        return;
      }

      throw Exception(_extractErrorMessage(body, 'Login failed'));
    } on TimeoutException {
      throw Exception('Connection timeout');
    } catch (e) {
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
        headers: _headers,
        body: jsonEncode({
          'refreshToken': oldRefreshToken,
        }),
      )
          .timeout(_timeout);

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

        return true;
      }

      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    await TokenStorageService.clearTokens();
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

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