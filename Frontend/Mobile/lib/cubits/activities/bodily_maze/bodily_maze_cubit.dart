import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../activities/bodily_maze/config/bodily_maze_level_config.dart';
import '../../models/activities/bodily_maze/bodily_maze_models.dart';
import '../../services/activities/bodily_maze_service.dart';
import 'bodily_maze_state.dart';

class BodilyMazeCubit extends Cubit<BodilyMazeState> {
  final BodilyMazeService _service;

  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;

  BodilyMazeLevel? _level;
  MazeLevelConfig? _config;

  int _attemptId = 0;
  int _attemptNumber = 1;
  String? _attemptStartedAt;

  Duration _elapsed = Duration.zero;
  bool _completed = false;
  bool _isLoading = false;

  BodilyMazeCubit({
    required BodilyMazeService service,
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
  })  : _service = service,
        super(const BodilyMazeInitial());

  Future<void> loadGame({
    int? startLevelId,
    int? startLevelNumber,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    emit(const BodilyMazeLoading());

    try {
      final levels = await _service.getLevels(activityId);

      debugPrint('BODILY MAZE requested startLevelId = $startLevelId');
      debugPrint('BODILY MAZE requested startLevelNumber = $startLevelNumber');

      for (final level in levels) {
        debugPrint(
          'BODILY MAZE LEVEL => id=${level.id}, number=${level.levelNumber}',
        );
      }

      if (levels.isEmpty) {
        emit(const BodilyMazeError('لا توجد مستويات لهذا النشاط'));
        _isLoading = false;
        return;
      }

      BodilyMazeLevel selectedLevel;

      if (startLevelNumber != null && startLevelNumber > 0) {
        selectedLevel = levels.firstWhere(
              (level) => level.levelNumber == startLevelNumber,
          orElse: () => levels.first,
        );
      } else if (startLevelId != null && startLevelId > 0) {
        selectedLevel = levels.firstWhere(
              (level) => level.id == startLevelId,
          orElse: () => levels.first,
        );
      } else {
        selectedLevel = levels.first;
      }

      _level = selectedLevel;

      debugPrint(
        'BODILY MAZE SELECTED => id=${_level!.id}, number=${_level!.levelNumber}',
      );

      final config = mazeConfigs[_level!.levelNumber] ?? mazeConfigs[_level!.id];

      if (config == null) {
        emit(
          BodilyMazeError(
            'لا توجد إعدادات إحداثيات للمستوى ${_level!.levelNumber}. '
                'levelId=${_level!.id}',
          ),
        );
        _isLoading = false;
        return;
      }

      _config = config;

      _completed = false;
      _elapsed = Duration.zero;
      _attemptNumber = 1;
      _attemptStartedAt = DateTime.now().toIso8601String();

      _attemptId = await _service.createLevelAttempt(
        attemptNumber: _attemptNumber,
        activitySessionId: activitySessionId,
        levelId: _level!.id,
      );

      await _service.logActivityEvent(
        childId: childId,
        sessionId: sessionId,
        activityId: activityId,
        action: 'STARTED',
      );

      await _service.logLevelEvent(
        childId: childId,
        sessionId: sessionId,
        activitySessionId: activitySessionId,
        action: 'STARTED',
      );

      _isLoading = false;
      _emitLoaded();
    } catch (e) {
      _isLoading = false;
      emit(
        BodilyMazeError(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  void _emitLoaded() {
    emit(
      BodilyMazeLoaded(
        level: _level!,
        config: _config!,
        currentAttemptId: _attemptId,
        attemptNumber: _attemptNumber,
        elapsed: _elapsed,
      ),
    );
  }

  // ─── Ball fell in a hole → failed attempt, reset to start ─────────────────

  Future<void> onBallFellInHole() async {
    if (_completed || _level == null) return;

    try {
      await _service.updateLevelAttempt(
        attemptId: _attemptId,
        attemptNumber: _attemptNumber,
        startedAt: _attemptStartedAt ?? DateTime.now().toIso8601String(),
        activitySessionId: activitySessionId,
        levelId: _level!.id,
        completed: false,
      );

      await _service.logLevelEvent(
        childId: childId,
        sessionId: sessionId,
        activitySessionId: activitySessionId,
        action: 'FAILED',
      );

      _attemptNumber += 1;
      _attemptStartedAt = DateTime.now().toIso8601String();

      _attemptId = await _service.createLevelAttempt(
        attemptNumber: _attemptNumber,
        activitySessionId: activitySessionId,
        levelId: _level!.id,
      );

      await _service.logLevelEvent(
        childId: childId,
        sessionId: sessionId,
        activitySessionId: activitySessionId,
        action: 'RETRIED',
      );
    } catch (e) {
      debugPrint('BODILY MAZE FAIL ERROR: $e');
    }

    emit(
      BodilyMazeFailed(
        currentAttemptId: _attemptId,
        attemptNumber: _attemptNumber,
      ),
    );

    _emitLoaded();
  }

  Future<void> onBallReachedEnd() async {
    if (_completed || _level == null) return;

    _completed = true;

    try {
      await _service.updateLevelAttempt(
        attemptId: _attemptId,
        attemptNumber: _attemptNumber,
        startedAt: _attemptStartedAt ?? DateTime.now().toIso8601String(),
        activitySessionId: activitySessionId,
        levelId: _level!.id,
        completed: true,
      );

      await _service.logLevelEvent(
        childId: childId,
        sessionId: sessionId,
        activitySessionId: activitySessionId,
        action: 'COMPLETED',
      );

      await _service.logActivityEvent(
        childId: childId,
        sessionId: sessionId,
        activityId: activityId,
        action: 'COMPLETED',
      );

      await _service.completeActivitySession(activitySessionId);
    } catch (e) {
      debugPrint('BODILY MAZE COMPLETE ERROR: $e');
    }

    emit(const BodilyMazeComplete());
  }

  // ─── Timer ────────────────────────────────────────────────────────────────

  void onTimerTick() {
    if (_completed) return;

    _elapsed += const Duration(seconds: 1);

    final currentState = state;

    if (currentState is BodilyMazeLoaded) {
      emit(
        currentState.copyWith(
          elapsed: _elapsed,
        ),
      );
    }
  }

  // ─── Exit without completing ──────────────────────────────────────────────

  Future<void> logExitIfNotCompleted() async {
    if (_completed || _level == null || _attemptId == 0) return;

    try {
      await _service.updateLevelAttempt(
        attemptId: _attemptId,
        attemptNumber: _attemptNumber,
        startedAt: _attemptStartedAt ?? DateTime.now().toIso8601String(),
        activitySessionId: activitySessionId,
        levelId: _level!.id,
        completed: false,
      );

      await _service.logActivityEvent(
        childId: childId,
        sessionId: sessionId,
        activityId: activityId,
        action: 'ENDED',
      );
    } catch (e) {
      debugPrint('BODILY MAZE EXIT ERROR: $e');
    }
  }
}
