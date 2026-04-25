import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/api_constants.dart';
import '../models/kit_model.dart';
import 'token_storage_service.dart';

class KitService {
  Future<Map<String, String>> _buildHeaders() async {
    final token = await TokenStorageService.getToken();

    return {
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<List<KitModel>> getAllKits() async {
    final headers = await _buildHeaders();

    final response = await http.get(
      Uri.parse('${ApiConstants.kits}/'),
      headers: headers,
    );

    return _parseKitListResponse(
      response,
      fallbackError: 'Failed to load kits',
    );
  }

  Future<List<KitModel>> getKitsByMindset(String mindset) async {
    final headers = await _buildHeaders();
    final url = '${ApiConstants.kitsByMindset}/$mindset';

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    return _parseKitListResponse(
      response,
      fallbackError: 'Failed to load kits by mindset',
    );
  }

  Future<List<KitModel>> searchKits(String keyword) async {
    final headers = await _buildHeaders();

    final uri = Uri.parse(ApiConstants.kitsSearch).replace(
      queryParameters: {'keyword': keyword},
    );

    final response = await http.get(
      uri,
      headers: headers,
    );

    return _parseKitListResponse(
      response,
      fallbackError: 'Failed to search kits',
    );
  }

  Future<KitModel> getKitById(int id) async {
    final headers = await _buildHeaders();
    final url = '${ApiConstants.kits}/$id';

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body);

      if (body is Map<String, dynamic>) {
        final dynamic actualData =
            body['data'] ?? body['result'] ?? body['kit'] ?? body;

        if (actualData is Map<String, dynamic>) {
          return KitModel.fromJson(actualData);
        }
      }

      throw Exception('Unexpected kit details response format');
    }

    throw Exception(
      _extractErrorMessage(response.body, 'Failed to load kit details'),
    );
  }

  List<KitModel> _parseKitListResponse(
      http.Response response, {
        required String fallbackError,
      }) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body);

      if (body is List) {
        return body.map((item) => KitModel.fromJson(item)).toList();
      }

      if (body is Map<String, dynamic>) {
        final dynamic data =
            body['data'] ??
                body['content'] ??
                body['kits'] ??
                body['result'] ??
                body['items'];

        if (data is List) {
          return data.map((item) => KitModel.fromJson(item)).toList();
        }
      }

      throw Exception('Unexpected kits response format');
    }

    throw Exception(_extractErrorMessage(response.body, fallbackError));
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