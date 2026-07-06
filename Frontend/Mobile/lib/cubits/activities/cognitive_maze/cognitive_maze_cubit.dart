import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/activities/cognitive_maze/cognitive_maze_models.dart';
import '../../../activities/cognitive_maze/config/cognitive_maze_level_config.dart';
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
  // No longer final -- a wrong answer starts a new attempt, matching the
  // Color Lab Step C flow (attemptNumber + 1 per retry).
  int _attemptNumber = 1;
  Duration _elapsed = Duration.zero;
  bool _completed = false;

  final Set<Color> _collectedColors = {};

  Future<void> loadGame({
    int? startLevelId,
    int? startLevelNumber,
  }) async {
    emit(const CognitiveMazeLoading());

    try {
      final levels = await service.getLevels(activityId);

      debugPrint('Requested startLevelNumber = $startLevelNumber');

      for (final l in levels) {
        debugPrint(
          'Level: id=${l.id}, number=${l.levelNumber}',
        );
      }

      if (levels.isEmpty) {
        emit(const CognitiveMazeError('لا توجد مستويات لهذا النشاط'));
        return;
      }

      CognitiveMazeLevel level;

      if (startLevelNumber != null) {
        level = levels.firstWhere(
              (l) => l.levelNumber == startLevelNumber,
          orElse: () => levels.first,
        );
      } else if (startLevelId != null) {
        level = levels.firstWhere(
              (l) => l.id == startLevelId,
          orElse: () => levels.first,
        );
      } else {
        level = levels.first;
      }

      final config = cognitiveMazeConfigs[level.id];

      // ... keep the rest of your code exactly the same

      if (config == null) {
        emit(const CognitiveMazeError('لم يتم إعداد إحداثيات هذا المستوى بعد'));
        return;
      }

      if (!config.isStarCollectLevel &&
          (level.correctChoiceIndex == -1 ||
              level.correctChoiceIndex >= config.endPoints.length)) {
        emit(const CognitiveMazeError(
            'بيانات الإجابة الصحيحة لهذا المستوى غير مكتملة'));
        return;
      }

      _level = level;
      _config = config;
      _completed = false;
      _attemptNumber = 1;
      _elapsed = Duration.zero;
      _collectedColors.clear();

      // Step A -- Color Lab pattern: create attempt, then STARTED events.
      _attemptId = await service.createLevelAttempt(
        attemptNumber: _attemptNumber,
        activitySessionId: activitySessionId,
        levelId: level.id,
      );

      unawaited(service.logActivityEvent(
        childId: childId,
        sessionId: sessionId,
        activityId: activityId,
        action: 'STARTED',
      ));

      unawaited(service.logLevelEvent(
        childId: childId,
        sessionId: sessionId,
        activitySessionId: activitySessionId,
        action: 'STARTED',
      ));

      emit(CognitiveMazeLoaded(
        level: level,
        config: config,
        elapsed: _elapsed,
      ));
    } catch (e) {
      emit(CognitiveMazeError(
        e.toString().replaceFirst('Exception: ', ''),
      ));
    }
  }

  void onTimerTick() {
    final level = _level;
    final config = _config;

    if (level == null || config == null || _completed) return;

    _elapsed += const Duration(seconds: 1);

    emit(CognitiveMazeLoaded(
      level: level,
      config: config,
      elapsed: _elapsed,
    ));
  }

  /// Called when the player collects a star. Star pickups are just visual
  /// progress toward the endpoint check -- they don't submit an answer by
  /// themselves, so no level-attempt/event calls happen here. The actual
  /// correct/wrong submission is _checkStarEndpoint() in the game engine,
  /// which calls onCorrectAnswer()/onWrongAnswer() below.
  void onStarCollected(Color color, bool isTarget) {
    final level = _level;
    final config = _config;

    if (level == null || config == null || _completed) return;

    if (isTarget) {
      _collectedColors.add(color);

      emit(CognitiveMazeLoaded(
        level: level,
        config: config,
        elapsed: _elapsed,
        collectedColors: Set.of(_collectedColors),
      ));
    } else {
      emit(CognitiveMazeWrongAnswer(
        level: level,
        config: config,
        elapsed: _elapsed,
        collectedColors: Set.of(_collectedColors),
      ));
    }
  }

  /// Called by the game screen the instant the ball lands on a WRONG
  /// endpoint (or fails the star-collect check). Matches Color Lab's
  /// Step C exactly: close out the failed attempt, log FAILED, open a
  /// new attempt, log RETRIED. The ball has already been reset to start
  /// by the game engine itself.
  Future<void> onWrongAnswer(int chosenIndex) async {
    final level = _level;
    final config = _config;

    if (level == null || config == null || _completed) return;

    _collectedColors.clear();

    final failedAttemptId = _attemptId;

    try {
      if (failedAttemptId != null) {
        await service.updateLevelAttempt(
          attemptId: failedAttemptId,
          completed: false,
        );
      }

      await service.logLevelEvent(
        childId: childId,
        sessionId: sessionId,
        activitySessionId: activitySessionId,
        action: 'FAILED',
      );

      _attemptNumber += 1;
      _attemptId = await service.createLevelAttempt(
        attemptNumber: _attemptNumber,
        activitySessionId: activitySessionId,
        levelId: level.id,
      );

      await service.logLevelEvent(
        childId: childId,
        sessionId: sessionId,
        activitySessionId: activitySessionId,
        action: 'RETRIED',
      );
    } catch (e) {
      debugPrint('COGNITIVE MAZE COMPLETE ERROR: $e');
    }
    emit(CognitiveMazeWrongAnswer(
      level: level,
      config: config,
      elapsed: _elapsed,
    ));
  }

  /// Called by the game screen the instant the ball lands on the CORRECT
  /// endpoint. Matches Color Lab's Step B exactly.
  Future<void> onCorrectAnswer() async {
    final level = _level;

    if (level == null || _completed) return;

    _completed = true;

    try {
      if (_attemptId != null) {
        await service.updateLevelAttempt(
          attemptId: _attemptId!,
          completed: true,
        );
      }

      await service.logLevelEvent(
        childId: childId,
        sessionId: sessionId,
        activitySessionId: activitySessionId,
        action: 'COMPLETED',
      );

      // Each Cognitive Maze card covers a single level (levelFrom ==
      // levelTo per the roadmap payload), so completing this level always
      // completes the activity for this card -- there's no multi-challenge
      // "last challenge in last level" check needed here like Color Lab's
      // multi-target-per-level structure.
      await service.logActivityEvent(
        childId: childId,
        sessionId: sessionId,
        activityId: activityId,
        action: 'COMPLETED',
      );

      await service.completeActivitySession(activitySessionId);
    } catch (_) {
      // Completion feedback still shows even if a background log call fails.
    }

    emit(CognitiveMazeComplete(
      level: level,
      elapsed: _elapsed,
    ));
  }

  Future<void> logExitIfNotCompleted() async {
    if (_completed || _attemptId == null) return;

    try {
      await service.updateLevelAttempt(
        attemptId: _attemptId!,
        completed: false,
      );

      await service.logActivityEvent(
        childId: childId,
        sessionId: sessionId,
        activityId: activityId,
        action: 'ENDED',
      );
    } catch (_) {}
  }
}