import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/config/api_constants.dart';
import '../../models/activities/shape_creator/shape_creator_level_model.dart';
import '../auth/auth_api_client.dart';

/// Handles all Shape Creator gameplay API calls:
/// levels, attempts, events, and activity-session completion.
class ShapeCreatorService {
  final AuthApiClient _client = AuthApiClient();

  String _nowIso() {
    return DateTime.now().toUtc().toIso8601String().replaceFirst('Z', '');
  }

  String _normalizeIso(String value) {
    return value.trim().replaceFirst(RegExp(r'Z$'), '');
  }

  // ===================== LEVELS =====================

  /// GET /api/levels/activity/{activityId}?page=0&size=100&sort=levelNumber,asc
  Future<List<ShapeCreatorLevelModel>> getLevels(int activityId) async {
    final url =
        '${ApiConstants.levelsByActivity(activityId)}?page=0&size=100&sort=levelNumber,asc';

    debugPrint('SHAPE CREATOR GET LEVELS URL: $url');

    final response = await _client.get(Uri.parse(url));

    debugPrint('SHAPE CREATOR GET LEVELS RESPONSE: ${response.statusCode}');
    debugPrint('SHAPE CREATOR GET LEVELS BODY: ${response.body}');

    _ensureSuccess(
      response.statusCode,
      response.body,
      'Failed to load Shape Creator levels',
    );

    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      return ShapeCreatorLevelModel.listFromPageResponse(decoded);
    }

    if (decoded is Map) {
      return ShapeCreatorLevelModel.listFromPageResponse(
        Map<String, dynamic>.from(decoded),
      );
    }

    return <ShapeCreatorLevelModel>[];
  }

  // ===================== LEVEL ATTEMPTS =====================

  /// POST /api/level-attempts
  Future<ShapeCreatorAttemptInfo> createLevelAttempt({
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

    debugPrint('SHAPE CREATOR CREATE LEVEL ATTEMPT URL: $url');
    debugPrint('SHAPE CREATOR CREATE LEVEL ATTEMPT BODY: $body');

    final response = await _client.post(
      Uri.parse(url),
      body: jsonEncode(body),
    );

    debugPrint(
      'SHAPE CREATOR CREATE LEVEL ATTEMPT RESPONSE: ${response.statusCode} - ${response.body}',
    );

    _ensureSuccess(
      response.statusCode,
      response.body,
      'Failed to create Shape Creator level attempt',
    );

    final decoded = jsonDecode(response.body);

    if (decoded is Map && decoded['id'] != null) {
      return ShapeCreatorAttemptInfo(
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

    debugPrint('SHAPE CREATOR UPDATE LEVEL ATTEMPT URL: $url');
    debugPrint('SHAPE CREATOR UPDATE LEVEL ATTEMPT BODY: $body');

    final response = await _client.put(
      Uri.parse(url),
      body: jsonEncode(body),
    );

    debugPrint(
      'SHAPE CREATOR UPDATE LEVEL ATTEMPT RESPONSE: ${response.statusCode} - ${response.body}',
    );

    _ensureSuccess(
      response.statusCode,
      response.body,
      'Failed to update Shape Creator level attempt',
    );
  }

  // ===================== EVENTS =====================

  /// POST /api/events/activity
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

    debugPrint('SHAPE CREATOR ACTIVITY EVENT URL: $url');
    debugPrint('SHAPE CREATOR ACTIVITY EVENT BODY: $body');

    final response = await _client.post(
      Uri.parse(url),
      body: jsonEncode(body),
    );

    debugPrint(
      'SHAPE CREATOR ACTIVITY EVENT RESPONSE: ${response.statusCode} - ${response.body}',
    );

    _ensureSuccess(
      response.statusCode,
      response.body,
      'Failed to log Shape Creator activity event $action',
    );
  }

  /// POST /api/events/level
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

    debugPrint('SHAPE CREATOR LEVEL EVENT URL: $url');
    debugPrint('SHAPE CREATOR LEVEL EVENT BODY: $body');

    final response = await _client.post(
      Uri.parse(url),
      body: jsonEncode(body),
    );

    debugPrint(
      'SHAPE CREATOR LEVEL EVENT RESPONSE: ${response.statusCode} - ${response.body}',
    );

    _ensureSuccess(
      response.statusCode,
      response.body,
      'Failed to log Shape Creator level event $action',
    );
  }

  // ===================== ACTIVITY SESSION =====================

  /// PUT /api/activity-sessions/{activitySessionId}
  Future<void> completeActivitySession(int activitySessionId) async {
    final url = ApiConstants.updateActivitySession(activitySessionId);

    debugPrint('SHAPE CREATOR COMPLETE ACTIVITY SESSION URL: $url');

    final response = await _client.put(
      Uri.parse(url),
    );

    debugPrint(
      'SHAPE CREATOR COMPLETE ACTIVITY SESSION RESPONSE: ${response.statusCode} - ${response.body}',
    );

    _ensureSuccess(
      response.statusCode,
      response.body,
      'Failed to complete Shape Creator activity session',
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

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class ShapeCreatorAttemptInfo {
  final int id;
  final String startedAt;

  const ShapeCreatorAttemptInfo({
    required this.id,
    required this.startedAt,
  });
}