import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/child_model.dart';
import '../../models/kit_model.dart';
import '../../services/profile_service.dart';
import '../../services/token_storage_service.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileService _service = ProfileService();

  ProfileCubit() : super(ProfileInitial());

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    try {
      final results = await Future.wait([
        _service.getCurrentUser(),
        _service.getChildren(),
        _service.getSelectedChild(),
      ]);

      final user = results[0] as dynamic;
      final children = results[1] as List<ChildModel>;
      final selectedChild = results[2] as ChildModel?;

      final List<ChildModel> finalChildren = children.isNotEmpty
          ? children
          : [
        ChildModel(id: 1, name: 'مايا'),
        ChildModel(id: 2, name: 'أيو'),
        ChildModel(id: 3, name: 'سارة'),
      ];

      final ChildModel? finalSelected = selectedChild ??
          (finalChildren.isNotEmpty ? finalChildren[0] : null);

      final List<KitModel> kits = finalSelected != null
          ? _getMockKits(finalSelected.id)
          : [];

      emit(ProfileLoaded(
        user: user,
        children: finalChildren,
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
      emit(ProfileLoaded(
        user: current.user,
        children: updatedChildren,
        selectedChild: current.selectedChild,
        kits: current.kits,
      ));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  List<KitModel> _getMockKits(int childId) {
    return [
      KitModel(
        id: childId * 10,
        name: 'مستكشف الفضاء',
        description: 'رحلة في عالم الكون',
        imageUrl: '',
        type: 'علوم',
        mindset: 'استكشاف',
        kitItems: [],
        rating: 4.5,
        age: 6,
      ),
      KitModel(
        id: childId * 10 + 1,
        name: 'عالم النبات',
        description: 'اكتشف الطبيعة',
        imageUrl: '',
        type: 'طبيعة',
        mindset: 'إبداع',
        kitItems: [],
        rating: 4.0,
        age: 5,
      ),
    ];
  }

  Future<void> logout() async {
    await TokenStorageService.clearTokens();
  }
}