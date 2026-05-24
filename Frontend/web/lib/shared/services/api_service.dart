import 'dart:convert';
import 'dart:html' as html;
import '../models/cart_model.dart';

import 'package:flutter/foundation.dart';

import '../models/cart_model.dart';
import 'api_result.dart';

class ApiService {
  /// Override for local backend: `--dart-define=API_BASE_URL=http://localhost:8080/api`
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://15.224.101.253/api',
  );

  static const String _basicAuthUsername = 'test';
  static const String _basicAuthPassword = 'test';

  /// Keys added by [postPublic] on every completed HTTP response.
  static const String _kHttpSuccess = '_success';
  static const String _kHttpStatus = '_statusCode';

  static String get _basicAuthHeader {
    final credentials = '$_basicAuthUsername:$_basicAuthPassword';
    final encoded = base64.encode(utf8.encode(credentials));
    return 'Basic $encoded';
  }

  /// Spring `/register` returns a **plain text** body (not JSON). This parses JSON objects,
  /// JSON strings, or falls back to `{ "message": "<raw>" }`.
  static Map<String, dynamic> decodeResponseBody(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return {};
    }
    final t = raw.trim();
    try {
      final decoded = json.decode(t);
      if (decoded is Map<String, dynamic>) {
        return Map<String, dynamic>.from(decoded);
      }
      if (decoded is String) {
        return {'message': decoded};
      }
      return {'message': decoded.toString()};
    } catch (_) {
      return {'message': t};
    }
  }

  /// Human-readable message from a decoded response map (excludes our meta keys).
  static String userFacingMessage(Map<String, dynamic> response) {
    final r = Map<String, dynamic>.from(response)
      ..remove(_kHttpSuccess)
      ..remove(_kHttpStatus);

    final m = r['message'];
    if (m != null && m.toString().trim().isNotEmpty) {
      return m.toString().trim();
    }
    final err = r['error'];
    if (err != null && err.toString().trim().isNotEmpty) {
      return err.toString().trim();
    }

    final errs = r['errors'];
    if (errs is Map) {
      final parts = <String>[];
      for (final e in errs.entries) {
        final v = e.value;
        if (v is List) {
          parts.add(v.map((x) => x.toString()).join(', '));
        } else {
          parts.add(v.toString());
        }
      }
      final joined = parts.where((s) => s.isNotEmpty).join('; ');
      if (joined.isNotEmpty) return joined;
    }

    return '';
  }

  /// True when the server responded with HTTP 2xx (set by [postPublic]).
  static bool isSuccessfulHttp(Map<String, dynamic> response) =>
      response[_kHttpSuccess] == true;

  static int httpStatusOf(Map<String, dynamic> response) {
    final code = response[_kHttpStatus];
    return code is int ? code : 0;
  }

  static dynamic _decodeJson(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    try {
      return json.decode(raw);
    } catch (e) {
      if (kDebugMode) debugPrint('[ApiService] JSON decode failed: $e');
      return null;
    }
  }

  /// Authenticated GET with status code (for kit details, reviews, cart).
  static Future<ApiResult> getWithStatus(String endpoint) async {
    try {
      final token = await LocalStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        return const ApiResult(status: 401, body: null);
      }

      final request = await html.HttpRequest.request(
        '$baseUrl$endpoint',
        method: 'GET',
        requestHeaders: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      final status = request.status ?? 0;
      final raw = request.responseText;
      if (kDebugMode) {
        debugPrint('[ApiService] GET $endpoint -> $status');
      }
      return ApiResult(
        status: status,
        body: _decodeJson(raw),
        rawText: raw,
      );
    } catch (e, st) {
      if (kDebugMode) debugPrint('[ApiService] GET $endpoint failed: $e\n$st');
      return const ApiResult(status: 0, body: null);
    }
  }

  // ✅ GET مع Bearer Token
  static Future<Map<String, dynamic>?> get(String endpoint) async {
    final result = await getWithStatus(endpoint);
    if (result.isSuccess && result.body is Map<String, dynamic>) {
      return Map<String, dynamic>.from(result.body as Map);
    }
    if (result.isSuccess && result.body is List) {
      return {'items': result.body};
    }
    return null;
  }

  static Future<ApiResult> postWithStatus(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final token = await LocalStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        return const ApiResult(status: 401, body: null);
      }

      final request = await html.HttpRequest.request(
        '$baseUrl$endpoint',
        method: 'POST',
        sendData: json.encode(body),
        requestHeaders: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      final status = request.status ?? 0;
      final raw = request.responseText;
      return ApiResult(
        status: status,
        body: _decodeJson(raw),
        rawText: raw,
      );
    } catch (e, st) {
      if (kDebugMode) debugPrint('[ApiService] POST $endpoint failed: $e\n$st');
      return const ApiResult(status: 0, body: null);
    }
  }

  static Future<ApiResult> deleteWithStatus(String endpoint) async {
    try {
      final token = await LocalStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        return const ApiResult(status: 401, body: null);
      }

      final request = await html.HttpRequest.request(
        '$baseUrl$endpoint',
        method: 'DELETE',
        requestHeaders: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));
      final status = request.status;
      if (status != null && status >= 200 && status < 300) {
        final responseText = request.responseText;
        if (responseText != null && responseText.isNotEmpty) {
          return json.decode(responseText);
        }
        return {};
      }
      return null;
    } catch (e) {
      return null;
    }
  }

      return ApiResult(
        status: request.status ?? 0,
        body: _decodeJson(request.responseText),
        rawText: request.responseText,
      );
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[ApiService] DELETE $endpoint failed: $e\n$st');
      }
      return const ApiResult(status: 0, body: null);
    }
  }

  // ✅ POST مع Basic Auth — للـ login و register (public)
  static Future<Map<String, dynamic>?> postPublic(
      String endpoint, Map<String, dynamic> body) async {
    try {
      final request = await _sendPublicPost('$baseUrl$endpoint', body);

      final status = request.status ?? 0;
      final parsed = decodeResponseBody(request.responseText);
      final ok = status >= 200 && status < 300;

      if (kDebugMode) {
        debugPrint(
          '[ApiService] POST $endpoint -> HTTP $status body=$parsed',
        );
      }

      return {
        ...parsed,
        _kHttpStatus: status,
        _kHttpSuccess: ok,
      };
    } on html.ProgressEvent catch (e, st) {
      debugPrint(
        '[ApiService] POST $endpoint blocked (CORS/network): '
        '${requestFailureHint(e)}\n$st',
      );
      return null;
    } catch (e, st) {
      debugPrint('[ApiService] POST $endpoint failed: $e\n$st');
      return null;
    }
  }

  static Future<html.HttpRequest> _sendPublicPost(
    String url,
    Map<String, dynamic> body,
  ) async {
    final request = html.HttpRequest();
    request.open('POST', url, async: true);
    request.withCredentials = false;
    request.setRequestHeader('Content-Type', 'application/json');
    request.setRequestHeader('Authorization', _basicAuthHeader);
    request.send(json.encode(body));
    await request.onLoadEnd.first.timeout(const Duration(seconds: 15));
    if (request.status == 0 && (request.responseText ?? '').isEmpty) {
      throw StateError('network-or-cors');
    }
    return request;
  }

  static String requestFailureHint(Object event) {
    return 'origin blocked or server unreachable (deploy CORS fix on API or use '
        '--dart-define=API_BASE_URL=http://localhost:8080/api)';
  }

  // ✅ POST مع Bearer Token — للـ endpoints المحمية
  static Future<Map<String, dynamic>?> post(
      String endpoint, Map<String, dynamic> body) async {
    final result = await postWithStatus(endpoint, body);
    if (result.isSuccess) {
      if (result.body is Map<String, dynamic>) {
        return Map<String, dynamic>.from(result.body as Map);
      }
      return {};
    }
    return null;
  }

  static Future<String?> getAccessToken() async {
    return await LocalStorage.getAccessToken();
  }

  // ===== CART =====

  static Future<Map<String, dynamic>> getCart() async {
    final result = await getWithStatus('/cart/');
    if (result.isNotFound) {
      return {'success': false, 'notFound': true};
    }
    if (result.isUnauthorized) {
      return {'success': false, 'message': 'Unauthorized'};
    }
    if (result.isNetworkFailure) {
      return {'success': false, 'message': 'Network error'};
    }
    if (result.isSuccess && result.body is Map<String, dynamic>) {
      return {
        'success': true,
        'cart': CartModel.fromJson(result.body as Map<String, dynamic>),
      };
    }
    return {
      'success': false,
      'message': decodeResponseBody(result.rawText)['message'] ??
          'Failed to load cart',
    };
  }

  static Future<Map<String, dynamic>> createCart() async {
    final result = await postWithStatus('/cart/', {});
    if (result.isSuccess) return {'success': true};
    return {
      'success': false,
      'message': decodeResponseBody(result.rawText)['message'] ??
          'Failed to create cart',
    };
  }

  static Future<Map<String, dynamic>> addCartItem({
    required int kitId,
    required int quantity,
  }) async {
    final result =
        await postWithStatus('/cart/items', {'kitId': kitId, 'quantity': quantity});
    if (result.isSuccess) return {'success': true};
    return {
      'success': false,
      'message':
          decodeResponseBody(result.rawText)['message'] ?? 'Failed to add item',
    };
  }

  /// Ensures a cart exists, then adds a kit line item.
  static Future<Map<String, dynamic>> ensureCartAndAddItem({
    required int kitId,
    required int quantity,
  }) async {
    var cartResult = await getCart();
    if (cartResult['notFound'] == true) {
      final created = await createCart();
      if (created['success'] != true) return created;
      cartResult = await getCart();
    }
    if (cartResult['success'] != true) {
      return {
        'success': false,
        'message': cartResult['message'] ?? 'Could not access cart',
      };
    }
    return addCartItem(kitId: kitId, quantity: quantity);
  }
}

class LocalStorage {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  static Future<String?> getAccessToken() async =>
      html.window.localStorage[_accessTokenKey];

  static Future<void> setAccessToken(String token) async =>
      html.window.localStorage[_accessTokenKey] = token;

  static Future<String?> getRefreshToken() async =>
      html.window.localStorage[_refreshTokenKey];

  static Future<void> setRefreshToken(String token) async =>
      html.window.localStorage[_refreshTokenKey] = token;

  static Future<void> clear() async {
    html.window.localStorage.remove(_accessTokenKey);
    html.window.localStorage.remove(_refreshTokenKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = html.window.localStorage[_accessTokenKey];
    return token != null && token.isNotEmpty;
  }
}