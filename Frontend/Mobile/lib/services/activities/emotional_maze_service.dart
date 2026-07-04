import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/config/api_constants.dart';
import '../../models/activities/emotional_maze/emotional_maze_models.dart';
import '../auth/auth_api_client.dart';

/// API layer for Emotional Maze — mirrors CognitiveMazeService exactly (same
/// AuthApiClient pattern already used across every other activity service).
class EmotionalMazeService {
  final AuthApiClient _client = AuthApiClient();

  String _nowIso() => DateTime.now().toUtc().toIso8601String();

  // ───────────────────────────── Levels ──────────────────────────────────

  Future<List<EmotionalMazeLevel>> getLevels(int activityId) async {
    final url =
        '${ApiConstants.levelsByActivity(activityId)}?page=0&size=100&sort=levelNumber,asc';
    debugPrint('EMOTIONAL MAZE GET LEVELS: $url');

    final res = await _client.get(Uri.parse(url));
    debugPrint('EMOTIONAL MAZE LEVELS: ${res.statusCode} - ${res.body}');

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final decoded = jsonDecode(res.body);
      final List content = decoded is Map
          ? (decoded['content'] as List? ?? [])
          : (decoded as List? ?? []);
      return content
          .whereType<Map>()
          .map((e) =>
          EmotionalMazeLevel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    throw Exception('Failed to load levels: ${res.statusCode}');
  }

  // ──────────────────────────── Attempts ─────────────────────────────────

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
      'completed': false,
    };
    debugPrint('EMOTIONAL MAZE CREATE ATTEMPT: $body');

    final res = await _client.post(
      Uri.parse(ApiConstants.levelAttempts),
      body: jsonEncode(body),
    );
    debugPrint('EMOTIONAL MAZE ATTEMPT RESP: ${res.statusCode} - ${res.body}');

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final d = jsonDecode(res.body);
      if (d is Map && d['id'] != null) return _toInt(d['id']);
    }
    throw Exception('Failed to create attempt: ${res.statusCode}');
  }

  Future<void> updateLevelAttempt({
    required int attemptId,
    required bool completed,
  }) async {
    final body = {'endedAt': _nowIso(), 'completed': completed};
    await _client.put(
      Uri.parse(ApiConstants.updateLevelAttempt(attemptId)),
      body: jsonEncode(body),
    );
  }

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
      'responseLanguage': 'ar',
    };
    debugPrint('EMOTIONAL MAZE ACTIVITY EVENT: $body');
    await _client.post(
      Uri.parse(ApiConstants.eventsActivity),
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
    debugPrint('EMOTIONAL MAZE LEVEL EVENT: $body');
    await _client.post(
      Uri.parse(ApiConstants.eventsLevel),
      body: jsonEncode(body),
    );
  }

  // ──────────────────────── Activity Session ──────────────────────────────

  Future<void> completeActivitySession(int activitySessionId) async {
    await _client.put(
      Uri.parse(ApiConstants.updateActivitySession(activitySessionId)),
    );
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}