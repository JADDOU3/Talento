import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/roadmap/roadmap_service.dart';
import 'roadmap_state.dart';

class RoadmapCubit extends Cubit<RoadmapState> {
  final RoadmapService _roadmapService;

  int? _kitId;
  int? _childId;

  RoadmapCubit(this._roadmapService) : super(const RoadmapInitial());

  Future<void> loadRoadmap(int kitId, int childId) async {
    _kitId = kitId;
    _childId = childId;

    emit(const RoadmapLoading());

    try {
      final roadmap = await _roadmapService.getRoadmap(
        kitId: kitId,
        childId: childId,
      );

      emit(RoadmapLoaded(roadmap.activities));
    } catch (e) {
      emit(RoadmapError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> refreshRoadmap() async {
    final kitId = _kitId;
    final childId = _childId;

    if (kitId == null || childId == null) {
      return;
    }

    try {
      final roadmap = await _roadmapService.getRoadmap(
        kitId: kitId,
        childId: childId,
      );

      emit(RoadmapLoaded(roadmap.activities));
    } catch (e) {
      emit(RoadmapError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}