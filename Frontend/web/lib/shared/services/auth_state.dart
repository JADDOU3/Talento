// lib/shared/services/auth_state.dart
import 'package:flutter/foundation.dart';
import 'local_storage.dart';  // ✅ Only need this once

/// Minimal reactive wrapper around the app's existing token storage.
///
/// There's no auth cubit/bloc in this project yet — login state lives as a
/// plain access token in SharedPreferences (`LocalStorage`). This class
/// turns that into something widgets can listen to (e.g. the navbar), so
/// pages stop hardcoding `isLoggedIn: true` / `isLoggedIn: false`.
///
/// Wire it up in exactly two places:
///   1. On app startup — before `runApp`, or in your splash/auth-check
///      screen — call `await AuthState.instance.refresh();` once, so the
///      navbar shows the correct state on first paint instead of "logged
///      out" for a frame.
///   2. Right after `AuthService.login()` succeeds and right after
///      `AuthService.logout()` runs — call `AuthState.instance.refresh()`
///      again (or `setLoggedIn(true/false)` directly if you already know
///      the result, to avoid an extra storage read).
class AuthState extends ChangeNotifier {
  AuthState._();
  static final AuthState instance = AuthState._();

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  /// Re-reads the access token from storage and notifies listeners if the
  /// logged-in status changed.
  Future<void> refresh() async {
    final token = await LocalStorage.getAccessToken();
    setLoggedIn(token != null && token.isNotEmpty);
  }

  /// Call this directly right after a successful login/logout if you
  /// already know the outcome — saves a redundant storage read.
  void setLoggedIn(bool value) {
    if (value != _isLoggedIn) {
      _isLoggedIn = value;
      notifyListeners();
    }
  }
}