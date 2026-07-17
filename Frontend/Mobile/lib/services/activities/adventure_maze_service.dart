import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/config/api_constants.dart';
import '../../models/activities/adventure_maze/adventure_maze_models.dart';
import '../auth/auth_api_client.dart';

/// API layer for Adventure Maze.
class AdventureMazeService {
  final AuthApiClient _client = AuthApiClient();

  Future<List<AdventureMazeLevel>> getLevels(int activityId) async {
    final url =
        '${ApiConstants.levelsByActivity(activityId)}?page=0&size=100&sort=levelNumber,asc';

    debugPrint('ADVENTURE MAZE GET LEVELS: $url');

    final response = await _client.get(Uri.parse(url));

    debugPrint(
      'ADVENTURE MAZE LEVELS RESP: '
          '${response.statusCode} - ${response.body}',
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);

      final List<dynamic> content = decoded is Map
          ? (decoded['content'] as List<dynamic>? ?? <dynamic>[])
          : (decoded as List<dynamic>? ?? <dynamic>[]);

      return content
          .whereType<Map>()
          .map(
            (item) => AdventureMazeLevel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();
    }

    throw Exception(
      'Failed to load levels: '
          '${response.statusCode} - ${response.body}',
    );
  }

  Future<int> createLevelAttempt({
    required int attemptNumber,
    required String startedAt,
    required int activitySessionId,
    required int levelId,
  }) async {
    final body = jsonEncode({
      'attemptNumber': attemptNumber,
      'startedAt': startedAt,
      'activitySessionId': activitySessionId,
      'levelId': levelId,
      'completed': false,
    });

    debugPrint('ADVENTURE MAZE CREATE ATTEMPT BODY: $body');

    final response = await _client.post(
      Uri.parse(ApiConstants.levelAttempts),
      headers: const {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    debugPrint(
      'ADVENTURE MAZE CREATE ATTEMPT RESP: '
          '${response.statusCode} - ${response.body}',
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);

      if (decoded is Map && decoded['id'] != null) {
        final attemptId = _toInt(decoded['id']);

        if (attemptId > 0) {
          return attemptId;
        }
      }

      throw Exception('Created level attempt id was not found');
    }

    throw Exception(
      'Failed to create attempt: '
          '${response.statusCode} - ${response.body}',
    );
  }

  Future<void> updateLevelAttempt({
    required int attemptId,
    required int attemptNumber,
    required String startedAt,
    required int activitySessionId,
    required int levelId,
    required bool completed,
  }) async {
    final body = jsonEncode({
      'attemptNumber': attemptNumber,
      'startedAt': startedAt,
      'endedAt': DateTime.now().toUtc().toIso8601String(),
      'completed': completed,
      'activitySessionId': activitySessionId,
      'levelId': levelId,
    });

    debugPrint('ADVENTURE MAZE UPDATE ATTEMPT BODY: $body');

    final response = await _client.put(
      Uri.parse(ApiConstants.levelAttemptById(attemptId)),
      headers: const {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    debugPrint(
      'ADVENTURE MAZE UPDATE ATTEMPT RESP: '
          '${response.statusCode} - ${response.body}',
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to update attempt: '
            '${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> logActivityEvent({
    required int childId,
    required int sessionId,
    required int activityId,
    required String action,
  }) async {
    final body = jsonEncode({
      'childId': childId,
      'sessionId': sessionId,
      'activityId': activityId,
      'action': action,
      'responseLanguage': 'ar',
    });

    debugPrint('ADVENTURE MAZE ACTIVITY EVENT BODY: $body');

    final response = await _client.post(
      Uri.parse(ApiConstants.activityEvents),
      headers: const {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    debugPrint(
      'ADVENTURE MAZE ACTIVITY EVENT RESP: '
          '${response.statusCode} - ${response.body}',
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to log activity event: '
            '${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> logLevelEvent({
    required int childId,
    required int sessionId,
    required int activitySessionId,
    required String action,
  }) async {
    final body = jsonEncode({
      'childId': childId,
      'sessionId': sessionId,
      'activitySessionId': activitySessionId,
      'action': action,
    });

    debugPrint('ADVENTURE MAZE LEVEL EVENT BODY: $body');

    final response = await _client.post(
      Uri.parse(ApiConstants.levelEvents),
      headers: const {
        'Content-Type': 'application/json',
      },
      body: body,
    );

    debugPrint(
      'ADVENTURE MAZE LEVEL EVENT RESP: '
          '${response.statusCode} - ${response.body}',
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to log level event: '
            '${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<void> completeActivitySession(int activitySessionId) async {
    final response = await _client.put(
      Uri.parse(ApiConstants.activitySessionById(activitySessionId)),
      headers: const {
        'Content-Type': 'application/json',
      },
    );

    debugPrint(
      'ADVENTURE MAZE COMPLETE ACTIVITY SESSION RESP: '
          '${response.statusCode} - ${response.body}',
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Failed to complete activity session: '
            '${response.statusCode} - ${response.body}',
      );
    }
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
