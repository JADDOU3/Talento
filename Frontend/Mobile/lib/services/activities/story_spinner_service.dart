import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../core/config/api_constants.dart';
import '../../models/activities/story_spinner/story_spinner_level_model.dart';
import '../../models/activities/story_spinner/story_spinner_voice_check_result.dart';
import '../auth/auth_api_client.dart';

class StorySpinnerService {
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

    print(
      'STORY SPINNER: latest session response = '
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

    print('STORY SPINNER: create session body = $body');

    final response = await _apiClient.post(
      Uri.parse(ApiConstants.sessions),
      headers: _jsonHeaders,
      body: body,
    );

    print(
      'STORY SPINNER: create session response = '
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

  Future<List<Map<String, dynamic>>> getRoadmapActivities({
    required int kitId,
    required int childId,
  }) async {
    final response = await _apiClient.get(
      Uri.parse(ApiConstants.roadmapByKitAndChild(kitId, childId)),
    );

    print(
      'STORY SPINNER: roadmap response = '
          '${response.statusCode} - ${_shortBody(response.body)}',
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

    print('STORY SPINNER: create activity session body = $body');

    final response = await _apiClient.post(
      Uri.parse(ApiConstants.activitySessions),
      headers: _jsonHeaders,
      body: body,
    );

    print(
      'STORY SPINNER: create activity session response = '
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

  Future<List<StorySpinnerLevelModel>> getLevelsByActivity(
      int activityId,
      ) async {
    final uri = Uri.parse(ApiConstants.levelsByActivity(activityId)).replace(
      queryParameters: {
        'page': '0',
        'size': '100',
        'sort': 'levelNumber,asc',
      },
    );

    print('STORY SPINNER: get levels url = $uri');

    final response = await _apiClient.get(uri);

    print(
      'STORY SPINNER: get levels response = '
          '${response.statusCode} - ${_shortBody(response.body)}',
    );

    _ensureSuccess(response.statusCode, response.body, 'get levels');

    final data = jsonDecode(response.body);

    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid levels response.');
    }

    final levels = StorySpinnerLevelModel.listFromPageResponse(data);

    if (levels.isEmpty) {
      throw Exception('No Story Spinner levels were found.');
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

    print('STORY SPINNER: create level attempt body = $body');

    final response = await _apiClient.post(
      Uri.parse(ApiConstants.levelAttempts),
      headers: _jsonHeaders,
      body: body,
    );

    print(
      'STORY SPINNER: create level attempt response = '
          '${response.statusCode} - ${_shortBody(response.body)}',
    );

    _ensureSuccess(response.statusCode, response.body, 'create level attempt');

    final data = jsonDecode(response.body);

    final attemptId = _readInt(data, ['id', 'attemptId']);

    if (attemptId == 0) {
      throw Exception('Level attempt id was not found.');
    }

    return attemptId;
  }

  Future<StorySpinnerVoiceCheckResult> transcribeWithKeywords({
    required String filePath,
    required int activityId,
    required int activitySessionId,
    required int levelId,
    required List<String> keywords,
    required Duration recordingDuration,
  }) async {
    const maximumRecordingDuration = Duration(minutes: 3);

    if (recordingDuration > maximumRecordingDuration) {
      throw Exception('لا يمكن رفع تسجيل تزيد مدته عن 3 دقائق.');
    }

    final audioFile = File(filePath);

    if (!await audioFile.exists()) {
      throw Exception('Recorded audio file was not found.');
    }

    final cleanedKeywords = keywords
        .map((keyword) => keyword.trim())
        .where((keyword) => keyword.isNotEmpty)
        .toList();

    if (cleanedKeywords.length != 3) {
      throw Exception('Story Spinner needs exactly 3 Arabic keywords.');
    }

    final requestBody = jsonEncode({
      'activityId': activityId,
      'activitySessionId': activitySessionId,
      'levelId': levelId,
      'keywords': cleanedKeywords,
    });

    print('STORY SPINNER: voice check request = $requestBody');
    print('STORY SPINNER: voice check file = ${audioFile.path}');

    final response = await _apiClient.multipartPost(
      Uri.parse(ApiConstants.voiceTranscribeWithKeywords),
      buildRequest: (request) async {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            audioFile.path,
          ),
        );

        request.files.add(
          http.MultipartFile.fromString(
            'request',
            requestBody,
            contentType: MediaType('application', 'json'),
          ),
        );
      },
    );

    print(
      'STORY SPINNER: voice check response = '
          '${response.statusCode} - ${_shortBody(response.body)}',
    );

    _ensureSuccess(
      response.statusCode,
      response.body,
      'transcribe story with keywords',
    );

    final data = jsonDecode(response.body);

    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid voice check response.');
    }

    return StorySpinnerVoiceCheckResult.fromJson(data);
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

    print('STORY SPINNER: update level attempt body = $body');

    final response = await _apiClient.put(
      Uri.parse(ApiConstants.levelAttemptById(attemptId)),
      headers: _jsonHeaders,
      body: body,
    );

    print(
      'STORY SPINNER: update level attempt response = '
          '${response.statusCode} - ${_shortBody(response.body)}',
    );

    _ensureSuccess(response.statusCode, response.body, 'update level attempt');
  }

  Future<void> postActivityEvent({
    required int childId,
    required int sessionId,
    required int activityId,
    required String action,
    String responseLanguage = 'en',
  }) async {
    final body = jsonEncode({
      'childId': childId,
      'sessionId': sessionId,
      'activityId': activityId,
      'action': action,
      'responseLanguage': responseLanguage,
    });

    print('STORY SPINNER: post activity event body = $body');

    final response = await _apiClient.post(
      Uri.parse(ApiConstants.activityEvents),
      headers: _jsonHeaders,
      body: body,
    );

    print(
      'STORY SPINNER: post activity event response = '
          '${response.statusCode} - ${_shortBody(response.body)}',
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

    print('STORY SPINNER: post level event body = $body');

    final response = await _apiClient.post(
      Uri.parse(ApiConstants.levelEvents),
      headers: _jsonHeaders,
      body: body,
    );

    print(
      'STORY SPINNER: post level event response = '
          '${response.statusCode} - ${_shortBody(response.body)}',
    );

    _ensureSuccess(response.statusCode, response.body, 'post level event');
  }

  Future<void> completeActivitySession(int activitySessionId) async {
    final response = await _apiClient.put(
      Uri.parse(ApiConstants.activitySessionById(activitySessionId)),
      headers: _jsonHeaders,
    );

    print(
      'STORY SPINNER: complete activity session response = '
          '${response.statusCode} - ${_shortBody(response.body)}',
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