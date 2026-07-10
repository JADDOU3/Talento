import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/api_constants.dart';
import '../../cubits/home/home_data.dart';
import '../../models/childmode/child_model.dart';
import '../../models/home/daily_challenge_model.dart';
import '../../models/home/last_reached_activity_model.dart';
import '../../models/kit/kit_model.dart';
import '../auth/auth_api_client.dart';
import '../kit/kit_service.dart';

class HomeService {
  final AuthApiClient _client = AuthApiClient();
  final KitService _kitService = KitService();

  Future<bool> isNewUser() async {
    final uri = Uri.parse(ApiConstants.isNewUser);

    final response = await _client.get(uri);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = _decodeJson(response);

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
      final partialResults = await Future.wait<dynamic>([
        getLastReachedActivity(),
        getCompletedActivitiesCount(),
        getDailyChallenge(),
      ]);

      final lastReachedActivity =
      partialResults[0] as LastReachedActivityModel?;
      final completedActivities = partialResults[1] as int;
      final dailyChallenge = partialResults[2] as DailyChallengeModel?;

      return HomeData(
        selectedChild: selectedChild,
        activitiesDoneCount: completedActivities,
        currentLevel: lastReachedActivity?.currentLevelNumber ?? 1,
        lastReachedActivity: lastReachedActivity,
        dailyChallenge: dailyChallenge,
        challengeAnswered: _challengeAnsweredFrom(dailyChallenge),
        challengeCorrect: _challengeCorrectFrom(dailyChallenge),
        correctAnswer: _challengeCorrectAnswerFrom(dailyChallenge),
      );
    }

    final latestSession = _findLatestSession(sessions);
    final kitId = _extractKitId(latestSession);

    if (kitId == null || kitId == 0) {
      final partialResults = await Future.wait<dynamic>([
        getLastReachedActivity(),
        getCompletedActivitiesCount(),
        getDailyChallenge(),
      ]);

      final lastReachedActivity =
      partialResults[0] as LastReachedActivityModel?;
      final completedActivities = partialResults[1] as int;
      final dailyChallenge = partialResults[2] as DailyChallengeModel?;

      return HomeData(
        selectedChild: selectedChild,
        activitiesDoneCount: completedActivities,
        currentLevel: lastReachedActivity?.currentLevelNumber ?? 1,
        lastReachedActivity: lastReachedActivity,
        dailyChallenge: dailyChallenge,
        challengeAnswered: _challengeAnsweredFrom(dailyChallenge),
        challengeCorrect: _challengeCorrectFrom(dailyChallenge),
        correctAnswer: _challengeCorrectAnswerFrom(dailyChallenge),
      );
    }

    final results = await Future.wait<dynamic>([
      getLastReachedActivity(),
      getCompletedActivitiesCount(),
      _kitService.getActivitiesCountByKitId(kitId),
      getDailyChallenge(),
      _safeGetKitById(kitId),
    ]);

    final lastReachedActivity = results[0] as LastReachedActivityModel?;
    final completedActivities = results[1] as int;
    final totalActivities = results[2] as int;
    final dailyChallenge = results[3] as DailyChallengeModel?;
    final lastUsedKit = results[4] as KitModel?;

    final latestSessionForKit = _findLatestSession(
      sessions.where((session) => _extractKitId(session) == kitId).toList(),
    );

    final latestActivitySessionId =
    _extractActivitySessionId(latestSessionForKit);

    return HomeData(
      selectedChild: selectedChild,
      lastUsedKit: lastUsedKit,
      activitiesDoneCount: completedActivities,
      totalActivitiesCount: totalActivities,
      currentLevel: lastReachedActivity?.currentLevelNumber ?? 1,
      latestActivitySessionId: latestActivitySessionId,
      lastReachedActivity: lastReachedActivity,
      dailyChallenge: dailyChallenge,
      challengeAnswered: _challengeAnsweredFrom(dailyChallenge),
      challengeCorrect: _challengeCorrectFrom(dailyChallenge),
      correctAnswer: _challengeCorrectAnswerFrom(dailyChallenge),
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

      final decoded = _decodeJson(response);

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

  Future<LastReachedActivityModel?> getLastReachedActivity() async {
    final response = await _client.get(
      Uri.parse(ApiConstants.roadmapLastReached),
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
          'lastReached',
          'lastReachedActivity',
          'activity',
          'result',
        ],
      );

      if (data == null) return null;

      final model = LastReachedActivityModel.fromJson(data);

      return model.isValid ? model : null;
    }

    throw Exception(
      _extractErrorMessage(response.body, 'Failed to load last activity'),
    );
  }

  Future<int> getCompletedActivitiesCount() async {
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
      _extractErrorMessage(response.body, 'Failed to load completed count'),
    );
  }

  Future<List<Map<String, dynamic>>> getRoadmapActivitiesByKitAndChild(
      int kitId,
      int childId,
      ) async {
    final response = await _client.get(
      Uri.parse(ApiConstants.roadmapByKitAndChild(kitId, childId)),
    );

    if (response.statusCode == 404 || response.body.trim().isEmpty) {
      return [];
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = _decodeJson(response);
      return _extractActivitiesFromRoadmap(decoded);
    }

    throw Exception(
      _extractErrorMessage(response.body, 'Failed to load roadmap activities'),
    );
  }

  Future<DailyChallengeModel?> getDailyChallenge() async {
    final response = await _client.get(
      Uri.parse(ApiConstants.dailyChallenge),
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
          'dailyChallenge',
          'challenge',
          'result',
        ],
      );

      if (data == null) return null;

      final model = DailyChallengeModel.fromJson(data);

      return model.isValid ? model : null;
    }

    throw Exception(
      _extractErrorMessage(response.body, 'Failed to load daily challenge'),
    );
  }

  Future<DailyChallengeAnswerModel> submitDailyChallengeAnswer(
      int challengeId,
      String answer,
      ) async {
    final response = await _client.post(
      Uri.parse(ApiConstants.dailyChallengeAnswer),
      body: jsonEncode({
        'challengeId': challengeId,
        'answer': answer,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.trim().isEmpty) {
        return const DailyChallengeAnswerModel(
          correct: false,
          correctAnswer: null,
        );
      }

      final decoded = _decodeJson(response);

      final data = _unwrapObject(
        decoded,
        keys: [
          'data',
          'result',
          'answer',
        ],
      ) ??
          <String, dynamic>{};

      return DailyChallengeAnswerModel.fromJson(data);
    }

    throw Exception(
      _extractErrorMessage(response.body, 'Failed to submit challenge answer'),
    );
  }

  Future<KitModel?> _safeGetKitById(int kitId) async {
    try {
      return await _kitService.getKitById(kitId);
    } catch (_) {
      return null;
    }
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

      final decoded = _decodeJson(response);

      if (decoded is List) {
        return _mapList(decoded);
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
          return _mapList(data);
        }

        if (data is Map) {
          return [Map<String, dynamic>.from(data)];
        }
      }

      return [];
    }

    throw Exception(_extractErrorMessage(response.body, fallbackError));
  }

  List<Map<String, dynamic>> _extractActivitiesFromRoadmap(dynamic decoded) {
    if (decoded is List) {
      return _mapList(decoded);
    }

    if (decoded is Map<String, dynamic>) {
      final directActivities = decoded['activities'] ??
          decoded['roadmapActivities'] ??
          decoded['activityList'] ??
          decoded['items'];

      if (directActivities is List) {
        return _mapList(directActivities);
      }

      final data = decoded['data'] ??
          decoded['roadmap'] ??
          decoded['result'] ??
          decoded['content'];

      if (data is List) {
        return _mapList(data);
      }

      if (data is Map<String, dynamic>) {
        final nestedActivities = data['activities'] ??
            data['roadmapActivities'] ??
            data['activityList'] ??
            data['items'];

        if (nestedActivities is List) {
          return _mapList(nestedActivities);
        }
      }
    }

    return [];
  }

  List<Map<String, dynamic>> _mapList(List<dynamic> list) {
    return list
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }

  Map<String, dynamic>? _unwrapObject(
      dynamic decoded, {
        required List<String> keys,
      }) {
    if (decoded == null) return null;

    if (decoded is Map<String, dynamic>) {
      for (final key in keys) {
        if (decoded.containsKey(key)) {
          final value = decoded[key];

          if (value == null) {
            return null;
          }

          if (value is Map) {
            return Map<String, dynamic>.from(value);
          }
        }
      }

      return decoded;
    }

    return null;
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

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  dynamic _decodeJson(http.Response response) {
    final decodedBody = utf8.decode(response.bodyBytes);
    return jsonDecode(decodedBody);
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

  bool _challengeAnsweredFrom(DailyChallengeModel? dailyChallenge) {
    return dailyChallenge?.alreadyAnswered ?? false;
  }

  bool _challengeCorrectFrom(DailyChallengeModel? dailyChallenge) {
    return dailyChallenge?.correct ?? false;
  }

  String? _challengeCorrectAnswerFrom(DailyChallengeModel? dailyChallenge) {
    return dailyChallenge?.correctAnswer;
  }
}