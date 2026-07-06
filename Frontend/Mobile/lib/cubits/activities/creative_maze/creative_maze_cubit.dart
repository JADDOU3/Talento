import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../activities/creative_maze/config/creative_maze_level_config.dart';
import '../../../models/activities/creative_maze/creative_maze_level_model.dart';
import '../../../services/activities/creative_maze_service.dart';
import 'creative_maze_state.dart';

/// Creative Maze runtime.
///
/// Structurally identical to Bodily Maze but with NO holes and NO failure
/// condition — the only outcome is completing the maze. The roadmap card
/// always hands us exactly one level, so there is no next-level flow inside
/// the game.
///
/// A timer runs internally (not shown to the child) and its value is passed as
/// `completionTime` when the maze is finished.
class CreativeMazeCubit extends Cubit<CreativeMazeState> {
  CreativeMazeCubit({
    CreativeMazeService? service,
  })  : _service = service ?? CreativeMazeService(),
        super(const CreativeMazeInitial());

  final CreativeMazeService _service;

  late int _activityId;
  late int _activitySessionId;
  late int _childId;
  late int _sessionId;

  bool _activityCompleted = false;
  bool _gameLoaded = false;
  bool _reachedEnd = false;

  Timer? _timer;
  Duration _elapsed = Duration.zero;

  Future<void> loadGame({
    required int activityId,
    required int activitySessionId,
    required int childId,
    required int sessionId,
    int? startLevelId,
    int? startLevelNumber,
  }) async {
    emit(const CreativeMazeLoading());

    _activityId = activityId;
    _activitySessionId = activitySessionId;
    _childId = childId;
    _sessionId = sessionId;
    _activityCompleted = false;
    _gameLoaded = false;
    _reachedEnd = false;
    _elapsed = Duration.zero;

    try {
      final levels = await _service.getLevelsByActivity(activityId);

      final startIndex = _resolveStartLevelIndex(
        levels: levels,
        startLevelId: startLevelId,
        startLevelNumber: startLevelNumber,
      );


      final level = levels[startIndex];
      print('CREATIVE MAZE PICK => levelNumber=${level.levelNumber} id=${level.id} configKeys=${creativeMazeConfigs.keys.toList()}');

// نجرّب نلاقي config بالـ id، بعدها بالـ levelNumber، وإلا أول متاهة متوفّرة.
    final config = creativeMazeConfigs[level.levelNumber] ??
          creativeMazeConfigs[level.id] ??
          (creativeMazeConfigs.isNotEmpty
              ? creativeMazeConfigs.values.first
              : null);
      if (config == null) {
        emit(
          const CreativeMazeError(
            'No maze layouts are configured. Add at least one to '
            'creativeMazeConfigs.',
          ),
        );
        return;
      } 

      final startedAt = DateTime.now().toIso8601String();
      final attemptId = await _service.createLevelAttempt(
        attemptNumber: 1,
        startedAt: startedAt,
        activitySessionId: _activitySessionId,
        levelId: level.id,
      );

      await _service.postActivityEvent(
        childId: _childId,
        sessionId: _sessionId,
        activityId: _activityId,
        action: 'STARTED',
      );

      await _service.postLevelEvent(
        childId: _childId,
        sessionId: _sessionId,
        activitySessionId: _activitySessionId,
        action: 'STARTED',
      );

      _gameLoaded = true;

      emit(
        CreativeMazeLoaded(
          level: level,
          config: config,
          currentAttemptId: attemptId,
          attemptNumber: 1,
          currentAttemptStartedAt: startedAt,
          elapsed: Duration.zero,
        ),
      );

      _startTimer();
    } catch (error) {
      emit(CreativeMazeError(error.toString()));
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => onTimerTick());
  }

  void onTimerTick() {
    final current = state;
    if (current is! CreativeMazeLoaded) return;
    _elapsed += const Duration(seconds: 1);
    emit(current.copyWith(elapsed: _elapsed));
  }

  /// Called by the game when the ball reaches the end-point zone.
  Future<void> onBallReachedEnd() async {
    if (_reachedEnd) return; // guard against multiple triggers
    final current = state;
    if (current is! CreativeMazeLoaded) return;

    _reachedEnd = true;
    _timer?.cancel();

    try {
      await _service.updateLevelAttempt(
        attemptId: current.currentAttemptId,
        attemptNumber: current.attemptNumber,
        startedAt: current.currentAttemptStartedAt,
        activitySessionId: _activitySessionId,
        levelId: current.level.id,
        completed: true,
      );

      await _service.postLevelEvent(
        childId: _childId,
        sessionId: _sessionId,
        activitySessionId: _activitySessionId,
        action: 'COMPLETED',
      );

      await _service.postActivityEvent(
        childId: _childId,
        sessionId: _sessionId,
        activityId: _activityId,
        action: 'COMPLETED',
      );

      await _service.completeActivitySession(_activitySessionId);

      _activityCompleted = true;

      emit(CreativeMazeComplete(completionTime: _elapsed));
    } catch (error) {
      emit(CreativeMazeError(error.toString()));
    }
  }

  int _resolveStartLevelIndex({
    required List<CreativeMazeLevelModel> levels,
    int? startLevelId,
    int? startLevelNumber,
  }) {
    if (levels.isEmpty) return 0;

    if (startLevelId != null && startLevelId > 0) {
      final byId = levels.indexWhere((l) => l.id == startLevelId);
      if (byId != -1) return byId;
    }

    if (startLevelNumber != null && startLevelNumber > 0) {
      final byNumber =
          levels.indexWhere((l) => l.levelNumber == startLevelNumber);
      if (byNumber != -1) return byNumber;
    }

    return 0;
  }

  Future<void> endActivityIfNotCompleted() async {
    if (_activityCompleted) return;
    if (!_gameLoaded) return;

    try {
      await _service.postActivityEvent(
        childId: _childId,
        sessionId: _sessionId,
        activityId: _activityId,
        action: 'ENDED',
      );
    } catch (_) {
      // Don't block closing the screen if the ending event fails.
    }
  }

  @override
  Future<void> close() async {
    _timer?.cancel();
    await endActivityIfNotCompleted();
    return super.close();
  }
}
