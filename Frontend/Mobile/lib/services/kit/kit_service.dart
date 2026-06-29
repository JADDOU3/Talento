import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/api_constants.dart';
import '../../models/kit/kit_model.dart';
import '../../models/kit/mindset_model.dart';
import '../auth/auth_api_client.dart';

class KitPageResult {
  final List<KitModel> kits;
  final int page;
  final int size;
  final bool isLast;
  final int totalPages;

  const KitPageResult({
    required this.kits,
    required this.page,
    required this.size,
    required this.isLast,
    required this.totalPages,
  });
}

class KitService {
  final AuthApiClient _client = AuthApiClient();

  Future<List<KitModel>> getAllKits({int page = 0, int size = 10}) async {
    final result = await getAllKitsPage(page: page, size: size);
    return result.kits;
  }

  Future<KitPageResult> getAllKitsPage({
    int page = 0,
    int size = 10,
  }) async {
    final uri = Uri.parse('${ApiConstants.kits}/').replace(
      queryParameters: {
        'page': page.toString(),
        'size': size.toString(),
      },
    );

    final response = await _client.get(uri);

    return _parseKitPageResponse(
      response,
      fallbackError: 'Failed to load kits',
      fallbackPage: page,
      fallbackSize: size,
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

    throw Exception(
      _extractErrorMessage(response.body, 'Failed to load mindsets'),
    );
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
    final result = await getKitsByTypePage(type);
    return result.kits;
  }

  Future<KitPageResult> getKitsByTypePage(
      String type, {
        int page = 0,
        int size = 10,
      }) async {
    final uri = Uri.parse('${ApiConstants.kitsByType}/$type').replace(
      queryParameters: {
        'page': page.toString(),
        'size': size.toString(),
      },
    );

    final response = await _client.get(uri);

    return _parseKitPageResponse(
      response,
      fallbackError: 'Failed to load kits by type',
      fallbackPage: page,
      fallbackSize: size,
    );
  }

  Future<List<KitModel>> searchKits(String keyword) async {
    final result = await searchKitsPage(keyword);
    return result.kits;
  }

  Future<KitPageResult> searchKitsPage(
      String keyword, {
        int page = 0,
        int size = 10,
      }) async {
    final uri = Uri.parse(ApiConstants.kitsSearch).replace(
      queryParameters: {
        'keyword': keyword,
        'page': page.toString(),
        'size': size.toString(),
      },
    );

    final response = await _client.get(uri);

    return _parseKitPageResponse(
      response,
      fallbackError: 'Failed to search kits',
      fallbackPage: page,
      fallbackSize: size,
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

  KitPageResult _parseKitPageResponse(
      http.Response response, {
        required String fallbackError,
        required int fallbackPage,
        required int fallbackSize,
      }) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body);
      final data = _extractList(body);

      if (data == null) {
        throw Exception('Unexpected kits response format');
      }

      final kits = data
          .whereType<Map<String, dynamic>>()
          .map(KitModel.fromJson)
          .toList();

      final pageContainer = _extractPageContainer(body);

      if (pageContainer == null) {
        return KitPageResult(
          kits: kits,
          page: fallbackPage,
          size: fallbackSize,
          isLast: true,
          totalPages: fallbackPage + 1,
        );
      }

      final page = _parseInt(pageContainer['number'], fallbackPage);
      final size = _parseInt(pageContainer['size'], fallbackSize);
      final totalPages = _parseInt(pageContainer['totalPages'], page + 1);
      final isLastFromApi = pageContainer['last'] == true;

      final isLast =
          isLastFromApi || totalPages <= 0 || page >= totalPages - 1;

      return KitPageResult(
        kits: kits,
        page: page,
        size: size,
        isLast: isLast,
        totalPages: totalPages,
      );
    }

    throw Exception(_extractErrorMessage(response.body, fallbackError));
  }

  Map<String, dynamic>? _extractPageContainer(dynamic body) {
    if (body is! Map<String, dynamic>) return null;

    if (_looksLikePage(body)) {
      return body;
    }

    final possibleContainers = [
      body['data'],
      body['result'],
      body['kits'],
      body['items'],
    ];

    for (final container in possibleContainers) {
      if (container is Map<String, dynamic> && _looksLikePage(container)) {
        return container;
      }
    }

    return null;
  }

  bool _looksLikePage(Map<String, dynamic> value) {
    return value['content'] is List ||
        value.containsKey('number') ||
        value.containsKey('totalPages') ||
        value.containsKey('last');
  }

  List<dynamic>? _extractList(dynamic body) {
    if (body is List) return body;

    if (body is Map<String, dynamic>) {
      final dynamic directData = body['data'] ??
          body['content'] ??
          body['kits'] ??
          body['result'] ??
          body['items'];

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

  int _parseInt(dynamic value, int fallback) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? fallback;
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

  Future<int> getActivitiesCountByKitId(int kitId) async {
    final response = await _client.get(
      Uri.parse('${ApiConstants.baseUrl}/activities/kit/$kitId'),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body);

      if (body is Map<String, dynamic>) {
        final totalElements = body['totalElements'];

        if (totalElements is int) {
          return totalElements;
        }

        final content = body['content'];

        if (content is List) {
          return content.length;
        }
      }

      throw Exception('Unexpected activities response format');
    }

    throw Exception(
      _extractErrorMessage(response.body, 'Failed to load kit activities'),
    );
  }
}