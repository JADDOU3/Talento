import '../../models/roadmap/roadmap_activity_model.dart';

abstract class RoadmapState {
  const RoadmapState();
}

class RoadmapInitial extends RoadmapState {
  const RoadmapInitial();
}

class RoadmapLoading extends RoadmapState {
  const RoadmapLoading();
}

class RoadmapLoaded extends RoadmapState {
  final List<RoadmapActivityModel> activities;

  const RoadmapLoaded(this.activities);
}

class RoadmapError extends RoadmapState {
  final String message;

  const RoadmapError(this.message);
}