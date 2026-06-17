import 'dart:convert';

import 'package:flutter/foundation.dart';
import '../../core/config/api_constants.dart';
import '../../models/roadmap/activity_progress_model.dart';
import '../../models/roadmap/roadmap_model.dart';
import '../auth/auth_api_client.dart';

class RoadmapService {
  final AuthApiClient _client = AuthApiClient();

  Future<RoadmapModel> getRoadmap({
    required int kitId,
    required int childId,
  }) async {
    final url = ApiConstants.roadmapByKitAndChild(kitId, childId);

    debugPrint('ROADMAP URL: $url');

    final response = await _client.get(
      Uri.parse(url),
    );

    debugPrint('ROADMAP RESPONSE: ${response.statusCode} - ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.trim().isEmpty) {
        debugPrint('ROADMAP EMPTY BODY');

        return const RoadmapModel(
          kitId: 0,
          kitName: '',
          kitImageUrl: '',
          activities: [],
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        final roadmap = RoadmapModel.fromJson(decoded);

        for (final activity in roadmap.activities) {
          debugPrint(
            'ROADMAP ACTIVITY => '
                'id=${activity.activityId}, '
                'name=${activity.activityName}, '
                'status=${activity.status}, '
                'currentLevel=${activity.currentLevelNumber}, '
                'completedLevels=${activity.completedLevels}, '
                'totalLevels=${activity.totalLevels}, '
                'isCompleted=${activity.isCompleted}',
          );
        }

        debugPrint('ROADMAP KIT ID: ${roadmap.kitId}');
        debugPrint('ROADMAP KIT NAME: ${roadmap.kitName}');
        debugPrint('ROADMAP ACTIVITIES COUNT: ${roadmap.activities.length}');

        return roadmap;
      }

      throw Exception('Invalid roadmap response');
    }

    throw Exception(
      _extractErrorMessage(
        response.body,
        'Failed to load roadmap',
      ),
    );
  }

  Future<ActivityProgressModel?> getActivityProgress({
    required int activityId,
  }) async {
    final url = ApiConstants.roadmapProgress(activityId);

    debugPrint('ACTIVITY PROGRESS URL: $url');

    final response = await _client.get(
      Uri.parse(url),
    );

    debugPrint(
      'ACTIVITY PROGRESS RESPONSE: ${response.statusCode} - ${response.body}',
    );

    // Backend note: if progress does not exist yet, we should start from Level 1.
    if (response.statusCode == 404) {
      debugPrint('ACTIVITY PROGRESS NOT FOUND, FALLBACK TO LEVEL 1');
      return null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.trim().isEmpty) {
        debugPrint('ACTIVITY PROGRESS EMPTY BODY, FALLBACK TO LEVEL 1');
        return null;
      }

      final decoded = jsonDecode(response.body);

      if (decoded == null) {
        debugPrint('ACTIVITY PROGRESS NULL BODY, FALLBACK TO LEVEL 1');
        return null;
      }

      if (decoded is Map<String, dynamic>) {
        return ActivityProgressModel.fromJson(decoded);
      }

      debugPrint('INVALID ACTIVITY PROGRESS RESPONSE, FALLBACK TO LEVEL 1');
      return null;
    }

    throw Exception(
      _extractErrorMessage(
        response.body,
        'Failed to load activity progress',
      ),
    );
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