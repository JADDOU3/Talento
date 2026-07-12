import 'dart:convert';

import '../../core/config/api_constants.dart';
import '../../models/activities/creative_maze/creative_maze_level_model.dart';
import '../auth/auth_api_client.dart';

/// HTTP layer for Creative Maze. Mirrors SoundTrackerService exactly — same
/// endpoints, same AuthApiClient, same body shapes — so the maze plugs into
/// the identical attempt/event backend flow.
class CreativeMazeService {
  final AuthApiClient _apiClient = AuthApiClient();

  Map<String, String> get _jsonHeaders => {
    'Content-Type': 'application/json',
  };

  Future<List<CreativeMazeLevelModel>> getLevelsByActivity(
      int activityId,
      ) async {
    final uri = Uri.parse(ApiConstants.levelsByActivity(activityId)).replace(
      queryParameters: {
        'page': '0',
        'size': '100',
        'sort': 'levelNumber,asc',
      },
    );

    print('CREATIVE MAZE: get levels url = $uri');

    final response = await _apiClient.get(uri);

    print(
      'CREATIVE MAZE: get levels response = '
          '${response.statusCode} - ${_shortBody(response.body)}',
    );

    _ensureSuccess(response.statusCode, response.body, 'get levels');

    final data = jsonDecode(response.body);
    final levels = CreativeMazeLevelModel.listFromPageResponse(data);

    if (levels.isEmpty) {
      throw Exception('No Creative Maze levels were found.');
    }

    levels.sort((a, b) => a.levelNumber.compareTo(b.levelNumber));
    return levels;
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
      'endedAt': startedAt,
      'completed': false,
      'activitySessionId': activitySessionId,
      'levelId': levelId,
    });

    print('CREATIVE MAZE: create level attempt body = $body');

    final response = await _apiClient.post(
      Uri.parse(ApiConstants.levelAttempts),
      headers: _jsonHeaders,
      body: body,
    );

    print(
      'CREATIVE MAZE: create level attempt response = '
          '${response.statusCode} - ${_shortBody(response.body)}',
    );

    _ensureSuccess(
      response.statusCode,
      response.body,
      'create level attempt',
    );

    final data = jsonDecode(response.body);
    final attemptId = _readInt(data, ['id', 'attemptId']);

    if (attemptId == 0) {
      throw Exception('Level attempt id was not found.');
    }

    return attemptId;
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
      'endedAt': DateTime.now().toIso8601String(),
      'completed': completed,
      'activitySessionId': activitySessionId,
      'levelId': levelId,
    });

    print('CREATIVE MAZE: update level attempt body = $body');

    final response = await _apiClient.put(
      Uri.parse(ApiConstants.levelAttemptById(attemptId)),
      headers: _jsonHeaders,
      body: body,
    );

    print(
      'CREATIVE MAZE: update level attempt response = '
          '${response.statusCode} - ${_shortBody(response.body)}',
    );

    _ensureSuccess(
      response.statusCode,
      response.body,
      'update level attempt',
    );
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
      'responseLanguage': 'ar',
    });

    print('CREATIVE MAZE: post activity event body = $body');

    final response = await _apiClient.post(
      Uri.parse(ApiConstants.activityEvents),
      headers: _jsonHeaders,
      body: body,
    );

    print(
      'CREATIVE MAZE: post activity event response = '
          '${response.statusCode} - ${_shortBody(response.body)}',
    );

    _ensureSuccess(
      response.statusCode,
      response.body,
      'post activity event',
    );
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

    print('CREATIVE MAZE: post level event body = $body');

    final response = await _apiClient.post(
      Uri.parse(ApiConstants.levelEvents),
      headers: _jsonHeaders,
      body: body,
    );

    print(
      'CREATIVE MAZE: post level event response = '
          '${response.statusCode} - ${_shortBody(response.body)}',
    );

    _ensureSuccess(
      response.statusCode,
      response.body,
      'post level event',
    );
  }

  Future<void> completeActivitySession(int activitySessionId) async {
    final response = await _apiClient.put(
      Uri.parse(ApiConstants.activitySessionById(activitySessionId)),
      headers: _jsonHeaders,
    );

    print(
      'CREATIVE MAZE: complete activity session response = '
          '${response.statusCode} - ${_shortBody(response.body)}',
    );

    _ensureSuccess(
      response.statusCode,
      response.body,
      'complete activity session',
    );
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

  // ---- Entry-flow helpers (mirror SoundTrackerService) ----

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
      queryParameters: {'page': '0', 'size': '1', 'sort': 'createdAt,desc'},
    );
    final response = await _apiClient.get(uri);
    _ensureSuccess(response.statusCode, response.body, 'get latest session');
    final data = jsonDecode(response.body);
    final content = data is Map ? data['content'] : null;
    if (content is! List || content.isEmpty) return null;
    final first = content.first;
    if (first is! Map) return null;
    return Map<String, dynamic>.from(first);
  }

  Future<int> createSession({required int childId, required int kitId}) async {
    final body = jsonEncode({'childId': childId, 'kitId': kitId});
    final response = await _apiClient.post(
      Uri.parse(ApiConstants.sessions),
      headers: _jsonHeaders,
      body: body,
    );
    _ensureSuccess(response.statusCode, response.body, 'create session');
    final data = jsonDecode(response.body);
    final sessionId = _readInt(data, ['id', 'sessionId']);
    if (sessionId == 0) throw Exception('Created session id was not found.');
    return sessionId;
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
    final response = await _apiClient.post(
      Uri.parse(ApiConstants.activitySessions),
      headers: _jsonHeaders,
      body: body,
    );
    _ensureSuccess(
        response.statusCode, response.body, 'create activity session');
    final data = jsonDecode(response.body);
    final id = _readInt(data, ['id', 'activitySessionId']);
    if (id == 0) throw Exception('Activity session id was not found.');
    return id;
  }

  int readSessionId(Map<String, dynamic> session) =>
      _readInt(session, ['id', 'sessionId']);

  int readKitId(Map<String, dynamic> session) {
    final direct = _readInt(session, ['kitId']);
    if (direct != 0) return direct;
    final kit = session['kit'];
    if (kit is Map) return _readInt(kit, ['id', 'kitId']);
    return 0;
  }

  // ── Coins ──────────────────────────────────────────────────────────
  // POST /api/coins/maze-collect?count={count}
  //
  Future<void> submitCoinsCollected(int count) async {
    final uri = Uri.parse(ApiConstants.coinsMazeCollect(count));
    final response = await _apiClient.post(uri);

    print(
      'CREATIVE MAZE: submit coins response = '
          '${response.statusCode} - ${_shortBody(response.body)}',
    );

    _ensureSuccess(response.statusCode, response.body, 'submit coins');
  }

}