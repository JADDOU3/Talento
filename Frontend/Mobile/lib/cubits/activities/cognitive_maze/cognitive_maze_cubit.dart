import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../activities/cognitive_maze/config/cognitive_maze_level_config.dart';
import '../../../models/activities/cognitive_maze/cognitive_maze_models.dart';
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
  int _attemptNumber = 1;
  String? _attemptStartedAt;

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

      debugPrint('COGNITIVE MAZE requested startLevelId = $startLevelId');
      debugPrint('COGNITIVE MAZE requested startLevelNumber = $startLevelNumber');

      for (final level in levels) {
        debugPrint(
          'COGNITIVE MAZE LEVEL => id=${level.id}, number=${level.levelNumber}',
        );
      }

      if (levels.isEmpty) {
        emit(const CognitiveMazeError('لا توجد مستويات لهذا النشاط'));
        return;
      }

      CognitiveMazeLevel level;

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
        'COGNITIVE MAZE SELECTED => id=${level.id}, number=${level.levelNumber}',
      );

      final config =
          cognitiveMazeConfigs[level.levelNumber] ?? cognitiveMazeConfigs[level.id];

      if (config == null) {
        emit(
          CognitiveMazeError(
            'لم يتم إعداد إحداثيات المستوى ${level.levelNumber}. '
                'levelId=${level.id}',
          ),
        );
        return;
      }

      if (!config.isStarCollectLevel &&
          (level.correctChoiceIndex == -1 ||
              level.correctChoiceIndex >= config.endPoints.length)) {
        emit(
          const CognitiveMazeError(
            'بيانات الإجابة الصحيحة لهذا المستوى غير مكتملة',
          ),
        );
        return;
      }

      _level = level;
      _config = config;
      _completed = false;
      _attemptNumber = 1;
      _elapsed = Duration.zero;
      _collectedColors.clear();
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
        CognitiveMazeLoaded(
          level: level,
          config: config,
          elapsed: _elapsed,
        ),
      );
    } catch (e) {
      emit(
        CognitiveMazeError(
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
      CognitiveMazeLoaded(
        level: level,
        config: config,
        elapsed: _elapsed,
        collectedColors: Set.of(_collectedColors),
      ),
    );
  }

  void onStarCollected(Color color, bool isTarget) {
    final level = _level;
    final config = _config;

    if (level == null || config == null || _completed) return;

    if (isTarget) {
      _collectedColors.add(color);

      emit(
        CognitiveMazeLoaded(
          level: level,
          config: config,
          elapsed: _elapsed,
          collectedColors: Set.of(_collectedColors),
        ),
      );
    } else {
      emit(
        CognitiveMazeWrongAnswer(
          level: level,
          config: config,
          elapsed: _elapsed,
          collectedColors: Set.of(_collectedColors),
        ),
      );
    }
  }

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
          attemptNumber: _attemptNumber,
          startedAt: _attemptStartedAt ?? DateTime.now().toIso8601String(),
          activitySessionId: activitySessionId,
          levelId: level.id,
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
      _attemptStartedAt = DateTime.now().toIso8601String();

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
      debugPrint('COGNITIVE MAZE WRONG ANSWER ERROR: $e');
    }

    emit(
      CognitiveMazeWrongAnswer(
        level: level,
        config: config,
        elapsed: _elapsed,
      ),
    );
  }

  Future<void> onCorrectAnswer() async {
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
      debugPrint('COGNITIVE MAZE COMPLETE ERROR: $e');
    }

    emit(
      CognitiveMazeComplete(
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
      debugPrint('COGNITIVE MAZE EXIT ERROR: $e');
    }
  }
}