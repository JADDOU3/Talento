import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../activities/emotional_maze/config/emotional_maze_level_config.dart';
import '../../../models/activities/emotional_maze/emotional_maze_models.dart';
import '../../../services/activities/emotional_maze_service.dart';
import 'emotional_maze_state.dart';

class EmotionalMazeCubit extends Cubit<EmotionalMazeState> {
  EmotionalMazeCubit({
    required this.service,
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
  }) : super(const EmotionalMazeInitial());

  final EmotionalMazeService service;
  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;

  EmotionalMazeLevel? _level;
  MazeLevelConfig? _config;

  int? _attemptId;
  int _attemptNumber = 1;
  String? _attemptStartedAt;

  Duration _elapsed = Duration.zero;
  bool _completed = false;

  Future<void> loadGame({
    int? startLevelId,
    int? startLevelNumber,
  }) async {
    emit(const EmotionalMazeLoading());

    try {
      final levels = await service.getLevels(activityId);

      debugPrint('EMOTIONAL MAZE requested startLevelId = $startLevelId');
      debugPrint('EMOTIONAL MAZE requested startLevelNumber = $startLevelNumber');

      for (final level in levels) {
        debugPrint(
          'EMOTIONAL MAZE LEVEL => id=${level.id}, number=${level.levelNumber}',
        );
      }

      if (levels.isEmpty) {
        emit(const EmotionalMazeError('لا توجد مستويات لهذا النشاط'));
        return;
      }

      EmotionalMazeLevel level;

      if (startLevelNumber != null && startLevelNumber > 0) {
        level = levels.firstWhere(
              (item) => item.levelNumber == startLevelNumber,
          orElse: () => levels.first,
        );
      } else if (startLevelId != null && startLevelId > 0) {
        level = levels.firstWhere(
              (item) => item.id == startLevelId,
          orElse: () => levels.first,
        );
      } else {
        level = levels.first;
      }

      debugPrint(
        'EMOTIONAL MAZE SELECTED => id=${level.id}, number=${level.levelNumber}',
      );

      final config =
          emotionalMazeConfigs[level.levelNumber] ?? emotionalMazeConfigs[level.id];

      if (config == null) {
        emit(
          EmotionalMazeError(
            'لم يتم إعداد إحداثيات المستوى ${level.levelNumber}. '
                'levelId=${level.id}',
          ),
        );
        return;
      }

      _level = level;
      _config = config;
      _completed = false;
      _elapsed = Duration.zero;
      _attemptNumber = 1;
      _attemptStartedAt = DateTime.now().toIso8601String();

      _attemptId = await service.createLevelAttempt(
        attemptNumber: _attemptNumber,
        activitySessionId: activitySessionId,
        levelId: level.id,
      );

      unawaited(
        service.logActivityEvent(
          childId: childId,
          sessionId: sessionId,
          activityId: activityId,
          action: 'STARTED',
        ),
      );

      unawaited(
        service.logLevelEvent(
          childId: childId,
          sessionId: sessionId,
          activitySessionId: activitySessionId,
          action: 'STARTED',
        ),
      );

      emit(
        EmotionalMazeLoaded(
          level: level,
          config: config,
          elapsed: _elapsed,
        ),
      );
    } catch (e) {
      emit(
        EmotionalMazeError(
          e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  void onTimerTick() {
    final level = _level;
    final config = _config;

    if (level == null || config == null || _completed) return;

    _elapsed += const Duration(seconds: 1);

    emit(
      EmotionalMazeLoaded(
        level: level,
        config: config,
        elapsed: _elapsed,
      ),
    );
  }

  Future<void> onFinished() async {
    final level = _level;

    if (level == null || _completed) return;

    _completed = true;

    try {
      if (_attemptId != null) {
        await service.updateLevelAttempt(
          attemptId: _attemptId!,
          attemptNumber: _attemptNumber,
          startedAt: _attemptStartedAt ?? DateTime.now().toIso8601String(),
          activitySessionId: activitySessionId,
          levelId: level.id,
          completed: true,
        );
      }

      await service.logLevelEvent(
        childId: childId,
        sessionId: sessionId,
        activitySessionId: activitySessionId,
        action: 'COMPLETED',
      );

      await service.logActivityEvent(
        childId: childId,
        sessionId: sessionId,
        activityId: activityId,
        action: 'COMPLETED',
      );

      await service.completeActivitySession(activitySessionId);
    } catch (e) {
      debugPrint('EMOTIONAL MAZE COMPLETE ERROR: $e');
    }

    emit(
      EmotionalMazeComplete(
        level: level,
        elapsed: _elapsed,
      ),
    );
  }

  Future<void> logExitIfNotCompleted() async {
    final level = _level;

    if (_completed || _attemptId == null || level == null) return;

    try {
      await service.updateLevelAttempt(
        attemptId: _attemptId!,
        attemptNumber: _attemptNumber,
        startedAt: _attemptStartedAt ?? DateTime.now().toIso8601String(),
        activitySessionId: activitySessionId,
        levelId: level.id,
        completed: false,
      );

      await service.logActivityEvent(
        childId: childId,
        sessionId: sessionId,
        activityId: activityId,
        action: 'ENDED',
      );
    } catch (e) {
      debugPrint('EMOTIONAL MAZE EXIT ERROR: $e');
    }
  }
}