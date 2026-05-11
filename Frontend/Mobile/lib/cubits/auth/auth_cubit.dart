import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/auth/auth_service.dart';
import '../../services/auth/token_storage_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService = AuthService();

  AuthCubit() : super(AuthLoading());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());

    final accessToken = await TokenStorageService.getAccessToken();
    final refreshToken = await TokenStorageService.getRefreshToken();

    if (accessToken != null && refreshToken != null) {
      emit(Authenticated());
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    emit(AuthLoading());

    try {
      await _authService.login(
        email: email,
        password: password,
      );

      emit(Authenticated());
    } catch (e) {
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
      emit(Unauthenticated());
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    emit(Unauthenticated());
  }
}