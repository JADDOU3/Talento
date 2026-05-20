import 'dart:convert';
import 'dart:html' as html;
import '../models/cart_model.dart';

class ApiService {
  static const String baseUrl = 'http://15.224.101.253/api';

  static const String _basicAuthUsername = 'test';
  static const String _basicAuthPassword = 'test';

  static String get _basicAuthHeader {
    final credentials = '$_basicAuthUsername:$_basicAuthPassword';
    final encoded = base64.encode(utf8.encode(credentials));
    return 'Basic $encoded';
  }

  // ✅ Register
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String gender,
    required String password,
  }) async {
    try {
      final response = await postPublic('/register', {
        'name': name,
        'email': email,
        'gender': gender,
        'password': password,
      });
      final token = response?['accessToken'];
      if (response != null && token != null) {
        await LocalStorage.setAccessToken(token);
        if (response['refreshToken'] != null) {
          await LocalStorage.setRefreshToken(response['refreshToken']);
        }
        return {'success': true, 'message': 'Account created successfully!'};
      }
      return {'success': false, 'message': response?['message'] ?? 'Registration failed'};
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong'};
    }
  }

  // ✅ Login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await postPublic('/login', {
        'username': email,
        'password': password,
      });
      final token = response?['accessToken'];
      if (response != null && token != null) {
        await LocalStorage.setAccessToken(token);
        if (response['refreshToken'] != null) {
          await LocalStorage.setRefreshToken(response['refreshToken']);
        }
        return {'success': true, 'message': 'Login successful!'};
      }
      return {'success': false, 'message': response?['message'] ?? 'Invalid credentials'};
    } catch (e) {
      return {'success': false, 'message': 'Something went wrong'};
    }
  }

  // ✅ GET
  static Future<Map<String, dynamic>?> get(String endpoint) async {
    try {
      final token = await LocalStorage.getAccessToken();
      if (token == null || token.isEmpty) return null;
      final request = await html.HttpRequest.request(
        '$baseUrl$endpoint',
        method: 'GET',
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
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ✅ POST Public (Basic Auth)
  static Future<Map<String, dynamic>?> postPublic(
      String endpoint, Map<String, dynamic> body) async {
    try {
      final request = await html.HttpRequest.request(
        '$baseUrl$endpoint',
        method: 'POST',
        sendData: json.encode(body),
        requestHeaders: {
          'Content-Type': 'application/json',
          'Authorization': _basicAuthHeader,
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

  // ✅ POST Bearer
  static Future<Map<String, dynamic>?> post(
      String endpoint, Map<String, dynamic> body) async {
    try {
      final token = await LocalStorage.getAccessToken();
      if (token == null || token.isEmpty) return null;
      final request = await html.HttpRequest.request(
        '$baseUrl$endpoint',
        method: 'POST',
        sendData: json.encode(body),
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

  // ✅ PUT
  static Future<Map<String, dynamic>?> put(
      String endpoint, Map<String, dynamic> body) async {
    try {
      final token = await LocalStorage.getAccessToken();
      if (token == null || token.isEmpty) return null;
      final request = await html.HttpRequest.request(
        '$baseUrl$endpoint',
        method: 'PUT',
        sendData: json.encode(body),
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

  // ✅ DELETE
  static Future<Map<String, dynamic>?> delete(String endpoint) async {
    try {
      final token = await LocalStorage.getAccessToken();
      if (token == null || token.isEmpty) return null;
      final request = await html.HttpRequest.request(
        '$baseUrl$endpoint',
        method: 'DELETE',
        requestHeaders: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));
      final status = request.status;
      if (status != null && status >= 200 && status < 300) return {};
      return null;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> getAccessToken() async {
    return await LocalStorage.getAccessToken();
  }

  // ===== CART =====

  static Future<Map<String, dynamic>> getCart() async {
    try {
      final token = await LocalStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        return {'success': false, 'message': 'Unauthorized'};
      }
      final request = await html.HttpRequest.request(
        '$baseUrl/cart/',
        method: 'GET',
        requestHeaders: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));
      final status = request.status;
      if (status == 404) return {'success': false, 'notFound': true};
      if (status != null && status >= 200 && status < 300) {
        final text = request.responseText;
        if (text == null || text.isEmpty) {
          return {'success': false, 'message': 'Empty cart response'};
        }
        final data = json.decode(text) as Map<String, dynamic>;
        return {'success': true, 'cart': CartModel.fromJson(data)};
      }
      return {'success': false, 'message': 'Failed to load cart'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> createCart() async {
    try {
      final response = await post('/cart/', {});
      if (response != null) return {'success': true};
      return {'success': false, 'message': 'Failed to create cart'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> addCartItem({
    required int kitId,
    required int quantity,
  }) async {
    try {
      final response =
          await post('/cart/items', {'kitId': kitId, 'quantity': quantity});
      if (response != null) return {'success': true};
      return {'success': false, 'message': 'Failed to add item'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> updateCartItem({
    required int itemId,
    required int quantity,
  }) async {
    try {
      final response =
          await put('/cart/items/$itemId', {'quantity': quantity});
      if (response != null) return {'success': true};
      return {'success': false, 'message': 'Failed to update item'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> removeCartItem({required int itemId}) async {
    try {
      final response = await delete('/cart/items/$itemId');
      if (response != null) return {'success': true};
      return {'success': false, 'message': 'Failed to remove item'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> clearCart() async {
    try {
      final response = await delete('/cart/');
      if (response != null) return {'success': true};
      return {'success': false, 'message': 'Failed to clear cart'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
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