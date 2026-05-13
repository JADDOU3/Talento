// lib/util/config/local_storage.dart
//
// Thin wrapper that delegates to the ApiService.LocalStorage
// which already uses dart:html localStorage directly.
// This avoids any shared_preferences dependency.

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class LocalStorage {
  static const String _accessTokenKey  = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey       = 'user_id';

  static Future<String?> getAccessToken() async =>
      html.window.localStorage[_accessTokenKey];

  static Future<void> setAccessToken(String token) async =>
      html.window.localStorage[_accessTokenKey] = token;

  static Future<String?> getRefreshToken() async =>
      html.window.localStorage[_refreshTokenKey];

  static Future<void> setRefreshToken(String token) async =>
      html.window.localStorage[_refreshTokenKey] = token;

  static Future<String?> getUserId() async =>
      html.window.localStorage[_userIdKey];

  static Future<void> setUserId(String id) async =>
      html.window.localStorage[_userIdKey] = id;

  static Future<void> clear() async {
    html.window.localStorage.remove(_accessTokenKey);
    html.window.localStorage.remove(_refreshTokenKey);
    html.window.localStorage.remove(_userIdKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = html.window.localStorage[_accessTokenKey];
    return token != null && token.isNotEmpty;
  }
}