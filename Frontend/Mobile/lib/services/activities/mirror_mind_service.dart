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
      'activityId': activityId,
      'sessionId': sessionId,
      'startedAt': DateTime.now().toIso8601String(),
    });

    final response = await _apiClient.post(
      Uri.parse(ApiConstants.activitySessions),
      headers: _jsonHeaders,
      body: body,
    );

    _ensureSuccess(
      response.statusCode,
      response.body,
      'create activity session',
    );

    final data = jsonDecode(response.body);

    final activitySessionId = _readInt(data, ['id', 'activitySessionId']);

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

    _ensureSuccess(response.statusCode, response.body, 'get levels');

    final data = jsonDecode(response.body);

    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid levels response.');
    }

    return MirrorMindLevelModel.listFromPageResponse(data);
  }

  Future<int> createLevelAttempt({
    required int attemptNumber,
    required int activitySessionId,
    required int levelId,
  }) async {
    final body = jsonEncode({
      'attemptNumber': attemptNumber,
      'startedAt': DateTime.now().toIso8601String(),
      'activitySessionId': activitySessionId,
      'levelId': levelId,
    });

    final response = await _apiClient.post(
      Uri.parse(ApiConstants.levelAttempts),
      headers: _jsonHeaders,
      body: body,
    );

    _ensureSuccess(response.statusCode, response.body, 'create level attempt');

    final data = jsonDecode(response.body);

    final attemptId = _readInt(data, ['id', 'attemptId']);

    if (attemptId == 0) {
      throw Exception('Level attempt id was not found.');
    }

    return attemptId;
  }

  Future<void> updateLevelAttempt({
    required int attemptId,
    required bool completed,
  }) async {
    final body = jsonEncode({
      'endedAt': DateTime.now().toIso8601String(),
      'completed': completed,
    });

    final response = await _apiClient.put(
      Uri.parse(ApiConstants.levelAttemptById(attemptId)),
      headers: _jsonHeaders,
      body: body,
    );

    _ensureSuccess(response.statusCode, response.body, 'update level attempt');
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

  void _ensureSuccess(int statusCode, String body, String actionName) {
    if (statusCode >= 200 && statusCode < 300) return;

    throw Exception(
      'Failed to $actionName. Status code: $statusCode. Body: $body',
    );
  }
}