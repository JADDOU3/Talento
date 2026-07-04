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
            return _parseInt(data['id']);
          }
        }
      }

      return null;
    } catch (e) {
      print('LIKE SELECTED CHILD ERROR: $e');
      return null;
    }
  }

  Future<int?> getCurrentParentId() async {
    try {
      final response = await _client.get(
        Uri.parse(ApiConstants.currentUser),
      );

      print('CURRENT PARENT STATUS: ${response.statusCode}');
      print('CURRENT PARENT BODY: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.trim().isEmpty) return null;

        final body = jsonDecode(response.body);

        if (body is Map<String, dynamic>) {
          final dynamic data =
              body['data'] ?? body['user'] ?? body['parent'] ?? body;

          if (data is Map<String, dynamic> && data['id'] != null) {
            return _parseInt(data['id']);
          }
        }
      }

      return null;
    } catch (e) {
      print('CURRENT PARENT ERROR: $e');
      return null;
    }
  }

  Future<bool> isPostLiked(int postId) async {
    final parentId = await getCurrentParentId();

    if (parentId == null) {
      print('CHECK LIKE ERROR: parentId is null');
      return false;
    }

    final url = ApiConstants.isPostLiked(postId, parentId);

    print('CHECK LIKE URL: $url');

    final response = await _client.get(
      Uri.parse(url),
    );

    print('CHECK LIKE STATUS: ${response.statusCode}');
    print('CHECK LIKE BODY: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return _parseLikedResponse(response.body);
    }

    throw Exception(
      _extractErrorMessage(response.body, 'Failed to check like status'),
    );
  }

  Future<String> toggleLike({
    required int postId,
    int? childId,
    int? parentId,
  }) async {
    final resolvedParentId = parentId ?? await getCurrentParentId();

    if (resolvedParentId == null) {
      throw Exception('Failed to toggle like: parentId is null');
    }

    final requestBody = {
      'postId': postId,
      'parentId': resolvedParentId,
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
      Uri.parse(ApiConstants.likeCount(postId)),
    );

    print('LIKE COUNT STATUS: ${response.statusCode}');
    print('LIKE COUNT BODY: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.trim().isEmpty) return 0;

      final body = jsonDecode(response.body);

      if (body is int) return body;
      if (body is num) return body.toInt();

      if (body is Map<String, dynamic>) {
        final dynamic count = body['data'] ??
            body['count'] ??
            body['likeCount'] ??
            body['result'] ??
            body['value'];

        final parsedCount = _parseInt(count);
        if (parsedCount != null) return parsedCount;
      }

      throw Exception('Unexpected like count response format');
    }

    throw Exception(
      _extractErrorMessage(response.body, 'Failed to load like count'),
    );
  }

  bool _parseLikedResponse(String body) {
    final bodyText = body.trim();

    if (bodyText.isEmpty) return false;

    final lowerBody = bodyText.toLowerCase();

    if (lowerBody == 'true') return true;
    if (lowerBody == 'false') return false;

    try {
      final decoded = jsonDecode(bodyText);

      if (decoded is bool) return decoded;

      if (decoded is Map<String, dynamic>) {
        final dynamic value = decoded['liked'] ??
            decoded['isLiked'] ??
            decoded['data'] ??
            decoded['result'] ??
            decoded['value'];

        if (value is bool) return value;
        if (value is String) return value.toLowerCase().trim() == 'true';
        if (value is num) return value != 0;

        if (value is Map<String, dynamic>) {
          final nestedValue = value['liked'] ??
              value['isLiked'] ??
              value['value'] ??
              value['result'];

          if (nestedValue is bool) return nestedValue;
          if (nestedValue is String) {
            return nestedValue.toLowerCase().trim() == 'true';
          }
          if (nestedValue is num) return nestedValue != 0;
        }
      }
    } catch (e) {
      print('CHECK LIKE PARSE ERROR: $e');
    }

    return false;
  }

  int? _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
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