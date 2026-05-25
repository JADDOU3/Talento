import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/api_constants.dart';
import '../../cubits/home/home_data.dart';
import '../../models/child_model.dart';
import '../../models/kit/kit_model.dart';
import '../auth/auth_api_client.dart';
import '../kit/kit_service.dart';

class HomeService {
  final AuthApiClient _client = AuthApiClient();
  final KitService _kitService = KitService();

  Future<bool> isNewUser() async {
    final response = await _client.get(
      Uri.parse(ApiConstants.isNewUser),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);

      if (decoded is bool) {
        return decoded;
      }

      if (decoded is Map<String, dynamic>) {
        final value = decoded['isNewUser'] ??
            decoded['newUser'] ??
            decoded['data'] ??
            decoded['result'];

        if (value is bool) return value;

        return value.toString().toLowerCase() == 'true';
      }

      return decoded.toString().toLowerCase() == 'true';
    }

    throw Exception(
      _extractErrorMessage(response.body, 'Failed to check user state'),
    );
  }

  Future<HomeData> getReturningUserHomeData() async {
    final selectedChild = await getSelectedChild();

    if (selectedChild == null) {
      return const HomeData();
    }

    final sessions = await getSessionsByChild(selectedChild.id);

    if (sessions.isEmpty) {
      return HomeData(
        selectedChild: selectedChild,
      );
    }

    final latestSession = _findLatestSession(sessions);
    final kitId = _extractKitId(latestSession);

    if (kitId == null || kitId == 0) {
      return HomeData(
        selectedChild: selectedChild,
      );
    }

    final sessionsForKit = sessions.where((session) {
      return _extractKitId(session) == kitId;
    }).toList();

    final activitiesDoneCount = sessionsForKit.where(_isCompletedSession).length;

    final activities = await getActivitiesByKit(kitId);
    final totalActivitiesCount = activities.length;

    KitModel? lastUsedKit;

    try {
      lastUsedKit = await _kitService.getKitById(kitId);
    } catch (_) {
      lastUsedKit = null;
    }

    final latestSessionForKit = _findLatestSession(sessionsForKit);
    final latestActivitySessionId = _extractActivitySessionId(latestSessionForKit);

    int currentLevel = 1;

    if (latestActivitySessionId != null && latestActivitySessionId != 0) {
      final attempts = await getLevelAttemptsByActivitySession(latestActivitySessionId);
      currentLevel = _getHighestLevelNumber(attempts);
    }

    return HomeData(
      selectedChild: selectedChild,
      lastUsedKit: lastUsedKit,
      activitiesDoneCount: activitiesDoneCount,
      totalActivitiesCount: totalActivitiesCount,
      currentLevel: currentLevel,
      latestActivitySessionId: latestActivitySessionId,
    );
  }

  Future<ChildModel?> getSelectedChild() async {
    final response = await _client.get(
      Uri.parse(ApiConstants.selectedChild),
    );

    if (response.statusCode == 404) {
      return null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.trim().isEmpty) {
        return null;
      }

      final decoded = jsonDecode(response.body);

      if (decoded == null) {
        return null;
      }

      if (decoded is Map<String, dynamic>) {
        final dynamic data = decoded['data'] ??
            decoded['child'] ??
            decoded['selectedChild'] ??
            decoded['result'] ??
            decoded;

        if (data is Map<String, dynamic>) {
          return ChildModel.fromJson(data);
        }
      }

      return null;
    }

    throw Exception(
      _extractErrorMessage(response.body, 'Failed to load selected child'),
    );
  }

  Future<List<Map<String, dynamic>>> getSessionsByChild(int childId) async {
    final response = await _client.get(
      Uri.parse(ApiConstants.sessionsByChild(childId)),
    );

    return _parseListResponse(
      response,
      fallbackError: 'Failed to load child sessions',
    );
  }

  Future<List<Map<String, dynamic>>> getActivitiesByKit(int kitId) async {
    final response = await _client.get(
      Uri.parse(ApiConstants.activitiesByKit(kitId)),
    );

    return _parseListResponse(
      response,
      fallbackError: 'Failed to load kit activities',
    );
  }

  Future<List<Map<String, dynamic>>> getLevelAttemptsByActivitySession(
      int activitySessionId,
      ) async {
    final response = await _client.get(
      Uri.parse(ApiConstants.levelAttemptsByActivitySession(activitySessionId)),
    );

    return _parseListResponse(
      response,
      fallbackError: 'Failed to load level attempts',
    );
  }

  List<Map<String, dynamic>> _parseListResponse(
      http.Response response, {
        required String fallbackError,
      }) {
    if (response.statusCode == 404) {
      return [];
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.trim().isEmpty) {
        return [];
      }

      final decoded = jsonDecode(response.body);

      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();
      }

      if (decoded is Map<String, dynamic>) {
        final dynamic data = decoded['data'] ??
            decoded['content'] ??
            decoded['sessions'] ??
            decoded['activities'] ??
            decoded['levelAttempts'] ??
            decoded['attempts'] ??
            decoded['result'] ??
            decoded['items'];

        if (data is List) {
          return data
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        }

        if (data is Map) {
          return [Map<String, dynamic>.from(data)];
        }
      }

      return [];
    }

    throw Exception(_extractErrorMessage(response.body, fallbackError));
  }

  Map<String, dynamic> _findLatestSession(List<Map<String, dynamic>> sessions) {
    if (sessions.isEmpty) {
      return {};
    }

    final sorted = List<Map<String, dynamic>>.from(sessions);

    sorted.sort((a, b) {
      final aDate = _extractDate(a);
      final bDate = _extractDate(b);

      if (aDate != null && bDate != null) {
        return bDate.compareTo(aDate);
      }

      final aId = _extractActivitySessionId(a) ?? 0;
      final bId = _extractActivitySessionId(b) ?? 0;

      return bId.compareTo(aId);
    });

    return sorted.first;
  }

  DateTime? _extractDate(Map<String, dynamic> session) {
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

    if (directKitId != null && directKitId != 0) {
      return directKitId;
    }

    final kit = session['kit'];
    if (kit is Map) {
      return _parseInt(kit['id'] ?? kit['kitId']);
    }

    final activity = session['activity'];
    if (activity is Map) {
      final activityKitId = _parseInt(activity['kitId'] ?? activity['kit_id']);
      if (activityKitId != null && activityKitId != 0) {
        return activityKitId;
      }

      final activityKit = activity['kit'];
      if (activityKit is Map) {
        return _parseInt(activityKit['id'] ?? activityKit['kitId']);
      }
    }

    return null;
  }

  int? _extractActivitySessionId(Map<String, dynamic> session) {
    return _parseInt(
      session['id'] ??
          session['activitySessionId'] ??
          session['activity_session_id'] ??
          session['sessionId'],
    );
  }

  bool _isCompletedSession(Map<String, dynamic> session) {
    final endedAt = session['endedAt'] ??
        session['ended_at'] ??
        session['completedAt'] ??
        session['completed_at'] ??
        session['endTime'];

    if (endedAt == null) {
      final status = session['status']?.toString().toLowerCase();
      return status == 'completed' || status == 'done' || status == 'finished';
    }

    return endedAt.toString().trim().isNotEmpty;
  }

  int _getHighestLevelNumber(List<Map<String, dynamic>> attempts) {
    if (attempts.isEmpty) {
      return 1;
    }

    int highest = 1;

    for (final attempt in attempts) {
      final level = _parseInt(
        attempt['levelNumber'] ??
            attempt['level_number'] ??
            attempt['level'] ??
            attempt['levelNo'],
      ) ??
          1;

      if (level > highest) {
        highest = level;
      }
    }

    return highest;
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
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