import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/api_constants.dart';
import '../../models/community/comment.dart';
import '../../models/community/create_comment.dart';
import '../auth/auth_api_client.dart';

class CommentService {
  final AuthApiClient _client = AuthApiClient();

  Future<List<Comment>> getCommentsByPost(int postId) async {
    final response = await _client.get(
      Uri.parse('${ApiConstants.commentsByPost}/$postId'),
    );

    return _parseCommentListResponse(
      response,
      fallbackError: 'Failed to load comments',
    );
  }

  Future<Comment> createComment(CreateComment dto) async {
    final response = await _client.post(
      Uri.parse(ApiConstants.comments),
      body: jsonEncode(dto.toJson()),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body);

      if (body is Map<String, dynamic>) {
        final dynamic actualData =
            body['data'] ?? body['result'] ?? body['comment'] ?? body;

        if (actualData is Map<String, dynamic>) {
          return Comment.fromJson(actualData);
        }
      }

      throw Exception('Unexpected create comment response format');
    }

    throw Exception(
      _extractErrorMessage(response.body, 'Failed to create comment'),
    );
  }

  Future<void> deleteComment(int id) async {
    final response = await _client.delete(
      Uri.parse('${ApiConstants.comments}/$id'),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw Exception(
      _extractErrorMessage(response.body, 'Failed to delete comment'),
    );
  }

  List<Comment> _parseCommentListResponse(
      http.Response response, {
        required String fallbackError,
      }) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body);

      if (body is List) {
        return body.map((item) => Comment.fromJson(item)).toList();
      }

      if (body is Map<String, dynamic>) {
        final dynamic data =
            body['data'] ??
                body['content'] ??
                body['comments'] ??
                body['result'] ??
                body['items'];

        if (data is List) {
          return data.map((item) => Comment.fromJson(item)).toList();
        }
      }

      throw Exception('Unexpected comments response format');
    }

    throw Exception(_extractErrorMessage(response.body, fallbackError));
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