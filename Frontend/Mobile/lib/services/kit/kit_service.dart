import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/api_constants.dart';
import '../../models/kit/kit_model.dart';
import '../../models/kit/mindset_model.dart';
import '../auth/auth_api_client.dart';

class KitService {
  final AuthApiClient _client = AuthApiClient();

  Future<List<KitModel>> getAllKits({int page = 0, int size = 10}) async {
    final uri = Uri.parse('${ApiConstants.kits}/').replace(
      queryParameters: {
        'page': page.toString(),
        'size': size.toString(),
      },
    );

    final response = await _client.get(uri);

    return _parseKitListResponse(
      response,
      fallbackError: 'Failed to load kits',
    );
  }

  Future<List<MindsetModel>> getMindsets() async {
    final response = await _client.get(
      Uri.parse(ApiConstants.mindsets),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body);
      final data = _extractList(body);

      if (data != null) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(MindsetModel.fromJson)
            .where((mindset) => mindset.id != 0 && mindset.name.isNotEmpty)
            .toList();
      }

      throw Exception('Unexpected mindsets response format');
    }

    throw Exception(_extractErrorMessage(response.body, 'Failed to load mindsets'));
  }

  Future<List<KitModel>> getKitsByMindset(int mindsetId) async {
    final response = await _client.get(
      Uri.parse('${ApiConstants.kitsByMindset}/$mindsetId'),
    );

    return _parseKitListResponse(
      response,
      fallbackError: 'Failed to load kits by mindset',
    );
  }

  Future<List<KitModel>> getKitsByMindsetLegacy(String mindset) async {
    final response = await _client.get(
      Uri.parse('${ApiConstants.kitsByMindset}/$mindset'),
    );

    return _parseKitListResponse(
      response,
      fallbackError: 'Failed to load kits by mindset',
    );
  }

  Future<List<KitModel>> getKitsByType(String type) async {
    final response = await _client.get(
      Uri.parse('${ApiConstants.kitsByType}/$type'),
    );

    return _parseKitListResponse(
      response,
      fallbackError: 'Failed to load kits by type',
    );
  }

  Future<List<KitModel>> searchKits(String keyword) async {
    final uri = Uri.parse(ApiConstants.kitsSearch).replace(
      queryParameters: {'keyword': keyword},
    );

    final response = await _client.get(uri);

    return _parseKitListResponse(
      response,
      fallbackError: 'Failed to search kits',
    );
  }

  Future<KitModel> getKitById(int id) async {
    final response = await _client.get(
      Uri.parse('${ApiConstants.kits}/$id'),
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
      final data = _extractList(body);

      if (data != null) {
        return data
            .whereType<Map<String, dynamic>>()
            .map(KitModel.fromJson)
            .toList();
      }

      throw Exception('Unexpected kits response format');
    }

    throw Exception(_extractErrorMessage(response.body, fallbackError));
  }

  List<dynamic>? _extractList(dynamic body) {
    if (body is List) return body;

    if (body is Map<String, dynamic>) {
      final dynamic directData =
          body['data'] ?? body['content'] ?? body['kits'] ?? body['result'] ?? body['items'];

      if (directData is List) return directData;

      if (directData is Map<String, dynamic>) {
        final dynamic nestedData = directData['content'] ??
            directData['data'] ??
            directData['kits'] ??
            directData['items'] ??
            directData['result'];

        if (nestedData is List) return nestedData;
      }
    }

    return null;
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
