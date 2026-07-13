import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/api_constants.dart';
import '../../models/journal/journal_models.dart';
import '../auth/auth_api_client.dart';
import '../kit/kit_service.dart';
import '../roadmap/roadmap_service.dart';

class JournalService {
  final AuthApiClient _client = AuthApiClient();
  final KitService _kitService = KitService();
  final RoadmapService _roadmapService = RoadmapService();

  Future<int?> getSelectedChildId() async {
    final response = await _client.get(
      Uri.parse(ApiConstants.selectedChild),
    );

    if (response.statusCode == 404 || response.body.trim().isEmpty) {
      return null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = _decodeJson(response);

      final data = _unwrapObject(
        decoded,
        keys: [
          'data',
          'child',
          'selectedChild',
          'result',
        ],
      );

      if (data == null) return null;

      return _parseInt(data['id'] ?? data['childId']);
    }

    throw Exception(
      _extractErrorMessage(response.body, 'Failed to load selected child'),
    );
  }

  Future<JournalActivitiesProgressModel> getActivitiesProgress(
      int childId,
      ) async {
    final sessionsResponse = await _client.get(
      Uri.parse(ApiConstants.sessionsByChild(childId)),
    );

    final sessions = _parseListResponse(
      sessionsResponse,
      fallbackError: 'Failed to load child sessions',
      listKeys: [
        'data',
        'sessions',
        'items',
        'content',
        'result',
      ],
    );

    if (sessions.isEmpty) {
      return const JournalActivitiesProgressModel.empty();
    }

    final latestSession = _findLatestSession(sessions);
    final kitId = _extractKitId(latestSession);

    if (kitId == null || kitId <= 0) {
      return const JournalActivitiesProgressModel.empty();
    }

    return _getActivitiesProgressFromRoadmap(
      kitId: kitId,
      childId: childId,
    );
  }

  Future<JournalActivitiesProgressModel>
  _getActivitiesProgressFromRoadmap({
    required int kitId,
    required int childId,
  }) async {
    try {
      final roadmap = await _roadmapService.getRoadmap(
        kitId: kitId,
        childId: childId,
      );

      final completionByActivityId = <int, bool>{};

      for (final activity in roadmap.activities) {
        if (activity.activityId <= 0) continue;

        completionByActivityId.update(
          activity.activityId,
              (allCardsCompleted) =>
          allCardsCompleted && activity.isCompleted,
          ifAbsent: () => activity.isCompleted,
        );
      }

      if (completionByActivityId.isEmpty) {
        return _getFallbackActivitiesProgress(kitId);
      }

      final completedActivities = completionByActivityId.values
          .where((isCompleted) => isCompleted)
          .length;
      final totalActivities = completionByActivityId.length;

      print(
        'JOURNAL ROADMAP PROGRESS: '
            '$completedActivities/$totalActivities unique activities',
      );

      return JournalActivitiesProgressModel(
        completedActivities: completedActivities,
        totalActivities: totalActivities,
      );
    } catch (_) {
      return _getFallbackActivitiesProgress(kitId);
    }
  }

  Future<JournalActivitiesProgressModel> _getFallbackActivitiesProgress(
      int kitId,
      ) async {
    final results = await Future.wait<int>([
      _getCompletedActivitiesCount(),
      _kitService.getActivitiesCountByKitId(kitId),
    ]);

    final totalActivities = results[1];
    final completedActivities = totalActivities > 0
        ? results[0].clamp(0, totalActivities).toInt()
        : results[0];

    return JournalActivitiesProgressModel(
      completedActivities: completedActivities,
      totalActivities: totalActivities,
    );
  }

  Future<int> _getCompletedActivitiesCount() async {
    final response = await _client.get(
      Uri.parse(ApiConstants.roadmapCompletedCount),
    );

    if (response.statusCode == 404 || response.body.trim().isEmpty) {
      return 0;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = _decodeJson(response);

      if (decoded == null) return 0;
      if (decoded is int) return decoded;
      if (decoded is num) return decoded.toInt();

      if (decoded is Map<String, dynamic>) {
        return _parseInt(
          decoded['completedActivities'] ??
              decoded['completed_activities'] ??
              decoded['completedCount'] ??
              decoded['count'] ??
              decoded['data'] ??
              decoded['result'],
        ) ??
            0;
      }

      return int.tryParse(decoded.toString()) ?? 0;
    }

    throw Exception(
      _extractErrorMessage(
        response.body,
        'Failed to load completed activities count',
      ),
    );
  }

  Future<AIReportModel?> getLatestReport(int childId) async {
    final response = await _client.get(
      Uri.parse(ApiConstants.aiReportLatest(childId)),
    );

    return _parseReportResponse(
      response,
      fallbackError: 'Failed to load latest report',
    );
  }

  Future<AIReportModel?> getReportByVersion(
      int childId,
      String version,
      ) async {
    final response = await _client.get(
      Uri.parse(ApiConstants.aiReportByVersion(childId, version)),
    );

    return _parseReportResponse(
      response,
      fallbackError: 'Failed to load report version',
    );
  }

  Future<List<DailySessionModel>> getWeeklySessions() async {
    final response = await _client.get(
      Uri.parse(ApiConstants.aiReportsWeeklySessions),
    );

    final list = _parseListResponse(
      response,
      fallbackError: 'Failed to load weekly sessions',
      listKeys: [
        'data',
        'weeklySessions',
        'sessions',
        'items',
        'result',
      ],
    );

    return list.map(DailySessionModel.fromJson).toList();
  }

  Future<List<PerformanceModel>> getPerformances(int childId) async {
    final url = ApiConstants.performanceByChild(childId);

    final response = await _client.get(
      Uri.parse(url),
    );

    final list = _parseListResponse(
      response,
      fallbackError: 'Failed to load performances',
      listKeys: [
        'data',
        'performances',
        'performance',
        'activityPerformances',
        'childPerformances',
        'items',
        'content',
        'result',
      ],
    );


    return list.map(PerformanceModel.fromJson).toList();
  }
  AIReportModel? _parseReportResponse(
      http.Response response, {
        required String fallbackError,
      }) {
    if (response.statusCode == 404 || response.body.trim().isEmpty) {
      return null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = _decodeJson(response);

      if (decoded == null) return null;

      final data = _unwrapObject(
        decoded,
        keys: [
          'data',
          'report',
          'aiReport',
          'result',
        ],
      );

      if (data == null) return null;

      return AIReportModel.fromJson(data);
    }

    throw Exception(_extractErrorMessage(response.body, fallbackError));
  }

  List<Map<String, dynamic>> _parseListResponse(
      http.Response response, {
        required String fallbackError,
        required List<String> listKeys,
      }) {
    if (response.statusCode == 404 || response.body.trim().isEmpty) {
      return [];
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = _decodeJson(response);
      return _extractList(decoded, listKeys);
    }

    throw Exception(_extractErrorMessage(response.body, fallbackError));
  }

  List<Map<String, dynamic>> _extractList(
      dynamic decoded,
      List<String> keys,
      ) {
    if (decoded is List) {
      return _mapList(decoded);
    }

    if (decoded is Map<String, dynamic>) {
      for (final key in keys) {
        final value = decoded[key];

        if (value is List) {
          return _mapList(value);
        }

        if (value is Map<String, dynamic>) {
          final nested = _extractList(value, keys);
          if (nested.isNotEmpty) return nested;
        }
      }

      for (final value in decoded.values) {
        if (value is List) {
          final mapped = _mapList(value);
          if (mapped.isNotEmpty) return mapped;
        }

        if (value is Map<String, dynamic>) {
          final nested = _extractList(value, keys);
          if (nested.isNotEmpty) return nested;
        }
      }
    }

    return [];
  }

  Map<String, dynamic>? _unwrapObject(
      dynamic decoded, {
        required List<String> keys,
      }) {
    if (decoded == null) return null;

    if (decoded is Map<String, dynamic>) {
      for (final key in keys) {
        if (!decoded.containsKey(key)) continue;

        final value = decoded[key];

        if (value == null) return null;

        if (value is Map) {
          return Map<String, dynamic>.from(value);
        }
      }

      return decoded;
    }

    return null;
  }

  List<Map<String, dynamic>> _mapList(List<dynamic> list) {
    return list
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Map<String, dynamic> _findLatestSession(
      List<Map<String, dynamic>> sessions,
      ) {
    if (sessions.isEmpty) return <String, dynamic>{};

    final sorted = List<Map<String, dynamic>>.from(sessions);

    sorted.sort((a, b) {
      final aDate = _extractSessionDate(a);
      final bDate = _extractSessionDate(b);

      if (aDate != null && bDate != null) {
        return bDate.compareTo(aDate);
      }

      final aId = _parseInt(a['id'] ?? a['sessionId']) ?? 0;
      final bId = _parseInt(b['id'] ?? b['sessionId']) ?? 0;
      return bId.compareTo(aId);
    });

    return sorted.first;
  }

  DateTime? _extractSessionDate(Map<String, dynamic> session) {
    final value = session['updatedAt'] ??
        session['createdAt'] ??
        session['startedAt'] ??
        session['startTime'] ??
        session['endedAt'] ??
        session['completedAt'];

    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  int? _extractKitId(Map<String, dynamic> session) {
    final directKitId = _parseInt(
      session['kitId'] ??
          session['kit_id'] ??
          session['usedKitId'] ??
          session['lastUsedKitId'],
    );

    if (directKitId != null && directKitId > 0) {
      return directKitId;
    }

    final kit = session['kit'];
    if (kit is Map) {
      final nestedKitId = _parseInt(kit['id'] ?? kit['kitId']);
      if (nestedKitId != null && nestedKitId > 0) {
        return nestedKitId;
      }
    }

    final activity = session['activity'];
    if (activity is Map) {
      final activityKitId = _parseInt(
        activity['kitId'] ?? activity['kit_id'],
      );

      if (activityKitId != null && activityKitId > 0) {
        return activityKitId;
      }

      final activityKit = activity['kit'];
      if (activityKit is Map) {
        final nestedActivityKitId = _parseInt(
          activityKit['id'] ?? activityKit['kitId'],
        );

        if (nestedActivityKitId != null && nestedActivityKitId > 0) {
          return nestedActivityKitId;
        }
      }
    }

    return null;
  }

  dynamic _decodeJson(http.Response response) {
    final decodedBody = utf8.decode(response.bodyBytes).trim();

    if (decodedBody.isEmpty) {
      return null;
    }

    return jsonDecode(decodedBody);
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  String _extractErrorMessage(String body, String fallback) {
    try {
      final decoded = jsonDecode(body);

      if (decoded is Map<String, dynamic>) {
        return (decoded['message'] ?? decoded['error'] ?? fallback).toString();
      }
    } catch (_) {}

    return body.trim().isEmpty ? fallback : body.trim();
  }
}