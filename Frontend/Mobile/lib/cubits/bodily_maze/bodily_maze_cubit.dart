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

  // ─── Load ────────────────────────────────────────────────────────────────

  Future<void> loadGame({int? startLevelId}) async {
    if (_isLoading) return;
    _isLoading = true;
    emit(const BodilyMazeLoading());

    try {
      final levels = await _service.getLevels(activityId);
      if (levels.isEmpty) {
        emit(const BodilyMazeError('لا توجد مستويات لهذا النشاط'));
        _isLoading = false;
        return;
      }

      // Pick the level to play: the requested start level, else the first.
      debugPrint('BODILY MAZE loadGame | requested startLevelId=$startLevelId');
      debugPrint(
          'BODILY MAZE available levels=${levels.map((l) => "${l.id}(#${l.levelNumber})").toList()}');

      _level = levels.firstWhere(
            (l) => l.id == startLevelId,
        orElse: () => levels.first,
      );

      debugPrint('BODILY MAZE picked levelId=${_level!.id} (#${_level!.levelNumber})');

      // Look up the manually-defined coordinate config for this level.
      final config = mazeConfigs[_level!.id];
      if (config == null) {
        emit(BodilyMazeError(
            'لا توجد إعدادات إحداثيات للمستوى ${_level!.id}. يجب على المطوّر تعريفها.'));
        _isLoading = false;
        return;
      }
      _config = config;

      _attemptNumber = 1;
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
      emit(BodilyMazeError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void _emitLoaded() {
    emit(BodilyMazeLoaded(
      level: _level!,
      config: _config!,
      currentAttemptId: _attemptId,
      attemptNumber: _attemptNumber,
      elapsed: _elapsed,
    ));
  }

  // ─── Ball fell in a hole → failed attempt, reset to start ─────────────────

  Future<void> onBallFellInHole() async {
    if (_completed || _level == null) return;

    try {
      await _service.updateLevelAttempt(
        attemptId: _attemptId,
        completed: false,
      );
      await _service.logLevelEvent(
        childId: childId,
        sessionId: sessionId,
        activitySessionId: activitySessionId,
        action: 'FAILED',
      );

      _attemptNumber += 1;
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

    // Brief feedback — the screen listens for this and resets the ball.
    emit(BodilyMazeFailed(
      currentAttemptId: _attemptId,
      attemptNumber: _attemptNumber,
    ));

    // Return to active play (same maze, ball reset by the game widget).
    _emitLoaded();
  }

  // ─── Ball reached the end → complete ──────────────────────────────────────

  Future<void> onBallReachedEnd() async {
    if (_completed || _level == null) return;
    _completed = true;

    try {
      await _service.updateLevelAttempt(
        attemptId: _attemptId,
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
    final s = state;
    if (s is BodilyMazeLoaded) {
      emit(s.copyWith(elapsed: _elapsed));
    }
  }

  // ─── Exit without completing ──────────────────────────────────────────────

  Future<void> logExitIfNotCompleted() async {
    if (_completed) return;
    try {
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