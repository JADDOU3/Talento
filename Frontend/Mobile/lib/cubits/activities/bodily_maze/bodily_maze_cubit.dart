import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../activities/bodily_maze/config/bodily_maze_level_config.dart';
import '../../../models/activities/bodily_maze/bodily_maze_models.dart';
import '../../../services/activities/bodily_maze_service.dart';
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
  bool _isCompleting = false;

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
      debugPrint(
        'BODILY MAZE requested startLevelNumber = $startLevelNumber',
      );

      for (final level in levels) {
        debugPrint(
          'BODILY MAZE LEVEL => '
              'id=${level.id}, number=${level.levelNumber}',
        );
      }

      if (levels.isEmpty) {
        emit(const BodilyMazeError('لا توجد مستويات لهذا النشاط'));
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
        'BODILY MAZE SELECTED => '
            'id=${_level!.id}, number=${_level!.levelNumber}',
      );

      final config =
          mazeConfigs[_level!.levelNumber] ?? mazeConfigs[_level!.id];

      if (config == null) {
        emit(
          BodilyMazeError(
            'لا توجد إعدادات إحداثيات للمستوى '
                '${_level!.levelNumber}. levelId=${_level!.id}',
          ),
        );
        return;
      }

      _config = config;

      _completed = false;
      _isCompleting = false;
      _elapsed = Duration.zero;
      _attemptNumber = 1;

      _attemptStartedAt = DateTime.now().toUtc().toIso8601String();

      _attemptId = await _service.createLevelAttempt(
        attemptNumber: _attemptNumber,
        startedAt: _attemptStartedAt!,
        activitySessionId: activitySessionId,
        levelId: _level!.id,
      );

      await _runSafely(
        label: 'BODILY MAZE START ACTIVITY EVENT ERROR',
        action: () => _service.logActivityEvent(
          childId: childId,
          sessionId: sessionId,
          activityId: activityId,
          action: 'STARTED',
        ),
      );

      await _runSafely(
        label: 'BODILY MAZE START LEVEL EVENT ERROR',
        action: () => _service.logLevelEvent(
          childId: childId,
          sessionId: sessionId,
          activitySessionId: activitySessionId,
          action: 'STARTED',
        ),
      );

      _emitLoaded();
    } catch (error) {
      emit(
        BodilyMazeError(
          error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    } finally {
      _isLoading = false;
    }
  }

  void _emitLoaded() {
    if (_level == null || _config == null) return;

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

  Future<void> onBallFellInHole() async {
    if (_completed ||
        _isCompleting ||
        _level == null ||
        _attemptId <= 0) {
      return;
    }

    try {
      await _service.updateLevelAttempt(
        attemptId: _attemptId,
        attemptNumber: _attemptNumber,
        startedAt:
        _attemptStartedAt ?? DateTime.now().toUtc().toIso8601String(),
        activitySessionId: activitySessionId,
        levelId: _level!.id,
        completed: false,
      );

      await _runSafely(
        label: 'BODILY MAZE FAILED LEVEL EVENT ERROR',
        action: () => _service.logLevelEvent(
          childId: childId,
          sessionId: sessionId,
          activitySessionId: activitySessionId,
          action: 'FAILED',
        ),
      );

      _attemptNumber += 1;
      _attemptStartedAt = DateTime.now().toUtc().toIso8601String();

      _attemptId = await _service.createLevelAttempt(
        attemptNumber: _attemptNumber,
        startedAt: _attemptStartedAt!,
        activitySessionId: activitySessionId,
        levelId: _level!.id,
      );

      await _runSafely(
        label: 'BODILY MAZE RETRIED LEVEL EVENT ERROR',
        action: () => _service.logLevelEvent(
          childId: childId,
          sessionId: sessionId,
          activitySessionId: activitySessionId,
          action: 'RETRIED',
        ),
      );

      emit(
        BodilyMazeFailed(
          currentAttemptId: _attemptId,
          attemptNumber: _attemptNumber,
        ),
      );

      _emitLoaded();
    } catch (error) {
      debugPrint('BODILY MAZE FAIL ERROR: $error');

      emit(
        BodilyMazeError(
          error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> onBallReachedEnd() async {
    if (_completed || _isCompleting || _level == null) return;

    if (_attemptId <= 0) {
      emit(
        const BodilyMazeError(
          'تعذر العثور على محاولة المستوى الحالية',
        ),
      );
      return;
    }

    _isCompleting = true;

    try {
      await _service.updateLevelAttempt(
        attemptId: _attemptId,
        attemptNumber: _attemptNumber,
        startedAt:
        _attemptStartedAt ?? DateTime.now().toUtc().toIso8601String(),
        activitySessionId: activitySessionId,
        levelId: _level!.id,
        completed: true,
      );

      // حفظ إكمال الـActivity Session أساسي، لذلك يتم قبل الـEvents.
      await _service.completeActivitySession(activitySessionId);

      _completed = true;

      // فشل تسجيل الـEvents لا يجب أن يمنع حفظ التقدم.
      await _runSafely(
        label: 'BODILY MAZE COMPLETED LEVEL EVENT ERROR',
        action: () => _service.logLevelEvent(
          childId: childId,
          sessionId: sessionId,
          activitySessionId: activitySessionId,
          action: 'COMPLETED',
        ),
      );

      await _runSafely(
        label: 'BODILY MAZE COMPLETED ACTIVITY EVENT ERROR',
        action: () => _service.logActivityEvent(
          childId: childId,
          sessionId: sessionId,
          activityId: activityId,
          action: 'COMPLETED',
        ),
      );

      emit(const BodilyMazeComplete());
    } catch (error) {
      _completed = false;

      debugPrint('BODILY MAZE COMPLETE ERROR: $error');

      emit(
        const BodilyMazeError(
          'تعذر حفظ تقدم النشاط، حاول مرة أخرى',
        ),
      );
    } finally {
      _isCompleting = false;
    }
  }

  void onTimerTick() {
    if (_completed || _isCompleting) return;

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

  Future<void> logExitIfNotCompleted() async {
    if (_completed || _level == null || _attemptId <= 0) return;

    try {
      await _service.updateLevelAttempt(
        attemptId: _attemptId,
        attemptNumber: _attemptNumber,
        startedAt:
        _attemptStartedAt ?? DateTime.now().toUtc().toIso8601String(),
        activitySessionId: activitySessionId,
        levelId: _level!.id,
        completed: false,
      );

      await _runSafely(
        label: 'BODILY MAZE EXIT EVENT ERROR',
        action: () => _service.logActivityEvent(
          childId: childId,
          sessionId: sessionId,
          activityId: activityId,
          action: 'ENDED',
        ),
      );
    } catch (error) {
      debugPrint('BODILY MAZE EXIT ERROR: $error');
    }
  }

  Future<void> _runSafely({
    required String label,
    required Future<void> Function() action,
  }) async {
    try {
      await action();
    } catch (error) {
      debugPrint('$label: $error');
    }
  }
}
