import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/roadmap/roadmap_activity_model.dart';
import '../../services/roadmap/roadmap_service.dart';
import '../../services/activities/story_submission_repository.dart';
import 'roadmap_state.dart';

class RoadmapCubit extends Cubit<RoadmapState> {
  final RoadmapService _roadmapService;
  final StorySubmissionRepository _storySubmissionRepository;

  int? _kitId;
  int? _childId;
  int _loadVersion = 0;

  RoadmapCubit(
      this._roadmapService, {
        StorySubmissionRepository? storySubmissionRepository,
      })  : _storySubmissionRepository =
      storySubmissionRepository ?? StorySubmissionRepository(),
        super(const RoadmapInitial());

  Future<void> loadRoadmap(int kitId, int childId) async {
    _kitId = kitId;
    _childId = childId;
    final version = ++_loadVersion;

    emit(const RoadmapLoading());

    try {
      final roadmap = await _roadmapService.getRoadmap(
        kitId: kitId,
        childId: childId,
      );

      final activities = roadmap.activities;

      emit(RoadmapLoaded(activities));
      unawaited(_attachStoryCounts(
        activities: activities,
        childId: childId,
        version: version,
      ));
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

    final version = ++_loadVersion;

    try {
      final roadmap = await _roadmapService.getRoadmap(
        kitId: kitId,
        childId: childId,
      );

      final activities = roadmap.activities;

      emit(RoadmapLoaded(activities));
      unawaited(_attachStoryCounts(
        activities: activities,
        childId: childId,
        version: version,
      ));
    } catch (e) {
      emit(RoadmapError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _attachStoryCounts({
    required List<RoadmapActivityModel> activities,
    required int childId,
    required int version,
  }) async {
    if (childId <= 0) return;

    final storyActivities = activities
        .where((activity) => activity.voiceEnabled && activity.activityId > 0)
        .toList();

    if (storyActivities.isEmpty) return;

    final countsByActivityId = <int, int>{};

    await Future.wait(
      storyActivities.map((activity) async {
        try {
          final count = await _storySubmissionRepository.getStoryCount(
            activity.activityId,
            childId,
          );

          countsByActivityId[activity.activityId] = count;
        } catch (_) {
          // Story counts are a silent enhancement. If they fail, keep the
          // roadmap working and hide the badge for that activity.
        }
      }),
    );

    if (isClosed || version != _loadVersion || countsByActivityId.isEmpty) {
      return;
    }

    final currentState = state;

    if (currentState is! RoadmapLoaded) return;

    final updatedActivities = currentState.activities.map((activity) {
      final count = countsByActivityId[activity.activityId];

      if (count == null) return activity;

      return activity.copyWith(storyCount: count);
    }).toList();

    emit(RoadmapLoaded(updatedActivities));
  }
}