import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../core/config/api_constants.dart';
import '../auth/auth_api_client.dart';
import '../roadmap/roadmap_service.dart';

/// Resolves everything the Color Lab game needs BEFORE it opens:
/// selected child → last used kit → current activity (via roadmap) →
/// progress → session → activity session.
///
/// The game itself never refetches any of this — it only receives the
/// final ids.
class ColorLabContext {
  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;
  final int? startLevelId;
  final int startLevelNumber;

  const ColorLabContext({
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
    this.startLevelId,
    this.startLevelNumber = 1,
  });
}

class ColorLabContextService {
  final AuthApiClient _client = AuthApiClient();
  final RoadmapService _roadmapService = RoadmapService();

  /// Full resolution pipeline. Throws with a friendly message on failure.
  Future<ColorLabContext> resolve() async {
    // A) Selected child
    final childId = await _getSelectedChildId();
    if (childId == null) {
      throw Exception('لم يتم اختيار طفل. الرجاء اختيار طفل أولاً.');
    }

    // B) Last used kit
    final kitId = await _getLastKitId(childId);
    if (kitId == null) {
      throw Exception('لا توجد حقيبة مستخدمة. الرجاء اختيار حقيبة.');
    }

    // C) Current activity from roadmap
    final activityId = await _getCurrentActivityId(kitId, childId);
    if (activityId == null) {
      throw Exception('لا يوجد نشاط حالي في خارطة الرحلة.');
    }

    // Progress — decide whether to resume or replay from Level 1.
    final startProgress = await _resolveStartProgress(activityId);

    // Session — create a fresh session for this play
    final sessionId = await _createSession(kitId: kitId, childId: childId);

    // D) Activity session — created before game opens
    final activitySessionId = await _createActivitySession(
      activityId: activityId,
      sessionId: sessionId,
    );

    return ColorLabContext(
      activityId: activityId,
      activitySessionId: activitySessionId,
      childId: childId,
      sessionId: sessionId,
      startLevelId: startProgress.startLevelId,
      startLevelNumber: startProgress.startLevelNumber,
    );
  }

  /// Faster path: the roadmap already knows childId, kitId and the tapped
  /// activityId. We only need to create a fresh session + activity session.
  /// This avoids re-fetching (and any chance of a wrong/empty resolve).
  Future<ColorLabContext> resolveFromKnown({
    required int activityId,
    required int kitId,
    required int childId,
  }) async {
    final startProgress = await _resolveStartProgress(activityId);

    final sessionId = await _createSession(kitId: kitId, childId: childId);

    final activitySessionId = await _createActivitySession(
      activityId: activityId,
      sessionId: sessionId,
    );

    return ColorLabContext(
      activityId: activityId,
      activitySessionId: activitySessionId,
      childId: childId,
      sessionId: sessionId,
      startLevelId: startProgress.startLevelId,
      startLevelNumber: startProgress.startLevelNumber,
    );
  }

  Future<_ColorLabStartProgress> _resolveStartProgress(int activityId) async {
    debugPrint('COLOR LAB: loading activity progress for activityId = $activityId');

    final progress = await _roadmapService.getActivityProgress(
      activityId: activityId,
    );

    if (progress == null) {
      debugPrint('COLOR LAB: no progress found, fallback to level 1');

      return const _ColorLabStartProgress(
        startLevelId: null,
        startLevelNumber: 1,
      );
    }

    if (progress.completed) {
      debugPrint('COLOR LAB: activity completed, replay starts from level 1');

      return const _ColorLabStartProgress(
        startLevelId: null,
        startLevelNumber: 1,
      );
    }

    if (!progress.hasValidCurrentLevel) {
      debugPrint('COLOR LAB: invalid progress level, fallback to level 1');

      return const _ColorLabStartProgress(
        startLevelId: null,
        startLevelNumber: 1,
      );
    }

    final startLevelNumber = progress.currentLevelNumber <= 0
        ? 1
        : progress.currentLevelNumber;

    debugPrint('COLOR LAB: resume from levelId = ${progress.currentLevelId}');
    debugPrint('COLOR LAB: resume from levelNumber = $startLevelNumber');

    return _ColorLabStartProgress(
      startLevelId: progress.currentLevelId,
      startLevelNumber: startLevelNumber,
    );
  }

  // A) GET /api/children/selected → childId
  Future<int?> _getSelectedChildId() async {
    final response = await _client.get(Uri.parse(ApiConstants.selectedChild));

    debugPrint('SELECTED CHILD: ${response.statusCode} - ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.trim().isEmpty) return null;
      final decoded = jsonDecode(response.body);
      if (decoded is Map) return _toInt(decoded['id']);
    }
    return null;
  }

  // B) GET /api/sessions/child/{childId}?page=0&size=1&sort=createdAt,desc
  Future<int?> _getLastKitId(int childId) async {
    final url =
        '${ApiConstants.sessionsByChild(childId)}?page=0&size=1&sort=createdAt,desc';

    final response = await _client.get(Uri.parse(url));

    debugPrint('LAST SESSION: ${response.statusCode} - ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.trim().isEmpty) return null;
      final decoded = jsonDecode(response.body);

      final List content = decoded is Map
          ? (decoded['content'] as List? ?? [])
          : (decoded as List? ?? []);

      if (content.isEmpty) return null;

      final first = content.first;
      if (first is Map) {
        // kitId may be nested under kit or flat
        final kit = first['kit'];
        if (kit is Map && kit['id'] != null) return _toInt(kit['id']);
        if (first['kitId'] != null) return _toInt(first['kitId']);
      }
    }
    return null;
  }

  // C) GET roadmap → filter for status == CURRENT, fallback to first
  Future<int?> _getCurrentActivityId(int kitId, int childId) async {
    final roadmap = await _roadmapService.getRoadmap(
      kitId: kitId,
      childId: childId,
    );

    if (roadmap.activities.isEmpty) return null;

    for (final activity in roadmap.activities) {
      if (activity.isCurrent) return activity.activityId;
    }

    // fallback to first
    return roadmap.activities.first.activityId;
  }

  // POST /api/sessions/  → returns session id
  Future<int> _createSession({
    required int kitId,
    required int childId,
  }) async {
    final body = {'kitId': kitId, 'childId': childId};

    final response = await _client.post(
      Uri.parse(ApiConstants.sessions),
      body: jsonEncode(body),
    );

    debugPrint('CREATE SESSION: ${response.statusCode} - ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['id'] != null) {
        return _toInt(decoded['id']);
      }
    }
    throw Exception('فشل إنشاء الجلسة');
  }

  // POST /api/activity-sessions/ → returns activity session id
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
      'CREATE ACTIVITY SESSION: ${response.statusCode} - ${response.body}',
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['id'] != null) {
        return _toInt(decoded['id']);
      }
    }
    throw Exception('فشل إنشاء جلسة النشاط');
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}

class _ColorLabStartProgress {
  final int? startLevelId;
  final int startLevelNumber;

  const _ColorLabStartProgress({
    required this.startLevelId,
    required this.startLevelNumber,
  });
}