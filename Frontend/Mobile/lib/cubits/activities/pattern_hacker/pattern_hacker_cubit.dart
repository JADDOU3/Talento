import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/activities/pattern_hacker/pattern_hacker_level_model.dart';
import '../../../services/activities/pattern_hacker_service.dart';
import 'pattern_hacker_state.dart';

class PatternHackerCubit extends Cubit<PatternHackerState> {
  PatternHackerCubit({
    PatternHackerService? patternHackerService,
  })  : _service = patternHackerService ?? PatternHackerService(),
        super(const PatternHackerInitial());

  final PatternHackerService _service;

  Timer? _timer;

  late int _activityId;
  late int _activitySessionId;
  late int _childId;
  late int _sessionId;

  bool _activityCompleted = false;
  bool _gameLoaded = false;

  /// Seconds (of elapsed) at the last child interaction — drives hint timing.
  int _lastInteractionSeconds = 0;

  /// Timestamps of recent choice taps — used to detect random pressing.
  final List<DateTime> _recentTaps = <DateTime>[];

  // ---------------------------------------------------------------------------
  // Loading
  // ---------------------------------------------------------------------------

  Future<void> loadGame({
    required int activityId,
    required int activitySessionId,
    required int childId,
    required int sessionId,
    int initialLevelNumber = 1,
  }) async {
    emit(const PatternHackerLoading());

    _activityId = activityId;
    _activitySessionId = activitySessionId;
    _childId = childId;
    _sessionId = sessionId;
    _activityCompleted = false;
    _gameLoaded = false;
    _lastInteractionSeconds = 0;
    _recentTaps.clear();

    try {
      final levels = await _service.getLevelsByActivity(activityId);

      // Keep only levels that actually have at least one playable challenge.
      final playableLevels =
          levels.where((level) => level.challenges.isNotEmpty).toList();

      if (playableLevels.isEmpty) {
        emit(const PatternHackerError('No Pattern Hacker levels were found.'));
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

      emit(
        PatternHackerLoaded(
          levels: playableLevels,
          currentLevelIndex: startLevelIndex,
          currentChallengeIndex: 0,
          selectedIcon: null,
          currentAttemptId: firstAttempt.id,
          attemptNumber: 1,
          currentAttemptStartedAt: firstAttempt.startedAt,
          elapsed: Duration.zero,
        ),
      );

      _startTimer();
    } catch (error) {
      emit(PatternHackerError(error.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Selection
  // ---------------------------------------------------------------------------

  void selectChoice(String iconName) {
    final currentState = state;
    if (currentState is! PatternHackerLoaded) return;

    _lastInteractionSeconds = currentState.elapsed.inSeconds;
    final isRandom = _detectRandomPress();

    // Tapping the already-selected choice clears it.
    if (currentState.selectedIcon == iconName) {
      emit(currentState.copyWith(
        clearSelectedIcon: true,
        hintLevel: 0,
        randomPress: isRandom,
      ));
    } else {
      emit(currentState.copyWith(
        selectedIcon: iconName,
        hintLevel: 0,
        randomPress: isRandom,
      ));
    }

    if (isRandom) _scheduleRandomPressClear();
  }

  /// Returns true if 5+ taps happened within the last 3 seconds.
  bool _detectRandomPress() {
    final now = DateTime.now();
    _recentTaps.add(now);
    _recentTaps.removeWhere(
      (t) => now.difference(t) > const Duration(seconds: 3),
    );
    return _recentTaps.length >= 5;
  }

  void _scheduleRandomPressClear() {
    _recentTaps.clear();
    Future.delayed(const Duration(seconds: 3), () {
      final s = state;
      if (s is PatternHackerLoaded && s.randomPress) {
        emit(s.copyWith(randomPress: false));
      }
    });
  }

  void clearSelection() {
    final currentState = state;
    if (currentState is! PatternHackerLoaded) return;

    _lastInteractionSeconds = currentState.elapsed.inSeconds;
    emit(currentState.copyWith(clearSelectedIcon: true, hintLevel: 0));
  }

  // ---------------------------------------------------------------------------
  // Submit
  // ---------------------------------------------------------------------------

  Future<void> submitAnswer() async {
    final currentState = state;
    if (currentState is! PatternHackerLoaded) return;
    if (!currentState.canSubmit) return;

    final isCorrect = currentState.challenge.isCorrectIcon(
      currentState.selectedIcon!,
    );

    try {
      if (isCorrect) {
        await _handleCorrectAnswer(currentState);
      } else {
        await _handleWrongAnswer(currentState);
      }
    } catch (error) {
      emit(PatternHackerError(error.toString()));
    }
  }

  Future<void> _handleCorrectAnswer(PatternHackerLoaded currentState) async {
    emit(
      PatternHackerChallengeResult(
        isCorrect: true,
        previousState: currentState,
      ),
    );

    await Future.delayed(const Duration(milliseconds: 900));

    final latestState = state;
    if (latestState is! PatternHackerChallengeResult) return;

    final loadedState = latestState.previousState;

    // Not the last challenge in the level -> just move to the next challenge.
    // The level attempt is only "completed" when the whole level is done.
    if (!loadedState.isLastChallengeInLevel) {
      _lastInteractionSeconds = loadedState.elapsed.inSeconds;
      emit(
        loadedState.copyWith(
          currentChallengeIndex: loadedState.currentChallengeIndex + 1,
          clearSelectedIcon: true,
          hintLevel: 0,
        ),
      );
      return;
    }

    // Last challenge in the level -> mark the attempt completed.
    await _updateCurrentAttempt(currentState: loadedState, completed: true);

    await _service.postLevelEvent(
      childId: _childId,
      sessionId: _sessionId,
      activitySessionId: _activitySessionId,
      action: 'COMPLETED',
    );

    // Was this the last level? -> finish the whole activity.
    if (loadedState.isLastLevel) {
      await _completeGame(loadedState.elapsed);
      return;
    }

    // Otherwise show the level-complete animation then load the next level.
    emit(
      PatternHackerLevelComplete(
        previousState: loadedState,
        message: 'أحسنت! أكملت المستوى ${loadedState.currentLevelNumber} 🎉',
      ),
    );

    await Future.delayed(const Duration(milliseconds: 900));

    await _moveToNextLevel(loadedState);
  }

  Future<void> _handleWrongAnswer(PatternHackerLoaded currentState) async {
    // Close the current attempt as not completed.
    await _updateCurrentAttempt(currentState: currentState, completed: false);

    await _service.postLevelEvent(
      childId: _childId,
      sessionId: _sessionId,
      activitySessionId: _activitySessionId,
      action: 'FAILED',
    );

    // Open a fresh attempt for the same level (retry).
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
      PatternHackerChallengeResult(
        isCorrect: false,
        previousState: currentState,
      ),
    );

    await Future.delayed(const Duration(milliseconds: 900));

    final latestState = state;
    if (latestState is! PatternHackerChallengeResult) return;

    // Same challenge again, cleared selection, new attempt.
    _lastInteractionSeconds = currentState.elapsed.inSeconds;
    emit(
      currentState.copyWith(
        currentAttemptId: nextAttempt.id,
        attemptNumber: nextAttemptNumber,
        currentAttemptStartedAt: nextAttempt.startedAt,
        clearSelectedIcon: true,
        hintLevel: 0,
      ),
    );
  }

  /// Public helper required by the spec — advances to the next challenge in the
  /// current level if there is one.
  void nextChallenge() {
    final currentState = state;
    if (currentState is! PatternHackerLoaded) return;
    if (currentState.isLastChallengeInLevel) return;

    emit(
      currentState.copyWith(
        currentChallengeIndex: currentState.currentChallengeIndex + 1,
        clearSelectedIcon: true,
      ),
    );
  }

  Future<void> _moveToNextLevel(PatternHackerLoaded previousState) async {
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

    _lastInteractionSeconds = previousState.elapsed.inSeconds;
    emit(
      previousState.copyWith(
        currentLevelIndex: nextLevelIndex,
        currentChallengeIndex: 0,
        clearSelectedIcon: true,
        currentAttemptId: nextAttempt.id,
        attemptNumber: 1,
        currentAttemptStartedAt: nextAttempt.startedAt,
        hintLevel: 0,
      ),
    );
  }

  Future<void> _completeGame(Duration elapsed) async {
    _activityCompleted = true;
    _timer?.cancel();

    await _service.postActivityEvent(
      childId: _childId,
      sessionId: _sessionId,
      activityId: _activityId,
      action: 'COMPLETED',
    );

    await _service.completeActivitySession(_activitySessionId);

    emit(PatternHackerGameComplete(elapsed: elapsed));
  }

  // ---------------------------------------------------------------------------
  // Attempt helpers
  // ---------------------------------------------------------------------------

  Future<_AttemptInfo> _createAttemptForLevel({
    required PatternHackerLevelModel level,
    required int attemptNumber,
  }) async {
    final startedAt = DateTime.now().toIso8601String();

    final attemptId = await _service.createLevelAttempt(
      attemptNumber: attemptNumber,
      startedAt: startedAt,
      activitySessionId: _activitySessionId,
      levelId: level.id,
    );

    return _AttemptInfo(id: attemptId, startedAt: startedAt);
  }

  Future<void> _updateCurrentAttempt({
    required PatternHackerLoaded currentState,
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

  // ---------------------------------------------------------------------------
  // Timer (UI only — backend does not store duration)
  // ---------------------------------------------------------------------------

  void onTimerTick() {
    final currentState = state;
    if (currentState is! PatternHackerLoaded) return;

    final newElapsed = currentState.elapsed + const Duration(seconds: 1);

    // Every 20 seconds of inactivity raises the hint level (capped at 4).
    final inactivity = newElapsed.inSeconds - _lastInteractionSeconds;
    final newHintLevel = (inactivity ~/ 20).clamp(0, 4);

    emit(
      currentState.copyWith(
        elapsed: newElapsed,
        hintLevel: newHintLevel,
      ),
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => onTimerTick(),
    );
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

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
      // Never block closing the screen if the ENDED event fails.
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
