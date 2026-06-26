import 'dart:convert';

import '../../core/config/api_constants.dart';
import '../../models/activities/story_spinner/story_submission_model.dart';
import '../auth/auth_api_client.dart';

class StorySubmissionRepository {
  final AuthApiClient _client;

  StorySubmissionRepository({AuthApiClient? client})
      : _client = client ?? AuthApiClient();

  Future<int> getStoryCount(int activityId, int childId) async {
    final url = ApiConstants.storySubmissionCountByActivityAndChild(
      activityId,
      childId,
    );

    final response = await _client.get(Uri.parse(url));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.trim().isEmpty) return 0;

      final decoded = jsonDecode(response.body);

      if (decoded is num) return decoded.toInt();

      if (decoded is Map<String, dynamic>) {
        return _parseInt(decoded['count'] ?? decoded['storyCount']);
      }

      return 0;
    }

    throw Exception(
      _extractErrorMessage(
        response.body,
        'Failed to load story count',
      ),
    );
  }

  Future<List<StorySubmission>> getStoriesByActivityAndChild(
      int activityId,
      int childId,
      ) async {
    final url = ApiConstants.storySubmissionsByActivityAndChild(
      activityId,
      childId,
    );

    final response = await _client.get(Uri.parse(url));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.trim().isEmpty) return <StorySubmission>[];

      final decoded = jsonDecode(response.body);

      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map(
              (item) => StorySubmission.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
            .toList();
      }

      return <StorySubmission>[];
    }

    throw Exception(
      _extractErrorMessage(
        response.body,
        'Failed to load stories',
      ),
    );
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
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