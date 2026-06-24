import 'package:http/http.dart' as http;
import 'auth_service.dart';
import 'token_storage_service.dart';

class AuthApiClient {
  final AuthService _authService = AuthService();

  Future<http.Response> get(Uri uri, {Map<String, String>? headers}) async {
    return _sendWithRefresh(
          () async => http.get(uri, headers: await authHeaders(headers)),
          () async => http.get(uri, headers: await authHeaders(headers)),
    );
  }

  Future<http.Response> post(
      Uri uri, {
        Map<String, String>? headers,
        Object? body,
      }) async {
    return _sendWithRefresh(
          () async => http.post(
        uri,
        headers: await authHeaders(headers),
        body: body,
      ),
          () async => http.post(
        uri,
        headers: await authHeaders(headers),
        body: body,
      ),
    );
  }


  Future<http.Response> put(
      Uri uri, {
        Map<String, String>? headers,
        Object? body,
      }) async {
    return _sendWithRefresh(
          () async => http.put(
        uri,
        headers: await authHeaders(headers),
        body: body,
      ),
          () async => http.put(
        uri,
        headers: await authHeaders(headers),
        body: body,
      ),
    );
  }


  Future<http.Response> patch(
      Uri uri, {
        Map<String, String>? headers,
        Object? body,
      }) async {
    return _sendWithRefresh(
          () async => http.patch(
        uri,
        headers: await authHeaders(headers),
        body: body,
      ),
          () async => http.patch(
        uri,
        headers: await authHeaders(headers),
        body: body,
      ),
    );
  }

  Future<http.Response> delete(
      Uri uri, {
        Map<String, String>? headers,
      }) async {
    return _sendWithRefresh(
          () async => http.delete(uri, headers: await authHeaders(headers)),
          () async => http.delete(uri, headers: await authHeaders(headers)),
    );
  }

  Future<http.Response> multipartPost(
      Uri uri, {
        required Future<void> Function(http.MultipartRequest request) buildRequest,
      }) async {
    Future<http.Response> sendRequest() async {
      final request = http.MultipartRequest('POST', uri);
      final headers = await authHeaders(null);

      // MultipartRequest must generate its own Content-Type with boundary.
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      await buildRequest(request);

      final streamedResponse = await request.send();
      return http.Response.fromStream(streamedResponse);
    }

    return _sendWithRefresh(sendRequest, sendRequest);
  }

  Future<http.Response> _sendWithRefresh(
      Future<http.Response> Function() request,
      Future<http.Response> Function() retryRequest,
      ) async {
    final response = await request();

    if (response.statusCode != 401) {
      return response;
    }

    print('REQUEST GOT 401, TRYING REFRESH TOKEN...');

    final refreshed = await _authService.refreshToken();

    print('REFRESH RESULT: $refreshed');

    if (!refreshed) {
      await TokenStorageService.clearTokens();
      throw Exception('Session expired. Please login again.');
    }

    return await retryRequest();
  }

  Future<Map<String, String>> authHeaders(
      Map<String, String>? extraHeaders,
      ) async {
    final accessToken = await TokenStorageService.getAccessToken();

    return {
      'Content-Type': 'application/json',
      if (accessToken != null && accessToken.isNotEmpty)
        'Authorization': 'Bearer $accessToken',
      ...?extraHeaders,
    };
  }
}
