import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/config/api_constants.dart';
import '../../models/empathy_mirror/empathy_mirror_models.dart';
import '../auth/auth_api_client.dart';

class EmpathyMirrorAttemptInfo {
  final int id;
  final String startedAt;

  const EmpathyMirrorAttemptInfo({
    required this.id,
    required this.startedAt,
  });
}

class EmpathyMirrorService {
  final AuthApiClient _client = AuthApiClient();

  String _nowIso() {
    return DateTime.now().toUtc().toIso8601String().replaceFirst('Z', '');
  }

  String _normalizeIso(String value) {
    return value.trim().replaceFirst(RegExp(r'Z$'), '');
  }

  // ===================== LEVELS =====================

  Future<List<EmpathyMirrorLevel>> getLevels(int activityId) async {
    final url =
        '${ApiConstants.levelsByActivity(activityId)}?page=0&size=100&sort=levelNumber,asc';

    debugPrint('EMPATHY GET LEVELS URL: $url');

    final response = await _client.get(Uri.parse(url));

    debugPrint(
      'EMPATHY GET LEVELS RESPONSE: '
          '${response.statusCode} - ${response.body}',
    );

    _ensureSuccess(
      response.statusCode,
      response.body,
      'فشل تحميل مستويات مرآة التعاطف',
    );

    final decoded = jsonDecode(response.body);
    final List content = decoded is Map
        ? (decoded['content'] as List? ?? [])
        : (decoded as List? ?? []);

    return content
        .whereType<Map>()
        .map(
          (item) => EmpathyMirrorLevel.fromJson(
        Map<String, dynamic>.from(item),
      ),
    )
        .toList();
  }

  // ===================== LEVEL ATTEMPTS =====================

  Future<EmpathyMirrorAttemptInfo> createLevelAttempt({
    required int attemptNumber,
    required int activitySessionId,
    required int levelId,
  }) async {
    final startedAt = _nowIso();
    final body = {
      'attemptNumber': attemptNumber,
      'startedAt': startedAt,
      'activitySessionId': activitySessionId,
      'levelId': levelId,
      'completed': false,
    };

    debugPrint('EMPATHY CREATE ATTEMPT BODY: $body');

    final response = await _client.post(
      Uri.parse(ApiConstants.levelAttempts),
      body: jsonEncode(body),
    );

    debugPrint(
      'EMPATHY CREATE ATTEMPT RESPONSE: '
          '${response.statusCode} - ${response.body}',
    );

    _ensureSuccess(
      response.statusCode,
      response.body,
      'فشل إنشاء محاولة المستوى',
    );

    final decoded = jsonDecode(response.body);

    if (decoded is Map && decoded['id'] != null) {
      return EmpathyMirrorAttemptInfo(
        id: _toInt(decoded['id']),
        startedAt: (decoded['startedAt'] ?? startedAt).toString(),
      );
    }

    throw Exception('تم إنشاء المحاولة بدون إرجاع رقم المحاولة');
  }

  Future<void> updateLevelAttempt({
    required int attemptId,
    required int attemptNumber,
    required String startedAt,
    required int activitySessionId,
    required int levelId,
    required bool completed,
  }) async {
    final body = {
      'attemptNumber': attemptNumber,
      'startedAt': _normalizeIso(startedAt),
      'endedAt': _nowIso(),
      'completed': completed,
      'activitySessionId': activitySessionId,
      'levelId': levelId,
    };

    debugPrint(
      'EMPATHY UPDATE ATTEMPT $attemptId BODY: $body',
    );

    final response = await _client.put(
      Uri.parse(ApiConstants.levelAttemptById(attemptId)),
      body: jsonEncode(body),
    );

    debugPrint(
      'EMPATHY UPDATE ATTEMPT RESPONSE: '
          '${response.statusCode} - ${response.body}',
    );

    _ensureSuccess(
      response.statusCode,
      response.body,
      'فشل تحديث محاولة المستوى',
    );
  }

  // ===================== EVENTS =====================

  Future<void> logActivityEvent({
    required int childId,
    required int sessionId,
    required int activityId,
    required String action,
    String responseLanguage = 'en',
  }) async {
    final body = {
      'childId': childId,
      'sessionId': sessionId,
      'activityId': activityId,
      'action': action,
      'responseLanguage': responseLanguage,
    };

    debugPrint('EMPATHY ACTIVITY EVENT BODY: $body');

    final response = await _client.post(
      Uri.parse(ApiConstants.activityEvents),
      body: jsonEncode(body),
    );

    debugPrint(
      'EMPATHY ACTIVITY EVENT RESPONSE: '
          '${response.statusCode} - ${response.body}',
    );

    _ensureSuccess(
      response.statusCode,
      response.body,
      'فشل حفظ حدث النشاط $action',
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

    debugPrint('EMPATHY LEVEL EVENT BODY: $body');

    final response = await _client.post(
      Uri.parse(ApiConstants.levelEvents),
      body: jsonEncode(body),
    );

    debugPrint(
      'EMPATHY LEVEL EVENT RESPONSE: '
          '${response.statusCode} - ${response.body}',
    );

    _ensureSuccess(
      response.statusCode,
      response.body,
      'فشل حفظ حدث المستوى $action',
    );
  }

  // ===================== ACTIVITY SESSION =====================

  Future<void> completeActivitySession(int activitySessionId) async {
    final response = await _client.put(
      Uri.parse(ApiConstants.activitySessionById(activitySessionId)),
    );

    debugPrint(
      'EMPATHY COMPLETE ACTIVITY SESSION RESPONSE: '
          '${response.statusCode} - ${response.body}',
    );

    _ensureSuccess(
      response.statusCode,
      response.body,
      'فشل إكمال جلسة النشاط',
    );
  }

  // ===================== HELPERS =====================

  void _ensureSuccess(
      int statusCode,
      String body,
      String fallbackMessage,
      ) {
    if (statusCode >= 200 && statusCode < 300) return;

    throw Exception(
      '${_extractErrorMessage(body, fallbackMessage)} '
          '| statusCode=$statusCode | body=$body',
    );
  }

  String _extractErrorMessage(String body, String fallbackMessage) {
    try {
      final decoded = jsonDecode(body);

      if (decoded is Map) {
        return (decoded['message'] ?? decoded['error'] ?? fallbackMessage)
            .toString();
      }
    } catch (_) {}

    return fallbackMessage;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
