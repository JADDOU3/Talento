// lib/shared/services/auth_service.dart
import 'package:flutter/foundation.dart';
import 'local_storage.dart';
import '../models/parent_profile.dart';
import 'api_service.dart';
import 'auth_state.dart';

class AuthService {
  /// Register parent
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
          'Could not reach the API. Check CORS or backend URL: ${ApiService.baseUrl}',
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

        if (lower.contains('registered successfully') || serverMsg.isEmpty) {
          return {
            'success': true,
            'message': 'Account created successfully!',
          };
        }

        return {
          'success': true,
          'message': serverMsg,
        };
      }

      return {
        'success': false,
        'message': serverMsg.isNotEmpty
            ? serverMsg
            : 'Registration failed (HTTP ${ApiService.httpStatusOf(response)})',
      };
    } catch (e, st) {
      debugPrint('[AuthService.register] exception: $e\n$st');
      return {
        'success': false,
        'message': 'Something went wrong: $e',
      };
    }
  }

  /// Login
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
          'message': 'Could not reach backend. Check network/CORS.',
        };
      }

      if (!ApiService.isSuccessfulHttp(response)) {
        final msg = ApiService.userFacingMessage(response);

        // Keep auth state in sync
        await AuthState.instance.refresh();

        return {
          'success': false,
          'message': msg.isNotEmpty
              ? msg
              : 'Login failed (HTTP ${ApiService.httpStatusOf(response)})',
        };
      }

      final access = response['accessToken'];
      final refresh = response['refreshToken'];

      if (access is String && access.isNotEmpty) {
        await LocalStorage.setAccessToken(access);

        if (refresh is String && refresh.isNotEmpty) {
          await LocalStorage.setRefreshToken(refresh);
        }

        // ✅ Notify the app immediately that the user is logged in.
        AuthState.instance.setLoggedIn(true);

        return {
          'success': true,
          'message': 'Login successful!',
        };
      }

      await AuthState.instance.refresh();

      return {
        'success': false,
        'message': ApiService.userFacingMessage(response),
      };
    } catch (e, st) {
      debugPrint('[AuthService.login] exception: $e\n$st');

      await AuthState.instance.refresh();

      return {
        'success': false,
        'message': 'Something went wrong: $e',
      };
    }
  }

  /// Get current logged-in user
  static Future<ParentProfile?> getCurrentUser() async {
    try {
      final response = await ApiService.get('/currentUser');

      if (response == null) return null;

      return ParentProfile.fromJson(response);
    } catch (e) {
      debugPrint('[AuthService.getCurrentUser] $e');
      return null;
    }
  }

  /// Logout - clears all user data and updates auth state
  static Future<void> logout() async {
    try {
      // Clear all stored tokens from SharedPreferences
      await LocalStorage.clear();

      // ✅ AuthState.instance.setLoggedIn(false) is already called inside LocalStorage.clear()
      // if it's implemented correctly, but we'll call it explicitly to be safe.
      AuthState.instance.setLoggedIn(false);

      if (kDebugMode) {
        debugPrint('[AuthService.logout] User logged out successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[AuthService.logout] Error during logout: $e');
      }
      // Even if there's an error, make sure the user is logged out
      AuthState.instance.setLoggedIn(false);
    }
  }
}