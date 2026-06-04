import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../core/config/api_constants.dart';
import '../services/auth/auth_service.dart';
import '../services/auth/token_storage_service.dart';

class ChildModeService {
  Future<Map<String, String>> _getHeaders() async {
    final token = await TokenStorageService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<http.Response> _getWithRefresh(String url) async {
    var headers = await _getHeaders();
    var response = await http.get(Uri.parse(url), headers: headers);
    if (response.statusCode == 401) {
      final refreshed = await AuthService().refreshToken();
      if (refreshed) {
        headers = await _getHeaders();
        response = await http.get(Uri.parse(url), headers: headers);
      }
    }
    return response;
  }

  Future<http.Response> _postWithRefresh(String url, {Map<String, dynamic>? body}) async {
    var headers = await _getHeaders();
    var response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    if (response.statusCode == 401) {
      final refreshed = await AuthService().refreshToken();
      if (refreshed) {
        headers = await _getHeaders();
        response = await http.post(
          Uri.parse(url),
          headers: headers,
          body: body != null ? jsonEncode(body) : null,
        );
      }
    }
    return response;
  }

  Future<bool> isChildMode() async {
    final response = await _getWithRefresh(ApiConstants.isChildMode);
    if (response.statusCode == 200) {
      return response.body.trim() == 'true';
    }
    throw Exception('Failed to check child mode: ${response.statusCode}');
  }

  Future<bool> hasPin() async {
    final response = await _getWithRefresh(ApiConstants.childModeHasPin);
    if (response.statusCode == 200) {
      return response.body.trim() == 'true';
    }
    throw Exception('Failed to check PIN: ${response.statusCode}');
  }

  Future<void> enableChildMode() async {
    debugPrint('ENABLING CHILD MODE');
    final response = await _postWithRefresh(ApiConstants.childModeEnable);
    debugPrint('ENABLE STATUS: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) return;
    if (response.statusCode == 400) throw Exception('PIN_REQUIRED');
    throw Exception('Failed to enable child mode');
  }

  Future<void> disableChildMode(String pin) async {
    final response = await _postWithRefresh(
      ApiConstants.childModeDisable,
      body: {'pin': pin},
    );
    if (response.statusCode == 200) return;
    if (response.statusCode == 401) {
      throw Exception('Incorrect PIN');
    }
    throw Exception('Failed to disable child mode: ${response.statusCode}');
  }

  Future<void> setPin(String pin) async {
    debugPrint('SETTING PIN: $pin');
    final response = await _postWithRefresh(
      ApiConstants.childModeSetPin,
      body: {'pin': pin},
    );
    debugPrint('SET PIN STATUS: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) return;
    throw Exception('Failed to set PIN: ${response.body}');
  }

}
