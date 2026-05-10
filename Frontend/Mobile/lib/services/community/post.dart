import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/api_constants.dart';
import '../../models/community/create_post.dart';
import '../../models/community/post.dart';
import '../auth/auth_api_client.dart';

class PostService {
  final AuthApiClient _client = AuthApiClient();

  Future<List<Post>> getAllPosts() async {
    final uri = Uri.parse(ApiConstants.posts).replace(
      queryParameters: {
        'page': '0',
        'size': '10',
        'sort': 'createdAt,desc',
      },
    );

    final response = await _client.get(uri);

    return _parsePostListResponse(
      response,
      fallbackError: 'Failed to load posts',
    );
  }

  Future<List<Post>> getMyPosts() async {
    final uri = Uri.parse(ApiConstants.myPosts).replace(
      queryParameters: {
        'page': '0',
        'size': '10',
        'sort': 'createdAt,desc',
      },
    );

    final response = await _client.get(uri);

    return _parsePostListResponse(
      response,
      fallbackError: 'Failed to load my posts',
    );
  }

  Future<Post> getPostById(int id) async {
    final response = await _client.get(
      Uri.parse('${ApiConstants.posts}/$id'),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body);

      if (body is Map<String, dynamic>) {
        final dynamic actualData =
            body['data'] ?? body['result'] ?? body['post'] ?? body;

        if (actualData is Map<String, dynamic>) {
          return Post.fromJson(actualData);
        }
      }

      throw Exception('Unexpected post details response format');
    }

    throw Exception(
      _extractErrorMessage(response.body, 'Failed to load post details'),
    );
  }

  Future<List<Post>> getPostsByMindset(int mindsetId) async {
    final uri = Uri.parse('${ApiConstants.postsByMindset}/$mindsetId').replace(
      queryParameters: {
        'page': '0',
        'size': '10',
        'sort': 'createdAt,desc',
      },
    );

    final response = await _client.get(uri);

    return _parsePostListResponse(
      response,
      fallbackError: 'Failed to load posts by mindset',
    );
  }

  Future<List<Post>> getPostsByKit(int kitId) async {
    final uri = Uri.parse('${ApiConstants.postsByKit}/$kitId').replace(
      queryParameters: {
        'page': '0',
        'size': '10',
        'sort': 'createdAt,desc',
      },
    );

    final response = await _client.get(uri);

    return _parsePostListResponse(
      response,
      fallbackError: 'Failed to load posts by kit',
    );
  }

  Future<Post> createPost(CreatePost dto) async {
    final requestBody = dto.toJson();

    print('CREATE POST REQUEST: ${jsonEncode(requestBody)}');

    final response = await _client.post(
      Uri.parse(ApiConstants.posts),
      body: jsonEncode(requestBody),
    );

    print('CREATE POST STATUS: ${response.statusCode}');
    print('CREATE POST BODY: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.trim().isEmpty) {
        throw Exception('Post created but response body is empty');
      }

      final body = jsonDecode(response.body);

      if (body is Map<String, dynamic>) {
        final dynamic actualData =
            body['data'] ?? body['result'] ?? body['post'] ?? body;

        if (actualData is Map<String, dynamic>) {
          return Post.fromJson(actualData);
        }
      }

      throw Exception('Unexpected create post response format');
    }

    throw Exception(
      _extractErrorMessage(response.body, 'Failed to create post'),
    );
  }

  Future<void> deletePost(int id) async {
    final response = await _client.delete(
      Uri.parse('${ApiConstants.posts}/$id'),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw Exception(
      _extractErrorMessage(response.body, 'Failed to delete post'),
    );
  }

  List<Post> _parsePostListResponse(
      http.Response response, {
        required String fallbackError,
      }) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body);

      if (body is List) {
        return body.map((item) => Post.fromJson(item)).toList();
      }

      if (body is Map<String, dynamic>) {
        final dynamic data =
            body['content'] ??
                body['data'] ??
                body['posts'] ??
                body['result'] ??
                body['items'];

        if (data is List) {
          return data.map((item) => Post.fromJson(item)).toList();
        }
      }

      throw Exception('Unexpected posts response format');
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