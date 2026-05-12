import 'dart:convert';
import 'dart:html' as html;

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

      return {
        'success': false,
        'message': response?['message'] ?? 'Registration failed'
      };
    } catch (e) {
      print('Register error: $e');
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
        'username': email, // ✅ السيرفر بده username مش email
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

      return {
        'success': false,
        'message': response?['message'] ?? 'Invalid credentials'
      };
    } catch (e) {
      print('Login error: $e');
      return {'success': false, 'message': 'Something went wrong'};
    }
  }

  // ✅ GET مع Bearer Token
  static Future<Map<String, dynamic>?> get(String endpoint) async {
    try {
      final token = await LocalStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        print('Unauthorized: No token found');
        return null;
      }

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
      print('GET failed with status: $status');
      print('Response: ${request.responseText}');
      return null;
    } catch (e) {
      print('GET failed: $e');
      return null;
    }
  }

  // ✅ POST مع Basic Auth — للـ login و register (public)
  static Future<Map<String, dynamic>?> postPublic(
      String endpoint, Map<String, dynamic> body) async {
    try {
      final request = await html.HttpRequest.request(
        '$baseUrl$endpoint',
        method: 'POST',
        sendData: json.encode(body),
        requestHeaders: {
          'Content-Type': 'application/json',
          'Authorization': _basicAuthHeader, // ✅ Basic Auth مطلوب من السيرفر
        },
      ).timeout(const Duration(seconds: 15));

      final status = request.status;
      if (status != null && status >= 200 && status < 300) {
        final responseText = request.responseText;
        if (responseText != null && responseText.isNotEmpty) {
          return json.decode(responseText);
        }
        return {}; // ✅ 2xx بدون body
      }
      print('POST failed with status: $status');
      print('Response: ${request.responseText}');
      return null;
    } catch (e) {
      print('POST failed: $e');
      return null;
    }
  }

  // ✅ POST مع Bearer Token — للـ endpoints المحمية
  static Future<Map<String, dynamic>?> post(
      String endpoint, Map<String, dynamic> body) async {
    try {
      final token = await LocalStorage.getAccessToken();
      if (token == null || token.isEmpty) {
        print('Unauthorized: No token found');
        return null;
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

      final status = request.status;
      if (status != null && status >= 200 && status < 300) {
        final responseText = request.responseText;
        if (responseText != null && responseText.isNotEmpty) {
          return json.decode(responseText);
        }
        return {};
      }
      print('POST failed with status: $status');
      print('Response: ${request.responseText}');
      return null;
    } catch (e) {
      print('POST failed: $e');
      return null;
    }
  }

  static Future<String?> getAccessToken() async {
    return await LocalStorage.getAccessToken();
  }
}

class LocalStorage {
  static const String _accessTokenKey  = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  static Future<String?> getAccessToken() async =>
      html.window.localStorage[_accessTokenKey];

  static Future<void> setAccessToken(String token) async {
    html.window.localStorage[_accessTokenKey] = token;
    print('Token saved: $token');
  }

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