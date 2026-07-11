import 'dart:convert';

import '../../core/config/api_constants.dart';
import '../../models/voice_over/voice_over_model.dart';
import '../auth/auth_api_client.dart';

class VoiceOverService {
  final AuthApiClient _client;

  VoiceOverService({
    AuthApiClient? client,
  }) : _client = client ?? AuthApiClient();

  Future<VoiceOverModel> getGlobalVoiceOver(
    GlobalVoiceOverType type,
  ) async {
    final response = await _client.get(
      Uri.parse(
        ApiConstants.globalVoiceOver(type.apiValue),
      ),
    );

    return _parseResponse(
      statusCode: response.statusCode,
      body: response.body,
      requestName: 'global ${type.apiValue}',
    );
  }

  Future<VoiceOverModel> getActivityIntroVoiceOver(
    int activityId,
  ) async {
    final response = await _client.get(
      Uri.parse(
        ApiConstants.activityVoiceOver(activityId),
      ),
    );

    return _parseResponse(
      statusCode: response.statusCode,
      body: response.body,
      requestName: 'activity $activityId intro',
    );
  }

  Future<VoiceOverModel> getActivityLevelVoiceOver({
    required int activityId,
    required int levelId,
  }) async {
    final uri = Uri.parse(
      ApiConstants.activityVoiceOver(activityId),
    ).replace(
      queryParameters: {
        'level': levelId.toString(),
      },
    );

    final response = await _client.get(uri);

    return _parseResponse(
      statusCode: response.statusCode,
      body: response.body,
      requestName: 'activity $activityId level $levelId',
    );
  }

  VoiceOverModel _parseResponse({
    required int statusCode,
    required String body,
    required String requestName,
  }) {
    if (statusCode < 200 || statusCode >= 300) {
      throw Exception(
        'Voice-over request failed for $requestName '
        'with status $statusCode.',
      );
    }

    if (body.trim().isEmpty) {
      throw Exception(
        'Voice-over response is empty for $requestName.',
      );
    }

    final decoded = jsonDecode(body);

    if (decoded is! Map) {
      throw Exception(
        'Voice-over response is invalid for $requestName.',
      );
    }

    return VoiceOverModel.fromJson(
      Map<String, dynamic>.from(decoded),
    );
  }
}
