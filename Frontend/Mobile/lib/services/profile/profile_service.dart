import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

import '../../core/config/api_constants.dart';
import '../../models/childmode/child_model.dart';
import '../../models/childmode/user_model.dart';
import '../../models/kit/kit_model.dart';
import '../auth/auth_service.dart';
import '../auth/token_storage_service.dart';

class ProfileService {
  Future<Map<String, String>> _getHeaders() async {
    final token = await TokenStorageService.getAccessToken();

    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty)
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

  Future<http.Response> _postWithRefresh(
      String url,
      Map<String, dynamic> body,
      ) async {
    var headers = await _getHeaders();

    debugPrint('POST URL: $url');
    debugPrint('POST BODY: ${jsonEncode(body)}');
    debugPrint('HAS TOKEN: ${headers['Authorization'] != null}');

    var response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 401) {
      final refreshed = await AuthService().refreshToken();

      if (refreshed) {
        headers = await _getHeaders();

        response = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(body),
        );
      }
    }

    return response;
  }

  Future<http.Response> _putWithRefresh(String url) async {
    var headers = await _getHeaders();

    debugPrint('PUT URL: $url');
    debugPrint('HAS TOKEN: ${headers['Authorization'] != null}');

    var response = await http.put(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 401) {
      final refreshed = await AuthService().refreshToken();

      if (refreshed) {
        headers = await _getHeaders();

        response = await http.put(
          Uri.parse(url),
          headers: headers,
        );
      }
    }

    return response;
  }

  List<dynamic> _extractListFromResponse(dynamic decoded) {
    if (decoded is List) {
      return decoded;
    }

    if (decoded is Map<String, dynamic> && decoded['content'] is List) {
      return decoded['content'] as List<dynamic>;
    }

    return [];
  }

  String _extractErrorMessage(String body, String fallback) {
    try {
      final decoded = jsonDecode(body);

      if (decoded is Map<String, dynamic>) {
        return (decoded['message'] ?? decoded['error'] ?? fallback).toString();
      }
    } catch (_) {}

    return body.trim().isEmpty ? fallback : body.trim();
  }

  Future<UserModel> getCurrentUser() async {
    final response = await _getWithRefresh(ApiConstants.currentUser);

    debugPrint('getCurrentUser: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    }

    throw Exception(
      _extractErrorMessage(
        response.body,
        'Failed to load user: ${response.statusCode}',
      ),
    );
  }

  Future<List<ChildModel>> getChildren() async {
    final response = await _getWithRefresh(ApiConstants.children);

    debugPrint('getChildren: ${response.statusCode} - ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      final data = _extractListFromResponse(decoded);

      return data
          .whereType<Map>()
          .map(
            (item) => ChildModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();
    }

    throw Exception(
      _extractErrorMessage(
        response.body,
        'Failed to load children: ${response.statusCode}',
      ),
    );
  }

  Future<ChildModel?> getSelectedChild() async {
    final response = await _getWithRefresh(ApiConstants.selectedChild);

    debugPrint('getSelectedChild: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 404) {
      return null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.trim().isEmpty) {
        return null;
      }

      final data = jsonDecode(response.body);

      if (data == null) return null;

      if (data is Map<String, dynamic>) {
        return ChildModel.fromJson(data);
      }

      return null;
    }

    return null;
  }

  Future<void> setSelectedChild(int childId) async {
    final response = await _putWithRefresh(
      ApiConstants.setSelectedChild(childId),
    );

    debugPrint('setSelectedChild: ${response.statusCode} - ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw Exception(
      _extractErrorMessage(
        response.body,
        'Failed to set selected child: ${response.statusCode}',
      ),
    );
  }

  Future<void> selectChild(int childId) async {
    await setSelectedChild(childId);
  }

  Future<List<KitModel>> getKitsByChild(int childId) async {
    final response = await _getWithRefresh(
      ApiConstants.kitsByChild(childId),
    );

    debugPrint('getKitsByChild: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 404) {
      return [];
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.trim().isEmpty) {
        return [];
      }

      final decoded = jsonDecode(response.body);
      final data = _extractListFromResponse(decoded);

      return data
          .whereType<Map>()
          .map(
            (item) => KitModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();
    }

    throw Exception(
      _extractErrorMessage(
        response.body,
        'Failed to load kits: ${response.statusCode}',
      ),
    );
  }

  Future<ChildModel> addChild({
    required String name,
    required String dateOfBirth,
    required String gender,
  }) async {
    final formattedGender =
    gender.toLowerCase() == 'male' || gender == 'ذكر'
        ? 'Male'
        : 'Female';

    final formattedDate = dateOfBirth.contains('T')
        ? dateOfBirth
        : '${dateOfBirth}T00:00:00';

    final body = {
      'name': name,
      'dateOfBirth': formattedDate,
      'gender': formattedGender,
    };

    final response = await _postWithRefresh(
      ApiConstants.addChild,
      body,
    );

    debugPrint('addChild: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ChildModel.fromJson(jsonDecode(response.body));
    }

    throw Exception(
      _extractErrorMessage(
        response.body,
        'Failed to add child: ${response.statusCode}',
      ),
    );
  }
}