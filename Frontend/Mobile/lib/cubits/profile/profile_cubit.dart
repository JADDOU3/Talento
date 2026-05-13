import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/child_model.dart';
import '../../models/kit/kit_model.dart';
import '../../services/auth/token_storage_service.dart';
import '../../services/profile/profile_service.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileService _service = ProfileService();

  ProfileCubit() : super(ProfileInitial());

  Future<void> loadProfile() async {
    emit(ProfileLoading());

    try {
      final user = await _service.getCurrentUser();
      final children = await _service.getChildren();
      final selectedChild = await _service.getSelectedChild();

      final ChildModel? finalSelected =
          selectedChild ?? (children.isNotEmpty ? children.first : null);

      final List<KitModel> kits = finalSelected != null
          ? await _service.getKitsByChild(finalSelected.id)
          : [];

      emit(ProfileLoaded(
        user: user,
        children: children,
        selectedChild: finalSelected,
        kits: kits,
      ));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> selectChild(ChildModel child) async {
    if (state is! ProfileLoaded) return;

    final current = state as ProfileLoaded;

    emit(ProfileKitsLoading(
      user: current.user,
      children: current.children,
      selectedChild: child,
    ));

    try {
      await _service.setSelectedChild(child.id);

      final selectedChild = await _service.getSelectedChild();
      final kits = await _service.getKitsByChild(child.id);

      emit(ProfileLoaded(
        user: current.user,
        children: current.children,
        selectedChild: selectedChild ?? child,
        kits: kits,
      ));
    } catch (e) {
      emit(ProfileLoaded(
        user: current.user,
        children: current.children,
        selectedChild: current.selectedChild,
        kits: current.kits,
      ));

      emit(ProfileError(e.toString()));
    }
  }

  Future<void> addChild({
    required String name,
    required String dateOfBirth,
    required String gender,
  }) async {
    if (state is! ProfileLoaded) return;

    final current = state as ProfileLoaded;

    try {
      final newChild = await _service.addChild(
        name: name,
        dateOfBirth: dateOfBirth,
        gender: gender,
      );

      final updatedChildren = [...current.children, newChild];

      final selectedChild = await _service.getSelectedChild();

      final ChildModel? finalSelected =
          selectedChild ?? current.selectedChild ?? newChild;

      final kits = finalSelected != null
          ? await _service.getKitsByChild(finalSelected.id)
          : <KitModel>[];

      emit(ProfileLoaded(
        user: current.user,
        children: updatedChildren,
        selectedChild: finalSelected,
        kits: kits,
      ));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> logout() async {
    await TokenStorageService.clearTokens();
  }
}