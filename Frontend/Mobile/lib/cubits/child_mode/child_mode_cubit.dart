import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/auth/token_storage_service.dart';
import '../../services/child_mode_service.dart';
import 'child_mode_state.dart';

class ChildModeCubit extends Cubit<ChildModeState> {
  final ChildModeService _service = ChildModeService();

  bool _isChildMode = false;
  bool _hasPin = false;

  ChildModeCubit() : super(ChildModeInitial());

  ChildModeStatus get current => ChildModeStatus(
    isChildMode: _isChildMode,
    hasPin: _hasPin,
  );

  Future<void> checkChildMode() async {
    final accessToken = await TokenStorageService.getAccessToken();
    final refreshToken = await TokenStorageService.getRefreshToken();

    // إذا المستخدم مش عامل login، ما نحاول ننادي API
    if (accessToken == null ||
        accessToken.isEmpty ||
        refreshToken == null ||
        refreshToken.isEmpty) {
      reset();
      return;
    }

    emit(current.copyWith(isLoading: true, error: null));

    try {
      final hasPin = await _service.hasPin();
      final isChildMode = await _service.isChildMode();

      _hasPin = hasPin;
      _isChildMode = isChildMode;

      emit(
        ChildModeStatus(
          isChildMode: _isChildMode,
          hasPin: _hasPin,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(
        current.copyWith(
          isLoading: false,
          error: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> enableChildMode() async {
    emit(current.copyWith(isLoading: true, error: null));

    try {
      await _service.enableChildMode();

      _isChildMode = true;

      emit(
        ChildModeStatus(
          isChildMode: true,
          hasPin: _hasPin,
          isLoading: false,
        ),
      );
    } catch (e) {
      if (e.toString().contains('PIN_REQUIRED')) {
        emit(ChildModePinRequired());
        return;
      }

      emit(
        current.copyWith(
          isLoading: false,
          error: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> disableChildMode(String pin) async {
    emit(current.copyWith(isLoading: true, error: null));

    try {
      await _service.disableChildMode(pin);

      _isChildMode = false;

      emit(
        ChildModeStatus(
          isChildMode: false,
          hasPin: _hasPin,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(
        current.copyWith(
          isLoading: false,
          error: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> setPin(String pin) async {
    emit(current.copyWith(isLoading: true, error: null));

    try {
      await _service.setPin(pin);

      _hasPin = true;

      emit(
        ChildModeStatus(
          isChildMode: _isChildMode,
          hasPin: true,
          isLoading: false,
        ),
      );
    } catch (e) {
      emit(
        current.copyWith(
          isLoading: false,
          error: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  void reset() {
    _isChildMode = false;
    _hasPin = false;
    emit(ChildModeInitial());
  }
}