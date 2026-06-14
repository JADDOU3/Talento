import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/activities/conflict_resolution/conflict_resolution_level_model.dart';
import '../../../services/activities/conflict_resolution_service.dart';
import 'conflict_resolution_state.dart';

class ConflictResolutionCubit extends Cubit<ConflictResolutionState> {
  ConflictResolutionCubit({
    ConflictResolutionService? conflictResolutionService,
  })  : _service = conflictResolutionService ?? ConflictResolutionService(),
        super(const ConflictResolutionInitial());

  final ConflictResolutionService _service;

  Timer? _timer;

  late int _activityId;
  late int _activitySessionId;
  late int _childId;
  late int _sessionId;

  bool _activityCompleted = false;
  bool _gameLoaded = false;
  bool _handlingTimeout = false;

  Future<void> loadGame({
    required int activityId,
    required int activitySessionId,
    required int childId,
    required int sessionId,
    int initialLevelNumber = 1,
  }) async {
    emit(const ConflictResolutionLoading());

    _activityId = activityId;
    _activitySessionId = activitySessionId;
    _childId = childId;
    _sessionId = sessionId;
    _activityCompleted = false;
    _gameLoaded = false;
    _handlingTimeout = false;

    try {
      final levels = await _service.getLevelsByActivity(activityId);

      final playableLevels =
      levels.where((level) => level.challenges.isNotEmpty).toList();

      if (playableLevels.isEmpty) {
        emit(
          const ConflictResolutionError(
            'No Conflict Resolution challenges were found.',
          ),
        );
        return;
      }

      final startLevelIndex =
      (initialLevelNumber - 1).clamp(0, playableLevels.length - 1);

      final startLevel = playableLevels[startLevelIndex];

      final firstAttempt = await _createAttemptForLevel(
        level: startLevel,
        attemptNumber: 1,
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

      final firstChallenge = startLevel.challenges.first;

      emit(
        ConflictResolutionLoaded(
          levels: playableLevels,
          currentLevelIndex: startLevelIndex,
          currentChallengeIndex: 0,
          currentAttemptId: firstAttempt.id,
          attemptNumber: 1,
          currentAttemptStartedAt: firstAttempt.startedAt,
          elapsed: Duration.zero,
          videoFinished: !firstChallenge.hasVideo,
          timerSeconds: firstChallenge.timerSeconds,
          timerRemaining: firstChallenge.timerSeconds,
        ),
      );

      _startTimer();
    } catch (error) {
      emit(ConflictResolutionError(error.toString()));
    }
  }

  void onVideoStarted() {
    // Kept for the video widget contract.
    // Continue is unlocked only when the video ends.
  }

  void onVideoFinished() {
    final currentState = state;

    if (currentState is! ConflictResolutionLoaded) return;

    emit(
      currentState.copyWith(
        videoFinished: true,
      ),
    );
  }

  Future<void> onQrScanned(String result) async {
    final currentState = state;

    if (currentState is! ConflictResolutionLoaded) return;

    final challenge = currentState.challenge;

    // TEMP TEST ONLY:
    // Backend currently does not provide CHOICE correct answers for
    // Conflict Resolution. Until correct answers are restored/provided,
    // treat any scanned QR as correct so we can test moving through
    // all challenges and levels.
    //
    // TODO: Remove this fallback before final delivery.
    // Official logic should compare the scanned QR value against
    // challenge.correctAnswerIcon, or map QR card IDs to icons first.
    final bool isCorrect = challenge.hasCorrectAnswer
        ? challenge.isCorrectQrValue(result)
        : true;

    try {
      if (isCorrect) {
        await _handleCorrectAnswer(currentState);
      } else {
        await _handleWrongAnswer(currentState);
      }
    } catch (error) {
      emit(ConflictResolutionError(error.toString()));
    }
  }

  Future<void> _handleCorrectAnswer(
      ConflictResolutionLoaded currentState,
      ) async {
    _handlingTimeout = false;

    emit(
      ConflictResolutionChallengeResult(
        isCorrect: true,
        previousState: currentState,
      ),
    );

    await Future.delayed(const Duration(milliseconds: 900));

    final latestState = state;
    if (latestState is! ConflictResolutionChallengeResult) return;

    final loadedState = latestState.previousState;

    if (!loadedState.isLastChallengeInLevel) {
      final nextChallengeIndex = loadedState.currentChallengeIndex + 1;
      final nextChallenge = loadedState.level.challenges[nextChallengeIndex];

      emit(
        loadedState.copyWith(
          currentChallengeIndex: nextChallengeIndex,
          videoFinished: !nextChallenge.hasVideo,
          timerSeconds: nextChallenge.timerSeconds,
          timerRemaining: nextChallenge.timerSeconds,
          clearTimer: !nextChallenge.hasTimer,
        ),
      );
      return;
    }

    await _updateCurrentAttempt(
      currentState: loadedState,
      completed: true,
    );

    await _service.postLevelEvent(
      childId: _childId,
      sessionId: _sessionId,
      activitySessionId: _activitySessionId,
      action: 'COMPLETED',
    );

    if (loadedState.isLastLevel) {
      await _completeActivity(loadedState.elapsed);
      return;
    }

    emit(
      ConflictResolutionLevelComplete(
        previousState: loadedState,
        message: 'أحسنتِ! أكملتِ المستوى ${loadedState.currentLevelNumber} 🎉',
      ),
    );

    await Future.delayed(const Duration(milliseconds: 900));

    await _moveToNextLevel(loadedState);
  }

  Future<void> _handleWrongAnswer(
      ConflictResolutionLoaded currentState,
      ) async {
    await _updateCurrentAttempt(
      currentState: currentState,
      completed: false,
    );

    await _service.postLevelEvent(
      childId: _childId,
      sessionId: _sessionId,
      activitySessionId: _activitySessionId,
      action: 'FAILED',
    );

    final nextAttemptNumber = currentState.attemptNumber + 1;

    final nextAttempt = await _createAttemptForLevel(
      level: currentState.level,
      attemptNumber: nextAttemptNumber,
    );

    await _service.postLevelEvent(
      childId: _childId,
      sessionId: _sessionId,
      activitySessionId: _activitySessionId,
      action: 'RETRIED',
    );

    emit(
      ConflictResolutionChallengeResult(
        isCorrect: false,
        previousState: currentState.copyWith(
          currentAttemptId: nextAttempt.id,
          attemptNumber: nextAttemptNumber,
          currentAttemptStartedAt: nextAttempt.startedAt,
          videoFinished: true,
          timerSeconds: currentState.challenge.timerSeconds,
          timerRemaining: currentState.challenge.timerSeconds,
          clearTimer: !currentState.challenge.hasTimer,
        ),
      ),
    );
  }

  void returnToChallengeAfterWrong(
      ConflictResolutionLoaded loadedState,
      ) {
    emit(loadedState);
  }

  Future<void> _moveToNextLevel(
      ConflictResolutionLoaded previousState,
      ) async {
    final nextLevelIndex = previousState.currentLevelIndex + 1;
    final nextLevel = previousState.levels[nextLevelIndex];

    final nextAttempt = await _createAttemptForLevel(
      level: nextLevel,
      attemptNumber: 1,
    );

    await _service.postLevelEvent(
      childId: _childId,
      sessionId: _sessionId,
      activitySessionId: _activitySessionId,
      action: 'STARTED',
    );

    final firstChallenge = nextLevel.challenges.first;

    emit(
      previousState.copyWith(
        currentLevelIndex: nextLevelIndex,
        currentChallengeIndex: 0,
        currentAttemptId: nextAttempt.id,
        attemptNumber: 1,
        currentAttemptStartedAt: nextAttempt.startedAt,
        videoFinished: !firstChallenge.hasVideo,
        timerSeconds: firstChallenge.timerSeconds,
        timerRemaining: firstChallenge.timerSeconds,
        clearTimer: !firstChallenge.hasTimer,
      ),
    );
  }

  Future<void> _completeActivity(Duration elapsed) async {
    _activityCompleted = true;
    _timer?.cancel();

    await _service.postActivityEvent(
      childId: _childId,
      sessionId: _sessionId,
      activityId: _activityId,
      action: 'COMPLETED',
    );

    await _service.completeActivitySession(_activitySessionId);

    emit(ConflictResolutionActivityComplete(elapsed: elapsed));
  }

  void onTimerTick() {
    final currentState = state;

    if (currentState is! ConflictResolutionLoaded) return;

    final newElapsed = currentState.elapsed + const Duration(seconds: 1);

    if (currentState.timerRemaining == null) {
      emit(currentState.copyWith(elapsed: newElapsed));
      return;
    }

    final nextRemaining = currentState.timerRemaining! - 1;

    if (nextRemaining <= 0) {
      emit(
        currentState.copyWith(
          elapsed: newElapsed,
          timerRemaining: 0,
        ),
      );

      _handleTimeoutAsWrong(currentState);
      return;
    }

    emit(
      currentState.copyWith(
        elapsed: newElapsed,
        timerRemaining: nextRemaining,
      ),
    );
  }

  Future<void> _handleTimeoutAsWrong(
      ConflictResolutionLoaded currentState,
      ) async {
    if (_handlingTimeout) return;

    _handlingTimeout = true;

    try {
      await _handleWrongAnswer(currentState);
    } catch (error) {
      emit(ConflictResolutionError(error.toString()));
    } finally {
      _handlingTimeout = false;
    }
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) => onTimerTick(),
    );
  }

  Future<_AttemptInfo> _createAttemptForLevel({
    required ConflictResolutionLevelModel level,
    required int attemptNumber,
  }) async {
    final startedAt = DateTime.now().toIso8601String();

    final attemptId = await _service.createLevelAttempt(
      attemptNumber: attemptNumber,
      startedAt: startedAt,
      activitySessionId: _activitySessionId,
      levelId: level.id,
    );

    return _AttemptInfo(
      id: attemptId,
      startedAt: startedAt,
    );
  }

  Future<void> _updateCurrentAttempt({
    required ConflictResolutionLoaded currentState,
    required bool completed,
  }) {
    return _service.updateLevelAttempt(
      attemptId: currentState.currentAttemptId,
      attemptNumber: currentState.attemptNumber,
      startedAt: currentState.currentAttemptStartedAt,
      activitySessionId: _activitySessionId,
      levelId: currentState.level.id,
      completed: completed,
    );
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
      // Do not block screen closing if logging fails.
    }
  }

  @override
  Future<void> close() async {
    _timer?.cancel();
    await endActivityIfNotCompleted();
    return super.close();
  }
}

class _AttemptInfo {
  final int id;
  final String startedAt;

  const _AttemptInfo({
    required this.id,
    required this.startedAt,
  });
}