import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/config/api_constants.dart';
import '../../models/activities/bodily_maze/bodily_maze_models.dart';
import '../auth/auth_api_client.dart';

/// API layer for Bodily Maze — mirrors the Color Lab service exactly.
class BodilyMazeService {
  final AuthApiClient _client = AuthApiClient();

  String _nowIso() => DateTime.now().toUtc().toIso8601String();

  // ───────────────────────────── Levels ──────────────────────────────────

  Future<List<BodilyMazeLevel>> getLevels(int activityId) async {
    final url =
        '${ApiConstants.levelsByActivity(activityId)}?page=0&size=100&sort=levelNumber,asc';
    debugPrint('BODILY MAZE GET LEVELS: $url');

    final res = await _client.get(Uri.parse(url));
    debugPrint('BODILY MAZE LEVELS: ${res.statusCode} - ${res.body}');

    if (res.statusCode >= 200 && res.statusCode < 300) {
      final decoded = jsonDecode(res.body);
      final List content = decoded is Map
          ? (decoded['content'] as List? ?? [])
          : (decoded as List? ?? []);
      return content
          .whereType<Map>()
          .map((e) => BodilyMazeLevel.fromJson(Map<String, dynamic>.from(e)))
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
    debugPrint('BODILY MAZE CREATE ATTEMPT: $body');

    final res = await _client.post(
      Uri.parse(ApiConstants.levelAttempts),
      body: jsonEncode(body),
    );
    debugPrint('BODILY MAZE ATTEMPT RESP: ${res.statusCode} - ${res.body}');

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
    final body = {
      'endedAt': _nowIso(),
      'completed': completed,
    };

    debugPrint('BODILY MAZE UPDATE ATTEMPT: $body');

    final res = await _client.put(
      Uri.parse(ApiConstants.levelAttemptById(attemptId)),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    debugPrint(
      'BODILY MAZE UPDATE ATTEMPT RESP: ${res.statusCode} - ${res.body}',
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Failed to update attempt: ${res.statusCode} - ${res.body}');
    }
  }

  // ───────────────────────────── Events ──────────────────────────────────

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

    debugPrint('MAZE ACTIVITY EVENT: $body');

    final res = await _client.post(
      Uri.parse(ApiConstants.activityEvents),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    debugPrint('BODILY MAZE ACTIVITY EVENT RESP: ${res.statusCode} - ${res.body}');

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Failed to log activity event: ${res.statusCode} - ${res.body}');
    }
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

    debugPrint('MAZE LEVEL EVENT: $body');

    final res = await _client.post(
      Uri.parse(ApiConstants.levelEvents),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    debugPrint('BODILY MAZE LEVEL EVENT RESP: ${res.statusCode} - ${res.body}');

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Failed to log level event: ${res.statusCode} - ${res.body}');
    }
  }

  // ──────────────────────── Activity Session ──────────────────────────────

  Future<void> completeActivitySession(int activitySessionId) async {
    final res = await _client.put(
      Uri.parse(ApiConstants.activitySessionById(activitySessionId)),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    debugPrint(
      'MAZE COMPLETE ACTIVITY SESSION RESP: ${res.statusCode} - ${res.body}',
    );

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception(
        'Failed to complete activity session: ${res.statusCode} - ${res.body}',
      );
    }
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}
