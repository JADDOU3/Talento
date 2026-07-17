import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/config/api_constants.dart';
import '../auth/auth_api_client.dart';
import '../roadmap/roadmap_service.dart';

/// Resolves everything Tower Builder needs before it opens:
/// progress → session → activity session.
///
/// The roadmap already passes activityId, kitId and childId through the
/// launcher, while [resolve] remains available as a fallback.
class TowerBuilderContext {
  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;
  final int? startLevelId;
  final int startLevelNumber;

  const TowerBuilderContext({
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
    this.startLevelId,
    this.startLevelNumber = 1,
  });
}

class TowerBuilderContextService {
  final AuthApiClient _client = AuthApiClient();
  final RoadmapService _roadmapService = RoadmapService();

  Future<TowerBuilderContext> resolve() async {
    final childId = await _getSelectedChildId();

    if (childId == null) {
      throw Exception('لم يتم اختيار طفل. الرجاء اختيار طفل أولاً.');
    }

    final kitId = await _getLastKitId(childId);

    if (kitId == null) {
      throw Exception('لا توجد حقيبة مستخدمة. الرجاء اختيار حقيبة.');
    }

    final activityId = await _getCurrentActivityId(
      kitId,
      childId,
    );

    if (activityId == null) {
      throw Exception('لا يوجد نشاط حالي في خارطة الرحلة.');
    }

    final startProgress = await _resolveStartProgress(activityId);

    final sessionId = await _createSession(
      kitId: kitId,
      childId: childId,
    );

    final activitySessionId = await _createActivitySession(
      activityId: activityId,
      sessionId: sessionId,
    );

    return TowerBuilderContext(
      activityId: activityId,
      activitySessionId: activitySessionId,
      childId: childId,
      sessionId: sessionId,
      startLevelId: startProgress.startLevelId,
      startLevelNumber: startProgress.startLevelNumber,
    );
  }

  Future<TowerBuilderContext> resolveFromKnown({
    required int activityId,
    required int kitId,
    required int childId,
  }) async {
    final startProgress = await _resolveStartProgress(activityId);

    final sessionId = await _createSession(
      kitId: kitId,
      childId: childId,
    );

    final activitySessionId = await _createActivitySession(
      activityId: activityId,
      sessionId: sessionId,
    );

    return TowerBuilderContext(
      activityId: activityId,
      activitySessionId: activitySessionId,
      childId: childId,
      sessionId: sessionId,
      startLevelId: startProgress.startLevelId,
      startLevelNumber: startProgress.startLevelNumber,
    );
  }

  /// Uses the same shared response parser as Color Lab.
  ///
  /// It accepts currentLevelId when available and still keeps
  /// currentLevelNumber as a fallback when the backend returns no valid id.
  Future<_TowerBuilderStartProgress> _resolveStartProgress(
      int activityId,
      ) async {
    debugPrint(
      'TOWER BUILDER: loading progress for activityId=$activityId',
    );

    final progress = await _roadmapService.getActivityProgress(
      activityId: activityId,
    );

    if (progress == null) {
      debugPrint(
        'TOWER BUILDER: no progress found, starting from level 1',
      );

      return const _TowerBuilderStartProgress(
        startLevelId: null,
        startLevelNumber: 1,
      );
    }

    if (progress.completed) {
      debugPrint(
        'TOWER BUILDER: completed activity replay starts from level 1',
      );

      return const _TowerBuilderStartProgress(
        startLevelId: null,
        startLevelNumber: 1,
      );
    }

    final startLevelId =
    progress.currentLevelId > 0 ? progress.currentLevelId : null;

    final startLevelNumber = progress.currentLevelNumber > 0
        ? progress.currentLevelNumber
        : 1;

    debugPrint(
      'TOWER BUILDER: resume levelId=$startLevelId, '
          'levelNumber=$startLevelNumber',
    );

    return _TowerBuilderStartProgress(
      startLevelId: startLevelId,
      startLevelNumber: startLevelNumber,
    );
  }

  Future<int?> _getSelectedChildId() async {
    final response = await _client.get(
      Uri.parse(ApiConstants.selectedChild),
    );

    debugPrint(
      'TOWER BUILDER SELECTED CHILD: '
          '${response.statusCode} - ${response.body}',
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        response.body.trim().isNotEmpty) {
      final decoded = jsonDecode(response.body);

      if (decoded is Map) {
        return _toInt(decoded['id']);
      }
    }

    return null;
  }

  Future<int?> _getLastKitId(int childId) async {
    final url =
        '${ApiConstants.sessionsByChild(childId)}'
        '?page=0&size=1&sort=createdAt,desc';

    final response = await _client.get(Uri.parse(url));

    debugPrint(
      'TOWER BUILDER LAST SESSION: '
          '${response.statusCode} - ${response.body}',
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300 &&
        response.body.trim().isNotEmpty) {
      final decoded = jsonDecode(response.body);

      final List content = decoded is Map
          ? (decoded['content'] as List? ?? [])
          : (decoded as List? ?? []);

      if (content.isEmpty) return null;

      final first = content.first;

      if (first is Map) {
        final kit = first['kit'];

        if (kit is Map && kit['id'] != null) {
          return _toInt(kit['id']);
        }

        if (first['kitId'] != null) {
          return _toInt(first['kitId']);
        }
      }
    }

    return null;
  }

  Future<int?> _getCurrentActivityId(
      int kitId,
      int childId,
      ) async {
    final roadmap = await _roadmapService.getRoadmap(
      kitId: kitId,
      childId: childId,
    );

    if (roadmap.activities.isEmpty) return null;

    for (final activity in roadmap.activities) {
      if (activity.isCurrent) {
        return activity.activityId;
      }
    }

    return roadmap.activities.first.activityId;
  }

  Future<int> _createSession({
    required int kitId,
    required int childId,
  }) async {
    final body = {
      'kitId': kitId,
      'childId': childId,
    };

    final response = await _client.post(
      Uri.parse(ApiConstants.sessions),
      body: jsonEncode(body),
    );

    debugPrint(
      'TOWER BUILDER CREATE SESSION BODY: $body',
    );
    debugPrint(
      'TOWER BUILDER CREATE SESSION RESPONSE: '
          '${response.statusCode} - ${response.body}',
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final decoded = jsonDecode(response.body);

      if (decoded is Map && decoded['id'] != null) {
        return _toInt(decoded['id']);
      }
    }

    throw Exception('فشل إنشاء الجلسة');
  }

  Future<int> _createActivitySession({
    required int activityId,
    required int sessionId,
  }) async {
    final body = {
      'orderIndex': 1,
      'activityId': activityId,
      'sessionId': sessionId,
    };

    final response = await _client.post(
      Uri.parse(ApiConstants.activitySessions),
      body: jsonEncode(body),
    );

    debugPrint(
      'TOWER BUILDER CREATE ACTIVITY SESSION BODY: $body',
    );
    debugPrint(
      'TOWER BUILDER CREATE ACTIVITY SESSION RESPONSE: '
          '${response.statusCode} - ${response.body}',
    );

    if (response.statusCode >= 200 &&
        response.statusCode < 300) {
      final decoded = jsonDecode(response.body);

      if (decoded is Map && decoded['id'] != null) {
        return _toInt(decoded['id']);
      }
    }

    throw Exception('فشل إنشاء جلسة النشاط');
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class _TowerBuilderStartProgress {
  final int? startLevelId;
  final int startLevelNumber;

  const _TowerBuilderStartProgress({
    required this.startLevelId,
    required this.startLevelNumber,
  });
}
