import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'http://13.37.240.125/api';
  static const _storage = FlutterSecureStorage();

  static Dio _createDio() {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));
    dio.interceptors.add(AuthInterceptor(dio));
    return dio;
  }

  static final Dio dio = _createDio();

  // ===== REGISTER =====
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String gender,
    required String password,
  }) async {
    try {
      final response = await dio.post('/register', data: {
        'name': name,
        'email': email,
        'gender': gender,
        'password': password,
      });
      return {'success': true, 'message': response.data};
    } on DioException catch (e) {
      final message = e.response?.data ?? 'Something went wrong';
      return {'success': false, 'message': message};
    }
  }

  // ===== LOGIN =====
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post('/login', data: {
        'email': email,
        'password': password,
      });
      final accessToken = response.data['accessToken'];
      final refreshToken = response.data['refreshToken'];
      await _storage.write(key: 'access_token', value: accessToken);
      await _storage.write(key: 'refresh_token', value: refreshToken);
      return {'success': true};
    } on DioException catch (e) {
      final message = e.response?.data ?? 'Something went wrong';
      return {'success': false, 'message': message};
    }
  }

  // ===== REFRESH TOKEN =====
  static Future<bool> refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) return false;
      final response = await Dio().post('$baseUrl/refresh',
          data: {'refreshToken': refreshToken});
      await _storage.write(
          key: 'access_token', value: response.data['accessToken']);
      await _storage.write(
          key: 'refresh_token', value: response.data['refreshToken']);
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<String?> getAccessToken() =>
      _storage.read(key: 'access_token');
}

// ===== AUTH INTERCEPTOR =====
class AuthInterceptor extends Interceptor {
  final Dio dio;
  AuthInterceptor(this.dio);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await ApiService.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await ApiService.refreshToken();
      if (refreshed) {
        final token = await ApiService.getAccessToken();
        err.requestOptions.headers['Authorization'] = 'Bearer $token';
        final response = await dio.fetch(err.requestOptions);
        handler.resolve(response);
        return;
      }
    }
    handler.next(err);
  }
}