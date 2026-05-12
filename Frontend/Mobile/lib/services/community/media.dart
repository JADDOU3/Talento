import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../core/config/api_constants.dart';
import '../auth/auth_api_client.dart';

class MediaService {
  final AuthApiClient _client = AuthApiClient();

  Future<String> uploadMedia(File file) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(ApiConstants.mediaUpload),
    );

    final headers = await _client.authHeaders(null);

    headers.remove('Content-Type');

    request.headers.addAll(headers);

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        file.path,
      ),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final body = jsonDecode(response.body);

      if (body is Map<String, dynamic>) {
        final dynamic s3Key =
            body['s3Key'] ??
                body['data']?['s3Key'] ??
                body['result']?['s3Key'];

        if (s3Key != null) {
          return s3Key.toString();
        }
      }

      throw Exception('Unexpected media upload response format');
    }

    throw Exception(
      _extractErrorMessage(response.body, 'Failed to upload media'),
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