import 'dart:convert';

import '../../core/config/api_constants.dart';
import '../../cubits/home/home_data.dart';
import '../../models/child_model.dart';
import '../auth/auth_api_client.dart';

class HomeService {
  final AuthApiClient _client = AuthApiClient();

  Future<bool> isNewUser() async {
    final response = await _client.get(
      Uri.parse(ApiConstants.isNewUser),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);

      if (decoded is bool) {
        return decoded;
      }

      if (decoded is Map<String, dynamic>) {
        final value = decoded['isNewUser'] ??
            decoded['newUser'] ??
            decoded['data'] ??
            decoded['result'];

        if (value is bool) return value;

        return value.toString().toLowerCase() == 'true';
      }

      return decoded.toString().toLowerCase() == 'true';
    }

    throw Exception(
      _extractErrorMessage(response.body, 'Failed to check user state'),
    );
  }

  Future<HomeData> getReturningUserHomeData() async {
    final selectedChild = await getSelectedChild();

    if (selectedChild == null) {
      return const HomeData();
    }

    return HomeData(
      selectedChild: selectedChild,
    );
  }

  Future<ChildModel?> getSelectedChild() async {
    final response = await _client.get(
      Uri.parse(ApiConstants.selectedChild),
    );

    if (response.statusCode == 404) {
      return null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.trim().isEmpty) {
        return null;
      }

      final decoded = jsonDecode(response.body);

      if (decoded == null) {
        return null;
      }

      if (decoded is Map<String, dynamic>) {
        final dynamic data = decoded['data'] ??
            decoded['child'] ??
            decoded['selectedChild'] ??
            decoded['result'] ??
            decoded;

        if (data is Map<String, dynamic>) {
          return ChildModel.fromJson(data);
        }
      }

      return null;
    }

    throw Exception(
      _extractErrorMessage(response.body, 'Failed to load selected child'),
    );
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
}