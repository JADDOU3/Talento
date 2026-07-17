import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/config/api_constants.dart';
import '../auth/auth_api_client.dart';
import '../roadmap/roadmap_service.dart';

/// Resolves everything the Shape Creator game needs BEFORE it opens:
/// selected child → last used kit → current activity via roadmap →
/// session → activity session.
///
/// The game itself never refetches any of this.
/// It only receives the final ids.
class ShapeCreatorContext {
  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;
  final int? startLevelId;
  final int startLevelNumber;

  const ShapeCreatorContext({
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
    this.startLevelId,
    this.startLevelNumber = 1,
  });
}

class ShapeCreatorContextService {
  final AuthApiClient _client = AuthApiClient();
  final RoadmapService _roadmapService = RoadmapService();

  /// Full resolution pipeline.
  /// Useful if Shape Creator is opened without roadmap-provided ids.
  Future<ShapeCreatorContext> resolve() async {
    final childId = await _getSelectedChildId();
    if (childId == null) {
      throw Exception('لم يتم اختيار طفل. الرجاء اختيار طفل أولاً.');
    }

    final kitId = await _getLastKitId(childId);
    if (kitId == null) {
      throw Exception('لا توجد حقيبة مستخدمة. الرجاء اختيار حقيبة.');
    }

    final activityId = await _getCurrentActivityId(kitId, childId);
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

    return ShapeCreatorContext(
      activityId: activityId,
      activitySessionId: activitySessionId,
      childId: childId,
      sessionId: sessionId,
      startLevelId: startProgress.startLevelId,
      startLevelNumber: startProgress.startLevelNumber,
    );
  }

  /// Faster path.
  /// The roadmap already knows childId, kitId and tapped activityId.
  Future<ShapeCreatorContext> resolveFromKnown({
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

    return ShapeCreatorContext(
      activityId: activityId,
      activitySessionId: activitySessionId,
      childId: childId,
      sessionId: sessionId,
      startLevelId: startProgress.startLevelId,
      startLevelNumber: startProgress.startLevelNumber,
    );
  }

  Future<_ShapeCreatorStartProgress> _resolveStartProgress(
      int activityId,
      ) async {
    debugPrint(
      'SHAPE CREATOR: loading activity progress for activityId = $activityId',
    );

    final progress = await _roadmapService.getActivityProgress(
      activityId: activityId,
    );

    if (progress == null) {
      debugPrint('SHAPE CREATOR: no progress found, fallback to level 1');

      return const _ShapeCreatorStartProgress(
        startLevelId: null,
        startLevelNumber: 1,
      );
    }

    if (progress.completed) {
      debugPrint(
        'SHAPE CREATOR: activity completed, replay starts from level 1',
      );

      return const _ShapeCreatorStartProgress(
        startLevelId: null,
        startLevelNumber: 1,
      );
    }

    if (!progress.hasValidCurrentLevel) {
      debugPrint(
        'SHAPE CREATOR: invalid progress level, fallback to level 1',
      );

      return const _ShapeCreatorStartProgress(
        startLevelId: null,
        startLevelNumber: 1,
      );
    }

    final startLevelNumber = progress.currentLevelNumber <= 0
        ? 1
        : progress.currentLevelNumber;

    debugPrint(
      'SHAPE CREATOR: resume from levelId = ${progress.currentLevelId}',
    );
    debugPrint(
      'SHAPE CREATOR: resume from levelNumber = $startLevelNumber',
    );

    return _ShapeCreatorStartProgress(
      startLevelId: progress.currentLevelId,
      startLevelNumber: startLevelNumber,
    );
  }

  // GET /api/children/selected
  Future<int?> _getSelectedChildId() async {
    final response = await _client.get(
      Uri.parse(ApiConstants.selectedChild),
    );

    debugPrint('SHAPE CREATOR SELECTED CHILD: ${response.statusCode} - ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.trim().isEmpty) return null;

      final decoded = jsonDecode(response.body);

      if (decoded is Map) {
        return _toInt(decoded['id']);
      }
    }

    return null;
  }

  // GET /api/sessions/child/{childId}?page=0&size=1&sort=createdAt,desc
  Future<int?> _getLastKitId(int childId) async {
    final url =
        '${ApiConstants.sessionsByChild(childId)}?page=0&size=1&sort=createdAt,desc';

    final response = await _client.get(
      Uri.parse(url),
    );

    debugPrint('SHAPE CREATOR LAST SESSION: ${response.statusCode} - ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.trim().isEmpty) return null;

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

  // GET roadmap → find current activity, fallback to first activity.
  Future<int?> _getCurrentActivityId(int kitId, int childId) async {
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

  // POST /api/sessions/
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

    debugPrint('SHAPE CREATOR CREATE SESSION: ${response.statusCode} - ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);

      if (decoded is Map && decoded['id'] != null) {
        return _toInt(decoded['id']);
      }
    }

    throw Exception('فشل إنشاء الجلسة');
  }

  // POST /api/activity-sessions/
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
      'SHAPE CREATOR CREATE ACTIVITY SESSION: ${response.statusCode} - ${response.body}',
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
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

class _ShapeCreatorStartProgress {
  final int? startLevelId;
  final int startLevelNumber;

  const _ShapeCreatorStartProgress({
    required this.startLevelId,
    required this.startLevelNumber,
  });
}
