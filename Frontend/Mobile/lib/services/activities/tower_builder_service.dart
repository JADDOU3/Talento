import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/config/api_constants.dart';
import '../../models/activities/tower_builder/tower_builder_level_model.dart';
import '../auth/auth_api_client.dart';

/// Handles all Tower Builder gameplay API calls:
/// levels, attempts, events, and activity-session completion.
class TowerBuilderService {
  final AuthApiClient _client = AuthApiClient();

  String _nowIso() {
    return DateTime.now().toUtc().toIso8601String().replaceFirst('Z', '');
  }

  String _normalizeIso(String value) {
    return value.trim().replaceFirst(RegExp(r'Z$'), '');
  }

  // ===================== LEVELS =====================

  /// GET /api/levels/activity/{activityId}?page=0&size=100&sort=levelNumber,asc
  Future<List<TowerBuilderLevelModel>> getLevels(int activityId) async {
    final url =
        '${ApiConstants.levelsByActivity(activityId)}?page=0&size=100&sort=levelNumber,asc';

    debugPrint('TOWER BUILDER GET LEVELS URL: $url');

    final response = await _client.get(Uri.parse(url));

    debugPrint('TOWER BUILDER GET LEVELS RESPONSE: ${response.statusCode}');
    debugPrint('TOWER BUILDER GET LEVELS BODY: ${response.body}');

    _ensureSuccess(
      response.statusCode,
      response.body,
      'Failed to load Tower Builder levels',
    );

    final decoded = jsonDecode(response.body);

    if (decoded is Map<String, dynamic>) {
      return TowerBuilderLevelModel.listFromPageResponse(decoded);
    }

    if (decoded is Map) {
      return TowerBuilderLevelModel.listFromPageResponse(
        Map<String, dynamic>.from(decoded),
      );
    }

    return <TowerBuilderLevelModel>[];
  }

  // ===================== LEVEL ATTEMPTS =====================

  /// POST /api/level-attempts
  Future<TowerBuilderAttemptInfo> createLevelAttempt({
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

    debugPrint('TOWER BUILDER CREATE LEVEL ATTEMPT URL: $url');
    debugPrint('TOWER BUILDER CREATE LEVEL ATTEMPT BODY: $body');

    final response = await _client.post(
      Uri.parse(url),
      body: jsonEncode(body),
    );

    debugPrint(
      'TOWER BUILDER CREATE LEVEL ATTEMPT RESPONSE: ${response.statusCode} - ${response.body}',
    );

    _ensureSuccess(
      response.statusCode,
      response.body,
      'Failed to create Tower Builder level attempt',
    );

    final decoded = jsonDecode(response.body);

    if (decoded is Map && decoded['id'] != null) {
      return TowerBuilderAttemptInfo(
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

    debugPrint('TOWER BUILDER UPDATE LEVEL ATTEMPT URL: $url');
    debugPrint('TOWER BUILDER UPDATE LEVEL ATTEMPT BODY: $body');

    final response = await _client.put(
      Uri.parse(url),
      body: jsonEncode(body),
    );

    debugPrint(
      'TOWER BUILDER UPDATE LEVEL ATTEMPT RESPONSE: ${response.statusCode} - ${response.body}',
    );

    _ensureSuccess(
      response.statusCode,
      response.body,
      'Failed to update Tower Builder level attempt',
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

    debugPrint('TOWER BUILDER ACTIVITY EVENT URL: $url');
    debugPrint('TOWER BUILDER ACTIVITY EVENT BODY: $body');

    final response = await _client.post(
      Uri.parse(url),
      body: jsonEncode(body),
    );

    debugPrint(
      'TOWER BUILDER ACTIVITY EVENT RESPONSE: ${response.statusCode} - ${response.body}',
    );

    _ensureSuccess(
      response.statusCode,
      response.body,
      'Failed to log Tower Builder activity event $action',
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

    debugPrint('TOWER BUILDER LEVEL EVENT URL: $url');
    debugPrint('TOWER BUILDER LEVEL EVENT BODY: $body');

    final response = await _client.post(
      Uri.parse(url),
      body: jsonEncode(body),
    );

    debugPrint(
      'TOWER BUILDER LEVEL EVENT RESPONSE: ${response.statusCode} - ${response.body}',
    );

    _ensureSuccess(
      response.statusCode,
      response.body,
      'Failed to log Tower Builder level event $action',
    );
  }

  // ===================== ACTIVITY SESSION =====================

  /// PUT /api/activity-sessions/{activitySessionId}
  Future<void> completeActivitySession(int activitySessionId) async {
    final url = ApiConstants.updateActivitySession(activitySessionId);

    debugPrint('TOWER BUILDER COMPLETE ACTIVITY SESSION URL: $url');

    final response = await _client.put(
      Uri.parse(url),
    );

    debugPrint(
      'TOWER BUILDER COMPLETE ACTIVITY SESSION RESPONSE: ${response.statusCode} - ${response.body}',
    );

    _ensureSuccess(
      response.statusCode,
      response.body,
      'Failed to complete Tower Builder activity session',
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

class TowerBuilderAttemptInfo {
  final int id;
  final String startedAt;

  const TowerBuilderAttemptInfo({
    required this.id,
    required this.startedAt,
  });
}