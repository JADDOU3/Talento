import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../../core/config/api_constants.dart';
import '../../models/user_model.dart';
import '../../models/child_model.dart';
import '../../models/kit_model.dart';
import '../../services/auth_service.dart';
import '../../services/token_storage_service.dart';

class ProfileService {
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

  Future<http.Response> _postWithRefresh(String url, Map<String, dynamic> body) async {
    var headers = await _getHeaders();
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

  Future<UserModel> getCurrentUser() async {
    final response = await _getWithRefresh(ApiConstants.currentUser);
    debugPrint('getCurrentUser: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to load user: ${response.statusCode}');
  }

  Future<List<ChildModel>> getChildren() async {
    final response = await _getWithRefresh(ApiConstants.children);
    debugPrint('getChildren: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => ChildModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load children: ${response.statusCode}');
  }

  Future<ChildModel?> getSelectedChild() async {
    final response = await _getWithRefresh(ApiConstants.selectedChild);
    debugPrint('getSelectedChild: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data == null) return null;
      return ChildModel.fromJson(data);
    }
    return null;
  }

  Future<List<KitModel>> getKitsByChild(int childId) async {
    final response = await _getWithRefresh(ApiConstants.kitsByChild(childId));
    debugPrint('getKitsByChild: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => KitModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load kits: ${response.statusCode}');
  }

  Future<ChildModel> addChild({
    required String name,
    required String dateOfBirth,
    required String gender,
  }) async {
    final response = await _postWithRefresh(ApiConstants.children, {
      'name': name,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
    });
    debugPrint('addChild: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200 || response.statusCode == 201) {
      return ChildModel.fromJson(jsonDecode(response.body));
    }
    throw Exception('Failed to add child: ${response.statusCode}');
  }
}