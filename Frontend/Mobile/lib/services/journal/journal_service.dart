import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/api_constants.dart';
import '../../models/journal/journal_models.dart';
import '../auth/auth_api_client.dart';

class JournalService {
  final AuthApiClient _client = AuthApiClient();

  Future<int?> getSelectedChildId() async {
    final response = await _client.get(
      Uri.parse(ApiConstants.selectedChild),
    );

    if (response.statusCode == 404 || response.body.trim().isEmpty) {
      return null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = _decodeJson(response);

      final data = _unwrapObject(
        decoded,
        keys: [
          'data',
          'child',
          'selectedChild',
          'result',
        ],
      );

      if (data == null) return null;

      return _parseInt(data['id'] ?? data['childId']);
    }

    throw Exception(
      _extractErrorMessage(response.body, 'Failed to load selected child'),
    );
  }

  Future<AIReportModel?> getLatestReport(int childId) async {
    final response = await _client.get(
      Uri.parse(ApiConstants.aiReportLatest(childId)),
    );

    return _parseReportResponse(
      response,
      fallbackError: 'Failed to load latest report',
    );
  }

  Future<AIReportModel?> getReportByVersion(
      int childId,
      String version,
      ) async {
    final response = await _client.get(
      Uri.parse(ApiConstants.aiReportByVersion(childId, version)),
    );

    return _parseReportResponse(
      response,
      fallbackError: 'Failed to load report version',
    );
  }

  Future<List<DailySessionModel>> getWeeklySessions() async {
    final response = await _client.get(
      Uri.parse(ApiConstants.aiReportsWeeklySessions),
    );

    final list = _parseListResponse(
      response,
      fallbackError: 'Failed to load weekly sessions',
      listKeys: [
        'data',
        'weeklySessions',
        'sessions',
        'items',
        'result',
      ],
    );

    return list.map(DailySessionModel.fromJson).toList();
  }

  Future<List<PerformanceModel>> getPerformances(int childId) async {
    final url = ApiConstants.performanceByChild(childId);

    // ignore: avoid_print
    print('Journal performances URL: $url');

    final response = await _client.get(
      Uri.parse(url),
    );

    // ignore: avoid_print
    print('Journal performances status: ${response.statusCode}');

    // ignore: avoid_print
    print('Journal performances body: ${utf8.decode(response.bodyBytes)}');

    final list = _parseListResponse(
      response,
      fallbackError: 'Failed to load performances',
      listKeys: [
        'data',
        'performances',
        'performance',
        'activityPerformances',
        'childPerformances',
        'items',
        'content',
        'result',
      ],
    );

    // ignore: avoid_print
    print('Journal performances parsed count: ${list.length}');

    return list.map(PerformanceModel.fromJson).toList();
  }
  AIReportModel? _parseReportResponse(
      http.Response response, {
        required String fallbackError,
      }) {
    if (response.statusCode == 404 || response.body.trim().isEmpty) {
      return null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = _decodeJson(response);

      if (decoded == null) return null;

      final data = _unwrapObject(
        decoded,
        keys: [
          'data',
          'report',
          'aiReport',
          'result',
        ],
      );

      if (data == null) return null;

      return AIReportModel.fromJson(data);
    }

    throw Exception(_extractErrorMessage(response.body, fallbackError));
  }

  List<Map<String, dynamic>> _parseListResponse(
      http.Response response, {
        required String fallbackError,
        required List<String> listKeys,
      }) {
    if (response.statusCode == 404 || response.body.trim().isEmpty) {
      return [];
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = _decodeJson(response);
      return _extractList(decoded, listKeys);
    }

    throw Exception(_extractErrorMessage(response.body, fallbackError));
  }

  List<Map<String, dynamic>> _extractList(
      dynamic decoded,
      List<String> keys,
      ) {
    if (decoded is List) {
      return _mapList(decoded);
    }

    if (decoded is Map<String, dynamic>) {
      for (final key in keys) {
        final value = decoded[key];

        if (value is List) {
          return _mapList(value);
        }

        if (value is Map<String, dynamic>) {
          final nested = _extractList(value, keys);
          if (nested.isNotEmpty) return nested;
        }
      }

      for (final value in decoded.values) {
        if (value is List) {
          final mapped = _mapList(value);
          if (mapped.isNotEmpty) return mapped;
        }

        if (value is Map<String, dynamic>) {
          final nested = _extractList(value, keys);
          if (nested.isNotEmpty) return nested;
        }
      }
    }

    return [];
  }

  Map<String, dynamic>? _unwrapObject(
      dynamic decoded, {
        required List<String> keys,
      }) {
    if (decoded == null) return null;

    if (decoded is Map<String, dynamic>) {
      for (final key in keys) {
        if (!decoded.containsKey(key)) continue;

        final value = decoded[key];

        if (value == null) return null;

        if (value is Map) {
          return Map<String, dynamic>.from(value);
        }
      }

      return decoded;
    }

    return null;
  }

  List<Map<String, dynamic>> _mapList(List<dynamic> list) {
    return list
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  dynamic _decodeJson(http.Response response) {
    final decodedBody = utf8.decode(response.bodyBytes).trim();

    if (decodedBody.isEmpty) {
      return null;
    }

    return jsonDecode(decodedBody);
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
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