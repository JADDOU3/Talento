import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/api_constants.dart';
import '../../models/user_model.dart';
import '../../models/child_model.dart';

import '../../services/token_storage_service.dart';
import '../models/kit_model.dart';

class ProfileService {
  // Get headers with token
  Future<Map<String, String>> _getHeaders() async {
    final token = await TokenStorageService.getAccessToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // GET current user
  Future<UserModel> getCurrentUser() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse(ApiConstants.currentUser),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);
    }
    throw Exception('Failed to load user: ${response.statusCode}');
  }

  // GET children
  Future<List<ChildModel>> getChildren() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse(ApiConstants.children),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => ChildModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load children: ${response.statusCode}');
  }

  // GET selected child
  Future<ChildModel?> getSelectedChild() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse(ApiConstants.selectedChild),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data == null) return null;
      return ChildModel.fromJson(data);
    }
    return null;
  }

  // GET kits by child
  Future<List<KitModel>> getKitsByChild(int childId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse(ApiConstants.kitsByChild(childId)),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => KitModel.fromJson(e)).toList();
    }
    throw Exception('Failed to load kits: ${response.statusCode}');
  }
}