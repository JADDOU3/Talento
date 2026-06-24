import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/config/api_constants.dart';
import '../../models/empathy_mirror/empathy_mirror_models.dart';
import '../auth/auth_api_client.dart';

class EmpathyMirrorService {
  final AuthApiClient _client = AuthApiClient();

  String _now() => DateTime.now().toUtc().toIso8601String();

  // ─── Levels ───────────────────────────────────────────────────────────────

  Future<List<EmpathyMirrorLevel>> getLevels(int activityId) async {
    final url =
        '${ApiConstants.levelsByActivity(activityId)}?page=0&size=100&sort=levelNumber,asc';
    debugPrint('EMPATHY GET LEVELS: $url');

    final res = await _client.get(Uri.parse(url));
    debugPrint('EMPATHY LEVELS: ${res.statusCode} - ${res.body}');

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final decoded = jsonDecode(res.body);
      final List content = decoded is Map
          ? (decoded['content'] as List? ?? [])
          : (decoded as List? ?? []);
      return content
          .whereType<Map>()
          .map((e) =>
              EmpathyMirrorLevel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    throw Exception('Failed to load levels: ${res.statusCode}');
  }

  // ─── Level Attempts ────────────────────────────────────────────────────────

  Future<int> createLevelAttempt({
    required int attemptNumber,
    required int activitySessionId,
    required int levelId,
  }) async {
    final body = {
      'attemptNumber': attemptNumber,
      'startedAt': _now(),
      'activitySessionId': activitySessionId,
      'levelId': levelId,
      'completed': false,
    };
    debugPrint('EMPATHY CREATE ATTEMPT: $body');

    final res = await _client.post(
      Uri.parse(ApiConstants.levelAttempts),
      body: jsonEncode(body),
    );
    debugPrint('EMPATHY ATTEMPT RESP: ${res.statusCode} - ${res.body}');

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final d = jsonDecode(res.body);
      if (d is Map && d['id'] != null) return _int(d['id']);
    }
    throw Exception('Failed to create attempt: ${res.statusCode}');
  }

  Future<void> updateLevelAttempt({
    required int attemptId,
    required bool completed,
  }) async {
    final body = {'endedAt': _now(), 'completed': completed};
    await _client.put(
      Uri.parse(ApiConstants.levelAttemptById(attemptId)),
      body: jsonEncode(body),
    );
  }

  // ─── Events ────────────────────────────────────────────────────────────────

  Future<void> logActivityEvent({
    required int childId,
    required int sessionId,
    required int activityId,
    required String action,
  }) async {
    final body = {
      'childId': childId,
      'sessionId': sessionId,
      'activityId': activityId,
      'action': action,
      'responseLanguage': 'en',
    };
    debugPrint('EMPATHY ACTIVITY EVENT: $body');
    await _client.post(
      Uri.parse(ApiConstants.activityEvents),
      body: jsonEncode(body),
    );
  }

  Future<void> logLevelEvent({
    required int childId,
    required int sessionId,
    required int activitySessionId,
    required String action,
  }) async {
    final body = {
      'childId': childId,
      'sessionId': sessionId,
      'activitySessionId': activitySessionId,
      'action': action,
    };
    debugPrint('EMPATHY LEVEL EVENT: $body');
    await _client.post(
      Uri.parse(ApiConstants.levelEvents),
      body: jsonEncode(body),
    );
  }

  // ─── Activity Session ──────────────────────────────────────────────────────

  Future<void> completeActivitySession(int activitySessionId) async {
    await _client.put(
      Uri.parse(ApiConstants.activitySessionById(activitySessionId)),
    );
  }

  static int _int(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}
