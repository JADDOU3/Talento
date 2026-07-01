import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/kit/kit_service.dart';
import 'community_filter_state.dart';

class CommunityFilterCubit extends Cubit<CommunityFilterState> {
  final KitService _kitService;

  CommunityFilterCubit(this._kitService) : super(CommunityFilterInitial());

  Future<void> loadFilters() async {
    emit(CommunityFilterLoading());

    try {
      final results = await Future.wait<dynamic>([
        _kitService.getMindsets(),
        _kitService.getAllKits(size: 50),
      ]);

      emit(
        CommunityFilterLoaded(
          mindsets: results[0],
          kits: results[1],
        ),
      );
    } catch (e) {
      emit(CommunityFilterError(e.toString()));
    }
  }
}
