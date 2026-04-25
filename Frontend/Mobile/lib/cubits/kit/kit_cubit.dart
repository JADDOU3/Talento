import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/kit_enums.dart';
import '../../services/kit_service.dart';
import 'kit_state.dart';

class KitCubit extends Cubit<KitState> {
  final KitService _kitService;

  KitCubit(this._kitService) : super(const KitInitial());

  Future<void> getAllKits() async {
    emit(const KitLoading());
    try {
      final kits = await _kitService.getAllKits();
      emit(KitLoaded(kits));
    } catch (e) {
      emit(KitError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> getKitsByMindset(Mindset mindset) async {
    emit(const KitLoading());
    try {
      final kits = await _kitService.getKitsByMindset(mindset.apiValue);
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