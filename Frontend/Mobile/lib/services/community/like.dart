import 'dart:convert';

import '../../core/config/api_constants.dart';
import '../auth/auth_api_client.dart';

class LikeService {
  final AuthApiClient _client = AuthApiClient();

  Future<int?> getSelectedChildId() async {
    try {
      final response = await _client.get(
        Uri.parse(ApiConstants.selectedChild),
      );

      print('LIKE SELECTED CHILD STATUS: ${response.statusCode}');
      print('LIKE SELECTED CHILD BODY: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.trim().isEmpty) return null;

        final body = jsonDecode(response.body);

        if (body is Map<String, dynamic>) {
          final dynamic data =
              body['data'] ?? body['child'] ?? body['result'] ?? body;

          if (data is Map<String, dynamic> && data['id'] != null) {
            final id = data['id'];

            if (id is int) return id;
            if (id is num) return id.toInt();
            if (id is String) return int.tryParse(id);
          }
        }
      }

      return null;
    } catch (e) {
      print('LIKE SELECTED CHILD ERROR: $e');
      return null;
    }
  }

  Future<String> toggleLike({
    required int postId,
    required int childId,
  }) async {
    final requestBody = {
      'postId': postId,
      'childId': childId,
    };

    final response = await _client.post(
      Uri.parse(ApiConstants.likesToggle),
      body: jsonEncode(requestBody),
    );

    print('TOGGLE LIKE REQUEST: ${jsonEncode(requestBody)}');
    print('TOGGLE LIKE STATUS: ${response.statusCode}');
    print('TOGGLE LIKE BODY: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body.trim();
    }

    throw Exception(
      _extractErrorMessage(response.body, 'Failed to toggle like'),
    );
  }

  Future<int> getLikeCount(int postId) async {
    final response = await _client.get(
      Uri.parse('${ApiConstants.likesPost}/$postId/count'),
    );

    print('LIKE COUNT STATUS: ${response.statusCode}');
    print('LIKE COUNT BODY: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body);

      if (body is int) {
        return body;
      }

      if (body is Map<String, dynamic>) {
        final dynamic count =
            body['data'] ??
                body['count'] ??
                body['likeCount'] ??
                body['result'];

        if (count is int) {
          return count;
        }

        if (count is num) {
          return count.toInt();
        }
      }

      throw Exception('Unexpected like count response format');
    }

    throw Exception(
      _extractErrorMessage(response.body, 'Failed to load like count'),
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