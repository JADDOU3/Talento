import 'api_service.dart';

class AuthService {

  // ✅ Register
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String gender,
    required String password,
  }) async {
    try {
      // Backend returns plain String, not JSON — use postPublic and check null
      final response = await ApiService.postPublic('/register', {
        'name': name,
        'email': email,
        'gender': gender,
        'password': password,
      });

      // postPublic returns null on non-2xx, so any non-null = success
      if (response != null) {
        return {'success': true, 'message': 'Account created successfully!'};
      }

      return {'success': false, 'message': 'Registration failed'};
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
      final response = await ApiService.postPublic('/login', {
        'email': email,
        'password': password,
      });

      final token = response?['accessToken'];

      if (response != null && token != null) {
        LocalStorage.setAccessToken(token);
        if (response['refreshToken'] != null) {
          LocalStorage.setRefreshToken(response['refreshToken']);
        }
        return {'success': true, 'message': 'Login successful!'};
      }

      return {
        'success': false,
        'message': response?['message'] ?? 'Invalid credentials',
      };
    } catch (e) {
      print('Login error: $e');
      return {'success': false, 'message': 'Something went wrong'};
    }
  }

  // ✅ Logout
  static void logout() => LocalStorage.clear();
}