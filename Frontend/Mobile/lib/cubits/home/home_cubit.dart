import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/home/home_service.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final HomeService _homeService;

  HomeCubit(this._homeService) : super(const HomeInitial());

  Future<void> initHome() async {
    emit(const HomeLoading());

    try {
      final isNewUser = await _homeService.isNewUser();

      if (isNewUser) {
        emit(const HomeNewUser());
        return;
      }

      await refreshHome();
    } catch (e) {
      emit(HomeError(_cleanError(e)));
    }
  }

  Future<void> refreshHome() async {
    emit(const HomeLoading());

    try {
      final data = await _homeService.getReturningUserHomeData();
      emit(HomeReturningUser(data));
    } catch (e) {
      emit(HomeError(_cleanError(e)));
    }
  }

  String _cleanError(Object error) {
    return error.toString().replaceFirst('Exception: ', '');
  }
}