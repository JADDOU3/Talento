import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/child_model.dart';
import '../../services/profile_service.dart';
import '../../services/token_storage_service.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileService _service = ProfileService();

  ProfileCubit() : super(ProfileInitial());

  // Load all profile data
  Future<void> loadProfile() async {
    emit(ProfileLoading());
    try {
      // Fetch all data in parallel
      final results = await Future.wait([
        _service.getCurrentUser(),
        _service.getChildren(),
        _service.getSelectedChild(),
      ]);

      final user = results[0] as dynamic;
      final children = results[1] as List<ChildModel>;
      final selectedChild = results[2] as ChildModel?;

      // Fetch kits for selected child
      final kits = selectedChild != null
          ? await _service.getKitsByChild(selectedChild.id)
          : [];

      emit(ProfileLoaded(
        user: user,
        children: children,
        selectedChild: selectedChild,
        kits: kits as dynamic,
      ));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  // Select child and refresh kits
  Future<void> selectChild(ChildModel child) async {
    if (state is! ProfileLoaded) return;
    final current = state as ProfileLoaded;

    emit(ProfileKitsLoading(
      user: current.user,
      children: current.children,
      selectedChild: child,
    ));

    try {
      final kits = await _service.getKitsByChild(child.id);
      emit(ProfileLoaded(
        user: current.user,
        children: current.children,
        selectedChild: child,
        kits: kits,
      ));
    } catch (e) {

      emit(ProfileError(e.toString()));

    }
  }

  // Logout
  Future<void> logout() async {
    await TokenStorageService.clearTokens();
  }
}