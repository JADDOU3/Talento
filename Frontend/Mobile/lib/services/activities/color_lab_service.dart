import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/config/api_constants.dart';
import '../../models/color_lab/color_lab_models.dart';
import '../auth/auth_api_client.dart';

/// Handles all Color Lab gameplay API calls: levels, attempts, events,
/// and activity-session completion. Uses AuthApiClient (auto token refresh).
class ColorLabService {
  final AuthApiClient _client = AuthApiClient();

  String _nowIso() {
    return DateTime.now().toUtc().toIso8601String().replaceFirst('Z', '');
  }

  String _normalizeIso(String value) {
    return value.trim().replaceFirst(RegExp(r'Z$'), '');
  }

  // ===================== LEVELS =====================

  /// GET /api/levels/activity/{activityId}?page=0&size=100&sort=levelNumber,asc
  Future<List<ColorLabLevel>> getLevels(int activityId) async {
    final url =
        '${ApiConstants.levelsByActivity(activityId)}?page=0&size=100&sort=levelNumber,asc';

    debugPrint('COLOR LAB GET LEVELS URL: $url');

    final response = await _client.get(Uri.parse(url));

    debugPrint('COLOR LAB GET LEVELS RESPONSE: ${response.statusCode}');
    debugPrint('COLOR LAB GET LEVELS BODY: ${response.body}');

    _ensureSuccess(
      response.statusCode,
      response.body,
      'Failed to load Color Lab levels',
    );

    final decoded = jsonDecode(response.body);

    final List content = decoded is Map
        ? (decoded['content'] as List? ?? [])
        : (decoded as List? ?? []);

    return content
        .whereType<Map>()
        .map((e) => ColorLabLevel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // ===================== LEVEL ATTEMPTS =====================

  /// POST /api/level-attempts → returns the new attempt info.
  Future<ColorLabAttemptInfo> createLevelAttempt({
    required int attemptNumber,
    required int activitySessionId,
    required int levelId,
  }) async {
    final url = ApiConstants.levelAttempts;
    final startedAt = _nowIso();

    final body = {
      'attemptNumber': attemptNumber,
      'startedAt': startedAt,
      'activitySessionId': activitySessionId,
      'levelId': levelId,
      'completed': false,
    };

    debugPrint('COLOR LAB CREATE LEVEL ATTEMPT URL: $url');
    debugPrint('COLOR LAB CREATE LEVEL ATTEMPT BODY: $body');

    final response = await _client.post(
      Uri.parse(url),
      body: jsonEncode(body),
    );

    debugPrint(
      'COLOR LAB CREATE LEVEL ATTEMPT RESPONSE: ${response.statusCode} - ${response.body}',
    );

    _ensureSuccess(
      response.statusCode,
      response.body,
      'Failed to create Color Lab level attempt',
    );

    final decoded = jsonDecode(response.body);

    if (decoded is Map && decoded['id'] != null) {
      return ColorLabAttemptInfo(
        id: _toInt(decoded['id']),
        startedAt: (decoded['startedAt'] ?? startedAt).toString(),
      );
    }

    throw Exception('Create level attempt succeeded but no attempt id returned');
  }

  /// PUT /api/level-attempts/{attemptId}
  Future<void> updateLevelAttempt({
    required int attemptId,
    required int attemptNumber,
    required String startedAt,
    required int activitySessionId,
    required int levelId,
    required bool completed,
  }) async {
    final url = ApiConstants.updateLevelAttempt(attemptId);

    final body = {
      'attemptNumber': attemptNumber,
      'startedAt': _normalizeIso(startedAt),
      'endedAt': _nowIso(),
      'completed': completed,
      'activitySessionId': activitySessionId,
      'levelId': levelId,
    };

    debugPrint('COLOR LAB UPDATE LEVEL ATTEMPT URL: $url');
    debugPrint('COLOR LAB UPDATE LEVEL ATTEMPT $attemptId BODY: $body');

    final response = await _client.put(
      Uri.parse(url),
      body: jsonEncode(body),
    );

    debugPrint(
      'COLOR LAB UPDATE LEVEL ATTEMPT RESPONSE: ${response.statusCode} - ${response.body}',
    );

    _ensureSuccess(
      response.statusCode,
      response.body,
      'Failed to update Color Lab level attempt',
    );
  }

  // ===================== EVENTS =====================

  /// POST /api/events/activity — requires responseLanguage.
  Future<void> logActivityEvent({
    required int childId,
    required int sessionId,
    required int activityId,
    required String action,
    String responseLanguage = 'en',
  }) async {
    final url = ApiConstants.eventsActivity;

    final body = {
      'childId': childId,
      'sessionId': sessionId,
      'activityId': activityId,
      'action': action,
      'responseLanguage': responseLanguage,
    };

    debugPrint('COLOR LAB ACTIVITY EVENT URL: $url');
    debugPrint('COLOR LAB ACTIVITY EVENT BODY: $body');

    final response = await _client.post(
      Uri.parse(url),
      body: jsonEncode(body),
    );

    debugPrint(
      'COLOR LAB ACTIVITY EVENT RESPONSE: ${response.statusCode} - ${response.body}',
    );

    _ensureSuccess(
      response.statusCode,
      response.body,
      'Failed to log Color Lab activity event $action',
    );
  }

  /// POST /api/events/level — requires activitySessionId.
  Future<void> logLevelEvent({
    required int childId,
    required int sessionId,
    required int activitySessionId,
    required String action,
  }) async {
    final url = ApiConstants.eventsLevel;

    final body = {
      'childId': childId,
      'sessionId': sessionId,
      'activitySessionId': activitySessionId,
      'action': action,
    };

    debugPrint('COLOR LAB LEVEL EVENT URL: $url');
    debugPrint('COLOR LAB LEVEL EVENT BODY: $body');

    final response = await _client.post(
      Uri.parse(url),
      body: jsonEncode(body),
    );

    debugPrint(
      'COLOR LAB LEVEL EVENT RESPONSE: ${response.statusCode} - ${response.body}',
    );

    _ensureSuccess(
      response.statusCode,
      response.body,
      'Failed to log Color Lab level event $action',
    );
  }

  // ===================== ACTIVITY SESSION =====================

  /// PUT /api/activity-sessions/{activitySessionId}
  Future<void> completeActivitySession(int activitySessionId) async {
    final url = ApiConstants.updateActivitySession(activitySessionId);

    debugPrint('COLOR LAB COMPLETE ACTIVITY SESSION URL: $url');
    debugPrint('COLOR LAB COMPLETE ACTIVITY SESSION ID: $activitySessionId');

    final response = await _client.put(
      Uri.parse(url),
    );

    debugPrint(
      'COLOR LAB COMPLETE ACTIVITY SESSION RESPONSE: ${response.statusCode} - ${response.body}',
    );

    _ensureSuccess(
      response.statusCode,
      response.body,
      'Failed to complete Color Lab activity session',
    );
  }

  // ===================== HELPERS =====================

  void _ensureSuccess(
      int statusCode,
      String body,
      String fallbackMessage,
      ) {
    if (statusCode >= 200 && statusCode < 300) return;

    final message = _extractErrorMessage(body, fallbackMessage);

    throw Exception('$message | statusCode=$statusCode | body=$body');
  }

  String _extractErrorMessage(String body, String fallback) {
    try {
      final decoded = jsonDecode(body);

      if (decoded is Map) {
        return (decoded['message'] ?? decoded['error'] ?? fallback).toString();
      }
    } catch (_) {}

    return body.trim().isEmpty ? fallback : body.trim();
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}

class ColorLabAttemptInfo {
  final int id;
  final String startedAt;

  const ColorLabAttemptInfo({
    required this.id,
    required this.startedAt,
  });
}