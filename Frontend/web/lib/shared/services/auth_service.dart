import 'package:flutter/foundation.dart';

import 'api_service.dart';

class AuthService {
  /// Register parent — backend returns **plain text** `"Parent registered successfully"` on 200,
  /// or plain text / JSON error bodies on 4xx (e.g. `"Email already exists"`).
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String gender,
    required String password,
  }) async {
    try {
      final response = await ApiService.postPublic('/register', {
        'name': name,
        'email': email,
        'gender': gender,
        'password': password,
      });

      if (response == null) {
        return {
          'success': false,
          'message':
              'Could not reach the API from this browser (CORS or network). '
              'Ensure the backend at ${ApiService.baseUrl} allows http://localhost:3000, '
              'or run the backend locally and start Flutter with '
              '--dart-define=API_BASE_URL=http://localhost:8080/api',
        };
      }

      final okHttp = ApiService.isSuccessfulHttp(response);
      final serverMsg = ApiService.userFacingMessage(response);

      if (kDebugMode) {
        debugPrint(
          '[AuthService.register] HTTP ${ApiService.httpStatusOf(response)} '
          'ok=$okHttp msg="$serverMsg"',
        );
      }

      if (okHttp) {
        final lower = serverMsg.toLowerCase();
        if (lower.contains('registered successfully')) {
          return {'success': true, 'message': 'Account created successfully!'};
        }
        // Unexpected 200 body — still show what the server sent
        if (serverMsg.isEmpty) {
          return {'success': true, 'message': 'Account created successfully!'};
        }
        return {'success': true, 'message': serverMsg};
      }

      final detail = serverMsg.isNotEmpty
          ? serverMsg
          : 'Registration failed (HTTP ${ApiService.httpStatusOf(response)})';

      return {'success': false, 'message': detail};
    } catch (e, st) {
      debugPrint('[AuthService.register] exception: $e\n$st');
      return {'success': false, 'message': 'Something went wrong: $e'};
    }
  }

  /// Login — [LoginDto] uses field `email` (see backend).
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiService.postPublic('/login', {
        'email': email,
        'password': password,
      });

      if (response == null) {
        return {
          'success': false,
          'message':
              'Could not reach the API from this browser (CORS or network). '
              'Ensure the backend at ${ApiService.baseUrl} allows http://localhost:3000, '
              'or run the backend locally and start Flutter with '
              '--dart-define=API_BASE_URL=http://localhost:8080/api',
        };
      }

      if (!ApiService.isSuccessfulHttp(response)) {
        final msg = ApiService.userFacingMessage(response);
        return {
          'success': false,
          'message': msg.isNotEmpty
              ? msg
              : 'Login failed (HTTP ${ApiService.httpStatusOf(response)})',
        };
      }

      final rawAccess = response['accessToken'];
      final rawRefresh = response['refreshToken'];

      if (rawAccess is String && rawAccess.isNotEmpty) {
        await LocalStorage.setAccessToken(rawAccess);
        if (rawRefresh is String && rawRefresh.isNotEmpty) {
          await LocalStorage.setRefreshToken(rawRefresh);
        }
        return {'success': true, 'message': 'Login successful!'};
      }

      final fallback = ApiService.userFacingMessage(response);
      return {
        'success': false,
        'message':
            fallback.isNotEmpty ? fallback : 'Invalid credentials',
      };
    } catch (e, st) {
      debugPrint('[AuthService.login] exception: $e\n$st');
      return {'success': false, 'message': 'Something went wrong: $e'};
    }
  }

  /// ✅ Logout
  static void logout() => LocalStorage.clear();
}
