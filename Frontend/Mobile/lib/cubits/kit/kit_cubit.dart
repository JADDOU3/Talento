import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/kit/kit_enums.dart';
import '../../services/kit/kit_service.dart';
import 'kit_state.dart';

class KitCubit extends Cubit<KitState> {
  final KitService _kitService;

  KitCubit(this._kitService) : super(const KitInitial());

  Future<void> getAllKits({int page = 0, int size = 10}) async {
    emit(const KitLoading());
    try {
      final kits = await _kitService.getAllKits(page: page, size: size);
      emit(KitLoaded(kits));
    } catch (e) {
      emit(KitError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  // Kept temporarily so the current hardcoded chip UI keeps compiling.
  // The library screen will be changed next to use getKitsByMindsetId().
  Future<void> getKitsByMindset(Mindset mindset) async {
    emit(const KitLoading());
    try {
      final kits = await _kitService.getKitsByMindsetLegacy(mindset.apiValue);
      emit(KitLoaded(kits));
    } catch (e) {
      emit(KitError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> getKitsByMindsetId(int mindsetId) async {
    emit(const KitLoading());
    try {
      final kits = await _kitService.getKitsByMindset(mindsetId);
      emit(KitLoaded(kits));
    } catch (e) {
      emit(KitError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> getKitsByType(String type) async {
    emit(const KitLoading());
    try {
      final kits = await _kitService.getKitsByType(type);
      emit(KitLoaded(kits));
    } catch (e) {
      emit(KitError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> searchKits(String keyword) async {
    final trimmedKeyword = keyword.trim();

    if (trimmedKeyword.isEmpty) {
      await getAllKits();
      return;
    }

    emit(const KitLoading());
    try {
      final kits = await _kitService.searchKits(trimmedKeyword);
      emit(KitLoaded(kits));
    } catch (e) {
      emit(KitError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> getKitById(int id) async {
    emit(const KitLoading());
    try {
      final kit = await _kitService.getKitById(id);
      emit(KitDetailsLoaded(kit));
    } catch (e) {
      emit(KitError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
