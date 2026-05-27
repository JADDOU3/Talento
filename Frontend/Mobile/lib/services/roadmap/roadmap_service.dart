import 'dart:convert';

import '../../core/config/api_constants.dart';
import '../../models/roadmap/roadmap_model.dart';
import '../auth/auth_api_client.dart';

class RoadmapService {
  final AuthApiClient _client = AuthApiClient();

  Future<RoadmapModel> getRoadmap({
    required int kitId,
    required int childId,
  }) async {
    final response = await _client.get(
      Uri.parse(ApiConstants.roadmapByKitAndChild(kitId, childId)),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.trim().isEmpty) {
        return const RoadmapModel(
          kitId: 0,
          kitName: '',
          kitImageUrl: '',
          activities: [],
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return RoadmapModel.fromJson(decoded);
      }

      throw Exception('Invalid roadmap response');
    }

    throw Exception(
      _extractErrorMessage(response.body, 'Failed to load roadmap'),
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