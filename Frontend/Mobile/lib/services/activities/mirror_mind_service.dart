import 'dart:convert';

import '../../core/config/api_constants.dart';
import '../../models/activities/mirror_mind/mirror_mind_level_model.dart';
import '../auth/auth_api_client.dart';

class MirrorMindService {
  final AuthApiClient _apiClient = AuthApiClient();

  Map<String, String> get _jsonHeaders => {
    'Content-Type': 'application/json',
  };

  Future<int> getSelectedChildId() async {
    final response = await _apiClient.get(
      Uri.parse(ApiConstants.selectedChild),
    );

    _ensureSuccess(response.statusCode, response.body, 'get selected child');

    final data = jsonDecode(response.body);

    final childId = _readInt(data, ['id', 'childId']);

    if (childId == 0) {
      throw Exception('Selected child id was not found.');
    }

    return childId;
  }

  Future<Map<String, dynamic>?> getLatestSessionForChild(int childId) async {
    final uri = Uri.parse(ApiConstants.sessionsByChild(childId)).replace(
      queryParameters: {
        'page': '0',
        'size': '1',
        'sort': 'createdAt,desc',
      },
    );

    final response = await _apiClient.get(uri);

    _ensureSuccess(response.statusCode, response.body, 'get latest session');

    final data = jsonDecode(response.body);

    final content = data is Map ? data['content'] : null;

    if (content is! List || content.isEmpty) {
      return null;
    }

    final firstSession = content.first;

    if (firstSession is! Map) {
      return null;
    }

    return Map<String, dynamic>.from(firstSession);
  }

  Future<int> createSession({
    required int childId,
    required int kitId,
  }) async {
    final body = jsonEncode({
      'childId': childId,
      'kitId': kitId,
    });

    print('MIRROR MIND: create session body = $body');

    final response = await _apiClient.post(
      Uri.parse(ApiConstants.sessions),
      headers: _jsonHeaders,
      body: body,
    );

    print(
      'MIRROR MIND: create session response = '
          '${response.statusCode} - ${response.body}',
    );

    _ensureSuccess(
      response.statusCode,
      response.body,
      'create session',
    );

    final data = jsonDecode(response.body);

    final sessionId = _readInt(data, ['id', 'sessionId']);

    if (sessionId == 0) {
      throw Exception('Created session id was not found.');
    }

    return sessionId;
  }

  Future<List<Map<String, dynamic>>> getRoadmapActivities({
    required int kitId,
    required int childId,
  }) async {
    final response = await _apiClient.get(
      Uri.parse(ApiConstants.roadmapByKitAndChild(kitId, childId)),
    );

    _ensureSuccess(response.statusCode, response.body, 'get roadmap');

    final data = jsonDecode(response.body);

    if (data is List) {
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (data is Map && data['activities'] is List) {
      return (data['activities'] as List)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    if (data is Map && data['content'] is List) {
      return (data['content'] as List)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    }

    return <Map<String, dynamic>>[];
  }

  Map<String, dynamic>? findCurrentActivity(
      List<Map<String, dynamic>> activities,
      ) {
    if (activities.isEmpty) return null;

    for (final activity in activities) {
      final status = (activity['status'] ?? '').toString().toUpperCase();

      if (status == 'CURRENT') {
        return activity;
      }
    }

    return activities.first;
  }

  Future<int> createActivitySession({
    required int activityId,
    required int sessionId,
  }) async {
    final body = jsonEncode({
      'orderIndex': activityId,
      'activityId': activityId,
      'sessionId': sessionId,
    });

    print('MIRROR MIND: create activity session body = $body');

    final response = await _apiClient.post(
      Uri.parse(ApiConstants.activitySessions),
      headers: _jsonHeaders,
      body: body,
    );

    print(
      'MIRROR MIND: create activity session response = '
          '${response.statusCode} - ${_shortBody(response.body)}',
    );

    _ensureSuccess(
      response.statusCode,
      response.body,
      'create activity session',
    );

    final activitySessionId = _extractIdFromBody(response.body);

    if (activitySessionId == 0) {
      throw Exception('Activity session id was not found.');
    }

    return activitySessionId;
  }

  Future<List<MirrorMindLevelModel>> getLevelsByActivity(int activityId) async {
    final uri = Uri.parse(ApiConstants.levelsByActivity(activityId)).replace(
      queryParameters: {
        'page': '0',
        'size': '100',
        'sort': 'levelNumber,asc',
      },
    );

    final response = await _apiClient.get(uri);

    print(
      'MIRROR MIND: get levels response = '
          '${response.statusCode} - ${_shortBody(response.body)}',
    );

    _ensureSuccess(response.statusCode, response.body, 'get levels');

    try {
      final data = jsonDecode(response.body);

      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid levels response.');
      }

      final levels = MirrorMindLevelModel.listFromPageResponse(data);

      if (levels.isNotEmpty) {
        return levels;
      }

      print('MIRROR MIND: levels response is empty, using mock levels.');
      return _mockMirrorMindLevels();
    } catch (error) {
      print('MIRROR MIND: failed to parse levels response: $error');
      print('MIRROR MIND: using mock levels for frontend testing.');

      return _mockMirrorMindLevels();
    }
  }

  Future<int> createLevelAttempt({
    required int attemptNumber,
    required int activitySessionId,
    required int levelId,
  }) async {
    final now = DateTime.now().toIso8601String();

    final body = jsonEncode({
      'attemptNumber': attemptNumber,
      'startedAt': now,
      'endedAt': now,
      'completed': false,
      'activitySessionId': activitySessionId,
      'levelId': levelId,
    });

    print('MIRROR MIND: create level attempt body = $body');

    try {
      final response = await _apiClient
          .post(
        Uri.parse(ApiConstants.levelAttempts),
        headers: _jsonHeaders,
        body: body,
      )
          .timeout(const Duration(seconds: 8));

      print(
        'MIRROR MIND: create level attempt response = '
            '${response.statusCode} - ${_shortBody(response.body)}',
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final attemptId = _extractIdFromBody(response.body);

        if (attemptId != 0) {
          return attemptId;
        }
      }

      print(
        'MIRROR MIND: level attempt failed, using local test attempt id.',
      );

      return -attemptNumber;
    } catch (error) {
      print('MIRROR MIND: level attempt request error/timeout: $error');

      return -attemptNumber;
    }
  }

  Future<void> updateLevelAttempt({
    required int attemptId,
    required bool completed,
  }) async {
    // TEMPORARY TESTING FALLBACK:
    // If attempt id is local negative id, do not call backend.
    if (attemptId <= 0) {
      print(
        'MIRROR MIND: skipping update level attempt for local attemptId = $attemptId',
      );
      return;
    }

    final body = jsonEncode({
      'endedAt': DateTime.now().toIso8601String(),
      'completed': completed,
    });

    print('MIRROR MIND: update level attempt body = $body');

    try {
      final response = await _apiClient
          .put(
        Uri.parse(ApiConstants.levelAttemptById(attemptId)),
        headers: _jsonHeaders,
        body: body,
      )
          .timeout(const Duration(seconds: 8));

      print(
        'MIRROR MIND: update level attempt response = '
            '${response.statusCode} - ${_shortBody(response.body)}',
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return;
      }

      print(
        'MIRROR MIND: update level attempt failed, continuing frontend test.',
      );
    } catch (error) {
      print(
        'MIRROR MIND: update level attempt error/timeout, continuing frontend test: $error',
      );
    }
  }
  Future<void> postActivityEvent({
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
      'responseLanguage': 'en',
    });

    final response = await _apiClient.post(
      Uri.parse(ApiConstants.activityEvents),
      headers: _jsonHeaders,
      body: body,
    );

    _ensureSuccess(response.statusCode, response.body, 'post activity event');
  }

  Future<void> postLevelEvent({
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

    final response = await _apiClient.post(
      Uri.parse(ApiConstants.levelEvents),
      headers: _jsonHeaders,
      body: body,
    );

    _ensureSuccess(response.statusCode, response.body, 'post level event');
  }

  Future<void> completeActivitySession(int activitySessionId) async {
    final response = await _apiClient.put(
      Uri.parse(ApiConstants.activitySessionById(activitySessionId)),
      headers: _jsonHeaders,
    );

    _ensureSuccess(
      response.statusCode,
      response.body,
      'complete activity session',
    );
  }

  int readSessionId(Map<String, dynamic> session) {
    return _readInt(session, ['id', 'sessionId']);
  }

  int readKitId(Map<String, dynamic> session) {
    final directKitId = _readInt(session, ['kitId']);

    if (directKitId != 0) return directKitId;

    final kit = session['kit'];

    if (kit is Map) {
      return _readInt(kit, ['id', 'kitId']);
    }

    return 0;
  }

  int readActivityId(Map<String, dynamic> activity) {
    final directActivityId = _readInt(activity, ['id', 'activityId']);

    if (directActivityId != 0) return directActivityId;

    final nestedActivity = activity['activity'];

    if (nestedActivity is Map) {
      return _readInt(nestedActivity, ['id', 'activityId']);
    }

    return 0;
  }

  List<MirrorMindLevelModel> _mockMirrorMindLevels() {
    return [
      MirrorMindLevelModel.fromJson({
        'id': 1,
        'levelNumber': 1,
        'name': 'انعكاس بسيط',
        'items': [
          {
            'sortOrder': 1,
            'meta': {
              'challengeId': 1,
              'target': 'triangle',
            },
          },
          {
            'sortOrder': 2,
            'meta': {
              'challengeId': 1,
              'choices': [
                {'icon': 'triangle', 'isCorrect': true},
                {'icon': 'circle', 'isCorrect': false},
                {'icon': 'square', 'isCorrect': false},
              ],
            },
          },
          {
            'sortOrder': 3,
            'meta': {
              'challengeId': 2,
              'target': 'circle',
            },
          },
          {
            'sortOrder': 4,
            'meta': {
              'challengeId': 2,
              'choices': [
                {'icon': 'star', 'isCorrect': false},
                {'icon': 'circle', 'isCorrect': true},
                {'icon': 'square', 'isCorrect': false},
              ],
            },
          },
          {
            'sortOrder': 5,
            'meta': {
              'challengeId': 3,
              'target': 'square',
            },
          },
          {
            'sortOrder': 6,
            'meta': {
              'challengeId': 3,
              'choices': [
                {'icon': 'triangle', 'isCorrect': false},
                {'icon': 'star', 'isCorrect': false},
                {'icon': 'square', 'isCorrect': true},
              ],
            },
          },
          {
            'sortOrder': 7,
            'meta': {
              'challengeId': 4,
              'target': 'star',
            },
          },
          {
            'sortOrder': 8,
            'meta': {
              'challengeId': 4,
              'choices': [
                {'icon': 'triangle', 'isCorrect': false},
                {'icon': 'circle', 'isCorrect': false},
                {'icon': 'star', 'isCorrect': true},
              ],
            },
          },
        ],
      }),
      MirrorMindLevelModel.fromJson({
        'id': 2,
        'levelNumber': 2,
        'name': 'عدة أشكال',
        'items': [
          {
            'sortOrder': 1,
            'meta': {
              'challengeId': 1,
              'left': ['triangle', 'circle'],
              'expectedRight': ['circle', 'triangle'],
            },
          },
          {
            'sortOrder': 2,
            'meta': {
              'challengeId': 1,
              'choices': [
                {
                  'icons': ['triangle', 'circle'],
                  'isCorrect': false,
                },
                {
                  'icons': ['circle', 'triangle'],
                  'isCorrect': true,
                },
                {
                  'icons': ['square', 'circle'],
                  'isCorrect': false,
                },
              ],
            },
          },
          {
            'sortOrder': 3,
            'meta': {
              'challengeId': 2,
              'left': ['square', 'triangle', 'circle'],
              'expectedRight': ['circle', 'triangle', 'square'],
            },
          },
          {
            'sortOrder': 4,
            'meta': {
              'challengeId': 2,
              'choices': [
                {
                  'icons': ['square', 'triangle', 'circle'],
                  'isCorrect': false,
                },
                {
                  'icons': ['circle', 'triangle', 'square'],
                  'isCorrect': true,
                },
                {
                  'icons': ['triangle', 'circle', 'square'],
                  'isCorrect': false,
                },
              ],
            },
          },
          {
            'sortOrder': 5,
            'meta': {
              'challengeId': 3,
              'left': ['fish', 'star'],
              'expectedRight': ['star', 'fish'],
            },
          },
          {
            'sortOrder': 6,
            'meta': {
              'challengeId': 3,
              'choices': [
                {
                  'icons': ['fish', 'star'],
                  'isCorrect': false,
                },
                {
                  'icons': ['star', 'fish'],
                  'isCorrect': true,
                },
                {
                  'icons': ['fish', 'circle'],
                  'isCorrect': false,
                },
              ],
            },
          },
          {
            'sortOrder': 7,
            'meta': {
              'challengeId': 4,
              'left': ['apple', 'banana'],
              'expectedRight': ['banana', 'apple'],
            },
          },
          {
            'sortOrder': 8,
            'meta': {
              'challengeId': 4,
              'choices': [
                {
                  'icons': ['apple', 'banana'],
                  'isCorrect': false,
                },
                {
                  'icons': ['banana', 'apple'],
                  'isCorrect': true,
                },
                {
                  'icons': ['apple', 'star'],
                  'isCorrect': false,
                },
              ],
            },
          },
        ],
      }),
      MirrorMindLevelModel.fromJson({
        'id': 3,
        'levelNumber': 3,
        'name': 'اليمين واليسار',
        'items': [
          {
            'sortOrder': 1,
            'meta': {
              'challengeId': 1,
              'sequence': ['arrow_left'],
              'expectedNext': ['arrow_right'],
            },
          },
          {
            'sortOrder': 2,
            'meta': {
              'challengeId': 1,
              'choices': [
                {'icon': 'arrow_left', 'isCorrect': false},
                {'icon': 'arrow_up', 'isCorrect': false},
                {'icon': 'arrow_right', 'isCorrect': true},
              ],
            },
          },
          {
            'sortOrder': 3,
            'meta': {
              'challengeId': 2,
              'sequence': ['arrow_right'],
              'expectedNext': ['arrow_left'],
            },
          },
          {
            'sortOrder': 4,
            'meta': {
              'challengeId': 2,
              'choices': [
                {'icon': 'arrow_right', 'isCorrect': false},
                {'icon': 'arrow_left', 'isCorrect': true},
                {'icon': 'arrow_down', 'isCorrect': false},
              ],
            },
          },
          {
            'sortOrder': 5,
            'meta': {
              'challengeId': 3,
              'sequence': ['arrow_up_left'],
              'expectedNext': ['arrow_up_right'],
            },
          },
          {
            'sortOrder': 6,
            'meta': {
              'challengeId': 3,
              'choices': [
                {'icon': 'arrow_up_left', 'isCorrect': false},
                {'icon': 'arrow_up_right', 'isCorrect': true},
                {'icon': 'arrow_down_left', 'isCorrect': false},
              ],
            },
          },
          {
            'sortOrder': 7,
            'meta': {
              'challengeId': 4,
              'sequence': ['arrow_down_right'],
              'expectedNext': ['arrow_down_left'],
            },
          },
          {
            'sortOrder': 8,
            'meta': {
              'challengeId': 4,
              'choices': [
                {'icon': 'arrow_down_right', 'isCorrect': false},
                {'icon': 'arrow_down_left', 'isCorrect': true},
                {'icon': 'arrow_up_right', 'isCorrect': false},
              ],
            },
          },
        ],
      }),
    ];
  }

  int _extractIdFromBody(String body) {
    final match = RegExp(r'"id"\s*:\s*(\d+)').firstMatch(body);

    if (match == null) return 0;

    return int.tryParse(match.group(1) ?? '') ?? 0;
  }

  int _readInt(dynamic source, List<String> keys) {
    if (source is! Map) return 0;

    for (final key in keys) {
      final value = source[key];

      if (value is int) return value;

      final parsed = int.tryParse(value?.toString() ?? '');

      if (parsed != null) return parsed;
    }

    return 0;
  }

  String _shortBody(String body) {
    if (body.length <= 800) return body;
    return '${body.substring(0, 800)}...';
  }

  void _ensureSuccess(int statusCode, String body, String actionName) {
    if (statusCode >= 200 && statusCode < 300) return;

    throw Exception(
      'Failed to $actionName. Status code: $statusCode. Body: $body',
    );
  }
}