import 'package:flutter_bloc/flutter_bloc.dart';
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
    emit(current.copyWith(isLoading: true));
    try {
      final isChildMode = await _service.isChildMode();
      final hasPin = await _service.hasPin();

      _isChildMode = isChildMode;
      _hasPin = hasPin;

      emit(ChildModeStatus(
        isChildMode: _isChildMode,
        hasPin: _hasPin,
        isLoading: false,
      ));
    } catch (e) {
      emit(current.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> enableChildMode() async {
    emit(current.copyWith(isLoading: true));
    try {
      await _service.enableChildMode();
      _isChildMode = true;
      // ✅ لا تنادي checkChildMode — عشان ما تمسح _hasPin
      emit(ChildModeStatus(
        isChildMode: true,
        hasPin: _hasPin,
        isLoading: false,
      ));
    } catch (e) {
      if (e.toString().contains('PIN_REQUIRED')) {
        emit(ChildModePinRequired());
        return;
      }
      emit(current.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> disableChildMode(String pin) async {
    emit(current.copyWith(isLoading: true));
    try {
      await _service.disableChildMode(pin);
      _isChildMode = false;
      // ✅ لا تنادي checkChildMode — بس عدل الـ state مباشرة
      emit(ChildModeStatus(
        isChildMode: false,
        hasPin: _hasPin,
        isLoading: false,
      ));
    } catch (e) {
      emit(current.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> setPin(String pin) async {
    emit(current.copyWith(isLoading: true));
    try {
      await _service.setPin(pin);
      _hasPin = true;
      emit(ChildModeStatus(
        isChildMode: _isChildMode,
        hasPin: true,
        isLoading: false,
      ));
    } catch (e) {
      emit(current.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void reset() {
    _isChildMode = false;
    _hasPin = false;
    emit(ChildModeInitial());
  }
}
