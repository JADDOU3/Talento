import 'dart:convert';

import '../../core/config/api_constants.dart';
import '../auth/auth_api_client.dart';

class LikeService {
  final AuthApiClient _client = AuthApiClient();

  Future<void> toggleLike(int postId) async {
    final response = await _client.post(
      Uri.parse(ApiConstants.likesToggle),
      body: jsonEncode({
        'postId': postId,
      }),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw Exception(
      _extractErrorMessage(response.body, 'Failed to toggle like'),
    );
  }

  Future<int> getLikeCount(int postId) async {
    final response = await _client.get(
      Uri.parse('${ApiConstants.likesPost}/$postId/count'),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body);

      if (body is int) {
        return body;
      }

      if (body is Map<String, dynamic>) {
        final dynamic count =
            body['data'] ?? body['count'] ?? body['likeCount'] ?? body['result'];

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