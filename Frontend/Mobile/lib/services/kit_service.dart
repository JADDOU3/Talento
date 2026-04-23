import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/config/api_constants.dart';
import '../models/kit_model.dart';
import 'token_storage_service.dart';

class KitService {
  Future<Map<String, String>> _buildHeaders() async {
    final token = await TokenStorageService.getToken();

    print('TOKEN: $token');

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

    print('GET ALL KITS URL: ${ApiConstants.kits}/');
    print('HEADERS: $headers');
    print('STATUS CODE: ${response.statusCode}');
    print('BODY: ${response.body}');

    return _parseKitListResponse(
      response,
      fallbackError: 'Failed to load kits',
    );
  }

  Future<List<KitModel>> getKitsByType(String type) async {
    final url = '${ApiConstants.kitsByType}/$type';
    final headers = await _buildHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    print('GET KITS BY TYPE URL: $url');
    print('HEADERS: $headers');
    print('STATUS CODE: ${response.statusCode}');
    print('BODY: ${response.body}');

    return _parseKitListResponse(
      response,
      fallbackError: 'Failed to load kits by type',
    );
  }

  Future<List<KitModel>> getKitsByMindset(String mindset) async {
    final url = '${ApiConstants.kitsByMindset}/$mindset';
    final headers = await _buildHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    print('GET KITS BY MINDSET URL: $url');
    print('HEADERS: $headers');
    print('STATUS CODE: ${response.statusCode}');
    print('BODY: ${response.body}');

    return _parseKitListResponse(
      response,
      fallbackError: 'Failed to load kits by mindset',
    );
  }

  Future<List<KitModel>> searchKits(String keyword) async {
    final uri = Uri.parse(ApiConstants.kitsSearch).replace(
      queryParameters: {'keyword': keyword},
    );
    final headers = await _buildHeaders();
    final response = await http.get(uri, headers: headers);

    print('SEARCH KITS URL: $uri');
    print('HEADERS: $headers');
    print('STATUS CODE: ${response.statusCode}');
    print('BODY: ${response.body}');

    return _parseKitListResponse(
      response,
      fallbackError: 'Failed to search kits',
    );
  }

  Future<KitModel> getKitById(int id) async {
    final url = '${ApiConstants.kits}/$id';
    final headers = await _buildHeaders();
    final response = await http.get(Uri.parse(url), headers: headers);

    print('GET KIT BY ID URL: $url');
    print('HEADERS: $headers');
    print('STATUS CODE: ${response.statusCode}');
    print('BODY: ${response.body}');

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