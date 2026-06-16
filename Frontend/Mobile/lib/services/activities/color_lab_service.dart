import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/config/api_constants.dart';
import '../../models/color_lab/color_lab_models.dart';
import '../auth/auth_api_client.dart';

/// Handles all Color Lab gameplay API calls: levels, attempts, events,
/// and activity-session completion. Uses AuthApiClient (auto token refresh).
class ColorLabService {
  final AuthApiClient _client = AuthApiClient();

  String _nowIso() => DateTime.now().toUtc().toIso8601String();

  // ===================== LEVELS =====================

  /// GET /api/levels/activity/{activityId}?page=0&size=100&sort=levelNumber,asc
  Future<List<ColorLabLevel>> getLevels(int activityId) async {
    final url =
        '${ApiConstants.levelsByActivity(activityId)}?page=0&size=100&sort=levelNumber,asc';

    debugPrint('COLOR LAB GET LEVELS: $url');

    final response = await _client.get(Uri.parse(url));

    debugPrint('LEVELS RESPONSE: ${response.statusCode}');
    debugPrint('LEVELS BODY: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);

      // Paginated response → content list. Or plain list.
      final List content = decoded is Map
          ? (decoded['content'] as List? ?? [])
          : (decoded as List? ?? []);

      return content
          .whereType<Map>()
          .map((e) => ColorLabLevel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    throw Exception('Failed to load levels: ${response.statusCode}');
  }

  // ===================== LEVEL ATTEMPTS =====================

  /// POST /api/level-attempts → returns the new attempt id.
  Future<int> createLevelAttempt({
    required int attemptNumber,
    required int activitySessionId,
    required int levelId,
  }) async {
    final body = {
      'attemptNumber': attemptNumber,
      'startedAt': _nowIso(),
      'activitySessionId': activitySessionId,
      'levelId': levelId,
      'completed': false, // ✅ DB column is NOT NULL — must send a value
    };

    debugPrint('CREATE LEVEL ATTEMPT: $body');

    var response = await _client.post(
      Uri.parse(ApiConstants.levelAttempts),
      body: jsonEncode(body),
    );

    debugPrint(
        'CREATE ATTEMPT RESPONSE: ${response.statusCode} - ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['id'] != null) {
        return _toInt(decoded['id']);
      }
    }

    throw Exception('Failed to create level attempt: ${response.statusCode}');
  }

  /// PUT /api/level-attempts/{attemptId}
  Future<void> updateLevelAttempt({
    required int attemptId,
    required bool completed,
  }) async {
    final body = {
      'endedAt': _nowIso(),
      'completed': completed,
    };

    debugPrint('UPDATE LEVEL ATTEMPT $attemptId: $body');

    await _client.put(
      Uri.parse(ApiConstants.updateLevelAttempt(attemptId)),
      body: jsonEncode(body),
    );
  }

  // ===================== EVENTS =====================

  /// POST /api/events/activity — requires responseLanguage.
  Future<void> logActivityEvent({
    required int childId,
    required int sessionId,
    required int activityId,
    required String action, // STARTED | COMPLETED | ENDED
    String responseLanguage = 'en',
  }) async {
    final body = {
      'childId': childId,
      'sessionId': sessionId,
      'activityId': activityId,
      'action': action,
      'responseLanguage': responseLanguage,
    };

    debugPrint('ACTIVITY EVENT: $body');

    await _client.post(
      Uri.parse(ApiConstants.eventsActivity),
      body: jsonEncode(body),
    );
  }

  /// POST /api/events/level — requires activitySessionId (NOT activityId).
  Future<void> logLevelEvent({
    required int childId,
    required int sessionId,
    required int activitySessionId,
    required String action, // STARTED | COMPLETED | FAILED | RETRIED
  }) async {
    final body = {
      'childId': childId,
      'sessionId': sessionId,
      'activitySessionId': activitySessionId,
      'action': action,
    };

    debugPrint('LEVEL EVENT: $body');

    await _client.post(
      Uri.parse(ApiConstants.eventsLevel),
      body: jsonEncode(body),
    );
  }

  // ===================== ACTIVITY SESSION =====================

  /// PUT /api/activity-sessions/{activitySessionId} (no body) — marks complete.
  Future<void> completeActivitySession(int activitySessionId) async {
    debugPrint('COMPLETE ACTIVITY SESSION: $activitySessionId');

    await _client.put(
      Uri.parse(ApiConstants.updateActivitySession(activitySessionId)),
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}
