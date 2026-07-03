import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/activities/cognitive_maze/cognitive_maze_models.dart';
import '../../activities/cognitive_maze/config/cognitive_maze_level_config.dart';
import '../../../services/activities/cognitive_maze_service.dart';
import 'cognitive_maze_state.dart';

class CognitiveMazeCubit extends Cubit<CognitiveMazeState> {
  CognitiveMazeCubit({
    required this.service,
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
  }) : super(const CognitiveMazeInitial());

  final CognitiveMazeService service;
  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;

  CognitiveMazeLevel? _level;
  CognitiveMazeLevelConfig? _config;
  int? _attemptId;
  final int _attemptNumber = 1;
  Duration _elapsed = Duration.zero;
  bool _completed = false;

  Future<void> loadGame({int? startLevelId}) async {
    emit(const CognitiveMazeLoading());
    try {
      final levels = await service.getLevels(activityId);
      if (levels.isEmpty) {
        emit(const CognitiveMazeError('لا توجد مستويات لهذا النشاط'));
        return;
      }

      final level = startLevelId != null
          ? levels.firstWhere(
            (l) => l.id == startLevelId,
        orElse: () => levels.first,
      )
          : levels.first;

      final config = cognitiveMazeConfigs[level.id];
      if (config == null) {
        emit(const CognitiveMazeError('لم يتم إعداد إحداثيات هذا المستوى بعد'));
        return;
      }
      if (level.correctChoiceIndex == -1 ||
          level.correctChoiceIndex >= config.endPoints.length) {
        // Mirrors the Tower Builder-style product decision needed when
        // level data doesn't have exactly one valid correct choice — fail
        // loudly instead of silently picking a wrong/no answer as "correct".
        emit(const CognitiveMazeError('بيانات الإجابة الصحيحة لهذا المستوى غير مكتملة'));
        return;
      }

      _level = level;
      _config = config;
      _completed = false;
      _elapsed = Duration.zero;

      _attemptId = await service.createLevelAttempt(
        attemptNumber: _attemptNumber,
        activitySessionId: activitySessionId,
        levelId: level.id,
      );

      unawaited(service.logActivityEvent(
        childId: childId,
        sessionId: sessionId,
        activityId: activityId,
        action: 'START',
      ));
      unawaited(service.logLevelEvent(
        childId: childId,
        sessionId: sessionId,
        activitySessionId: activitySessionId,
        action: 'START',
      ));

      emit(CognitiveMazeLoaded(level: level, config: config, elapsed: _elapsed));
    } catch (e) {
      emit(CognitiveMazeError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  void onTimerTick() {
    final level = _level;
    final config = _config;
    if (level == null || config == null || _completed) return;
    _elapsed += const Duration(seconds: 1);
    emit(CognitiveMazeLoaded(level: level, config: config, elapsed: _elapsed));
  }

  /// Called by the game screen the instant the ball lands on a WRONG
  /// endpoint. The ball has already been reset to start by the game engine
  /// itself — this just logs it and lets the UI show a "try again" toast.
  void onWrongAnswer(int chosenIndex) {
    final level = _level;
    final config = _config;
    if (level == null || config == null || _completed) return;

    unawaited(service.logLevelEvent(
      childId: childId,
      sessionId: sessionId,
      activitySessionId: activitySessionId,
      action: 'WRONG_ANSWER',
    ));

    emit(CognitiveMazeWrongAnswer(level: level, config: config, elapsed: _elapsed));
  }

  /// Called by the game screen the instant the ball lands on the CORRECT
  /// endpoint.
  Future<void> onCorrectAnswer() async {
    final level = _level;
    if (level == null || _completed) return;
    _completed = true;

    try {
      if (_attemptId != null) {
        await service.updateLevelAttempt(attemptId: _attemptId!, completed: true);
      }
      await service.logLevelEvent(
        childId: childId,
        sessionId: sessionId,
        activitySessionId: activitySessionId,
        action: 'FINISH',
      );
      await service.logActivityEvent(
        childId: childId,
        sessionId: sessionId,
        activityId: activityId,
        action: 'FINISH',
      );
      await service.completeActivitySession(activitySessionId);
    } catch (_) {
      // Completion feedback still shows even if a background log call fails.
    }

    emit(CognitiveMazeComplete(level: level, elapsed: _elapsed));
  }

  Future<void> logExitIfNotCompleted() async {
    if (_completed || _attemptId == null) return;
    try {
      await service.updateLevelAttempt(attemptId: _attemptId!, completed: false);
      await service.logLevelEvent(
        childId: childId,
        sessionId: sessionId,
        activitySessionId: activitySessionId,
        action: 'EXIT',
      );
    } catch (_) {}
  }
}