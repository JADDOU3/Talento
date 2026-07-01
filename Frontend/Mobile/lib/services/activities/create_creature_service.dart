import 'dart:convert';
import 'dart:io';

import '../../core/config/api_constants.dart';
import '../../models/activities/create_creature/create_creature_level_model.dart';
import '../auth/auth_api_client.dart';

class CreateCreatureService {
  final AuthApiClient _apiClient = AuthApiClient();

  Map<String, String> get _jsonHeaders => {
    'Content-Type': 'application/json',
  };

  Future<List<CreateCreatureLevelModel>> getLevelsByActivity(
      int activityId) async {
    final uri = Uri.parse(ApiConstants.levelsByActivity(activityId)).replace(
      queryParameters: {
        'page': '0',
        'size': '100',
        'sort': 'levelNumber,asc',
      },
    );

    print('CREATE CREATURE: get levels url = $uri');

    final response = await _apiClient.get(uri);

    print(
      'CREATE CREATURE: get levels response = '
          '${response.statusCode} - ${_shortBody(response.body)}',
    );

    _ensureSuccess(response.statusCode, response.body, 'get levels');

    final data = jsonDecode(response.body);

    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid levels response.');
    }

    final levels = CreateCreatureLevelModel.listFromPageResponse(data);

    if (levels.isEmpty) {
      throw Exception('No levels were found for activityId: $activityId');
    }

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

    print('CREATE CREATURE: create level attempt body = $body');

    final response = await _apiClient.post(
      Uri.parse(ApiConstants.levelAttempts),
      headers: _jsonHeaders,
      body: body,
    );

    print(
      'CREATE CREATURE: create level attempt response = '
          '${response.statusCode} - ${_shortBody(response.body)}',
    );

    _ensureSuccess(
        response.statusCode, response.body, 'create level attempt');

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

    print('CREATE CREATURE: update level attempt body = $body');

    final response = await _apiClient.put(
      Uri.parse(ApiConstants.levelAttemptById(attemptId)),
      headers: _jsonHeaders,
      body: body,
    );

    print(
      'CREATE CREATURE: update level attempt response = '
          '${response.statusCode} - ${_shortBody(response.body)}',
    );

    _ensureSuccess(
        response.statusCode, response.body, 'update level attempt');
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

    print('CREATE CREATURE: post activity event body = $body');

    final response = await _apiClient.post(
      Uri.parse(ApiConstants.activityEvents),
      headers: _jsonHeaders,
      body: body,
    );

    print(
      'CREATE CREATURE: post activity event response = '
          '${response.statusCode} - ${_shortBody(response.body)}',
    );

    _ensureSuccess(
        response.statusCode, response.body, 'post activity event');
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

    print('CREATE CREATURE: post level event body = $body');

    final response = await _apiClient.post(
      Uri.parse(ApiConstants.levelEvents),
      headers: _jsonHeaders,
      body: body,
    );

    print(
      'CREATE CREATURE: post level event response = '
          '${response.statusCode} - ${_shortBody(response.body)}',
    );

    _ensureSuccess(
        response.statusCode, response.body, 'post level event');
  }

  Future<void> completeActivitySession(int activitySessionId) async {
    final response = await _apiClient.put(
      Uri.parse(ApiConstants.activitySessionById(activitySessionId)),
      headers: _jsonHeaders,
    );

    print(
      'CREATE CREATURE: complete activity session response = '
          '${response.statusCode} - ${_shortBody(response.body)}',
    );

    _ensureSuccess(
        response.statusCode, response.body, 'complete activity session');
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
    return body;
    //if (body.length <= 800) return body;
    //return '${body.substring(0, 800)}...';
  }

  void _ensureSuccess(int statusCode, String body, String actionName) {
    if (statusCode >= 200 && statusCode < 300) return;

    throw Exception(
      'Failed to $actionName. Status code: $statusCode. Body: $body',
    );
  }

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

    print(
      'CREATE CREATURE: latest session response = '
          '${response.statusCode} - ${_shortBody(response.body)}',
    );

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

    print('CREATE CREATURE: create session body = $body');

    final response = await _apiClient.post(
      Uri.parse(ApiConstants.sessions),
      headers: _jsonHeaders,
      body: body,
    );

    print(
      'CREATE CREATURE: create session response = '
          '${response.statusCode} - ${_shortBody(response.body)}',
    );

    _ensureSuccess(response.statusCode, response.body, 'create session');

    final data = jsonDecode(response.body);

    final sessionId = _readInt(data, ['id', 'sessionId']);

    if (sessionId == 0) {
      throw Exception('Created session id was not found.');
    }

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

    print('CREATE CREATURE: create activity session body = $body');

    final response = await _apiClient.post(
      Uri.parse(ApiConstants.activitySessions),
      headers: _jsonHeaders,
      body: body,
    );

    print(
      'CREATE CREATURE: create activity session response = '
          '${response.statusCode} - ${_shortBody(response.body)}',
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

  Future<Map<String, dynamic>> transcribeWithKeywords({
    required File file,
    required int activityId,
    required List<String> keywords,
  }) async {
    final response = await _apiClient.multipartPost(
      Uri.parse(ApiConstants.transcribeWithKeywords),
      filePath: file.path,
      fileField: 'file',
      jsonField: 'request',
      jsonBody: {
        'activityId': activityId,
        'keywords': keywords,
      },
    );

    print(
      'CREATE CREATURE: transcribe response = '
          '${response.statusCode} - ${_shortBody(response.body)}',
    );

    _ensureSuccess(response.statusCode, response.body, 'transcribe with keywords');

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

// Future<String> getPresignedUrl(String s3Key) async {
//   final uri = Uri.parse(ApiConstants.presignedUrlEndpoint).replace(
//     queryParameters: {'key': s3Key},
//   );

//   final response = await _apiClient.get(uri);

//   print(
//     'CREATE CREATURE: get presigned url response = '
//         '${response.statusCode} - ${_shortBody(response.body)}',
//   );

//   _ensureSuccess(response.statusCode, response.body, 'get presigned url');

//   final data = jsonDecode(response.body);
//   final url = data is Map ? data['url']?.toString() : null;

//   if (url == null || url.isEmpty) {
//     throw Exception('Presigned URL not found in response.');
//   }

//   return url;
// }
}