import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../models/activities/pattern_hacker/pattern_hacker_level_model.dart';
import '../../../services/activities/pattern_hacker_service.dart';
import 'pattern_hacker_state.dart';

class PatternHackerCubit extends Cubit<PatternHackerState> {
  PatternHackerCubit({
    PatternHackerService? patternHackerService,
  })  : _service = patternHackerService ?? PatternHackerService(),
        super(const PatternHackerInitial());

  final PatternHackerService _service;

  static const FlutterSecureStorage _progressStorage =
  FlutterSecureStorage();

  late int _activityId;
  late int _activitySessionId;
  late int _childId;
  late int _sessionId;

  bool _activityCompleted = false;
  bool _gameLoaded = false;
  bool _isProcessingAction = false;

  String get _progressStorageKey {
    return 'pattern_hacker_progress_child_${_childId}_activity_$_activityId';
  }

  // ---------------------------------------------------------------------------
  // Local progress backup
  // ---------------------------------------------------------------------------

  Future<_PatternHackerSavedProgress?> _readSavedProgress() async {
    final raw = await _progressStorage.read(
      key: _progressStorageKey,
    );

    if (raw == null || raw.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);

      if (decoded is! Map) return null;

      final levelIndex = _readInt(decoded['levelIndex']);
      final challengeIndex = _readInt(decoded['challengeIndex']);

      if (levelIndex == null || levelIndex < 0) return null;

      return _PatternHackerSavedProgress(
        levelIndex: levelIndex,
        challengeIndex: challengeIndex ?? 0,
      );
    } catch (_) {
      return null;
    }
  }

  int? _readInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  Future<void> _saveProgress({
    required int levelIndex,
    required int challengeIndex,
  }) async {
    await _progressStorage.write(
      key: _progressStorageKey,
      value: jsonEncode({
        'levelIndex': levelIndex,
        'challengeIndex': challengeIndex,
        'updatedAt': DateTime.now().toIso8601String(),
      }),
    );
  }

  Future<void> _clearSavedProgress() async {
    await _progressStorage.delete(
      key: _progressStorageKey,
    );
  }

  // ---------------------------------------------------------------------------
  // Loading
  // ---------------------------------------------------------------------------

  Future<void> loadGame({
    required int activityId,
    required int activitySessionId,
    required int childId,
    required int sessionId,
    int initialLevelNumber = 1,
    int? startLevelId,
  }) async {
    emit(const PatternHackerLoading());

    _activityId = activityId;
    _activitySessionId = activitySessionId;
    _childId = childId;
    _sessionId = sessionId;
    _activityCompleted = false;
    _gameLoaded = false;
    _isProcessingAction = false;

    try {
      final levels = await _service.getLevelsByActivity(activityId);

      // Keep only levels that actually have at least one playable challenge.
      final playableLevels =
      levels.where((level) => level.challenges.isNotEmpty).toList();

      if (playableLevels.isEmpty) {
        emit(const PatternHackerError('No Pattern Hacker levels were found.'));
        return;
      }

      final startPosition = await _resolveStartPosition(
        levels: playableLevels,
        startLevelId: startLevelId,
        initialLevelNumber: initialLevelNumber,
      );

      final startLevel = playableLevels[startPosition.levelIndex];

      final firstAttempt = await _createAttemptForLevel(
        level: startLevel,
        attemptNumber: 1,
      );

      await _saveProgress(
        levelIndex: startPosition.levelIndex,
        challengeIndex: startPosition.challengeIndex,
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
          currentLevelIndex: startPosition.levelIndex,
          currentChallengeIndex: startPosition.challengeIndex,
          selectedIcon: null,
          currentAttemptId: firstAttempt.id,
          attemptNumber: 1,
          currentAttemptStartedAt: firstAttempt.startedAt,
          elapsed: Duration.zero,
        ),
      );
    } catch (error) {
      emit(PatternHackerError(error.toString()));
    }
  }

  Future<_PatternHackerStartPosition> _resolveStartPosition({
    required List<PatternHackerLevelModel> levels,
    required int? startLevelId,
    required int initialLevelNumber,
  }) async {
    if (levels.isEmpty) {
      return const _PatternHackerStartPosition(
        levelIndex: 0,
        challengeIndex: 0,
      );
    }

    int backendLevelIndex = 0;

    if (startLevelId != null && startLevelId > 0) {
      final indexFromProgress = levels.indexWhere(
            (level) => level.id == startLevelId,
      );

      if (indexFromProgress != -1) {
        backendLevelIndex = indexFromProgress;
      } else {
        backendLevelIndex = _levelIndexFromNumber(
          initialLevelNumber: initialLevelNumber,
          levelsLength: levels.length,
        );
      }
    } else {
      backendLevelIndex = _levelIndexFromNumber(
        initialLevelNumber: initialLevelNumber,
        levelsLength: levels.length,
      );
    }

    final savedProgress = await _readSavedProgress();

    if (savedProgress != null &&
        savedProgress.levelIndex >= 0 &&
        savedProgress.levelIndex < levels.length) {
      final maxChallengeIndex =
          levels[savedProgress.levelIndex].challenges.length - 1;

      final savedChallengeIndex = _clampInt(
        savedProgress.challengeIndex,
        0,
        maxChallengeIndex,
      );

      if (savedProgress.levelIndex > backendLevelIndex ||
          savedProgress.levelIndex == backendLevelIndex) {
        return _PatternHackerStartPosition(
          levelIndex: savedProgress.levelIndex,
          challengeIndex: savedChallengeIndex,
        );
      }
    }

    return _PatternHackerStartPosition(
      levelIndex: backendLevelIndex,
      challengeIndex: 0,
    );
  }

  int _levelIndexFromNumber({
    required int initialLevelNumber,
    required int levelsLength,
  }) {
    if (levelsLength <= 0) return 0;

    if (initialLevelNumber <= 0 || initialLevelNumber > levelsLength) {
      return 0;
    }

    return _clampInt(initialLevelNumber - 1, 0, levelsLength - 1);
  }

  int _clampInt(int value, int min, int max) {
    if (max < min) return min;
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  // ---------------------------------------------------------------------------
  // Selection
  // ---------------------------------------------------------------------------

  void selectChoice(String iconName) {
    final currentState = state;
    if (currentState is! PatternHackerLoaded) return;

    // Tapping the selected choice again clears it.
    if (currentState.selectedIcon == iconName) {
      emit(
        currentState.copyWith(
          clearSelectedIcon: true,
        ),
      );
      return;
    }

    emit(
      currentState.copyWith(
        selectedIcon: iconName,
      ),
    );
  }

  void clearSelection() {
    final currentState = state;
    if (currentState is! PatternHackerLoaded) return;

    emit(
      currentState.copyWith(
        clearSelectedIcon: true,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Submit
  // ---------------------------------------------------------------------------

  Future<void> submitAnswer() async {
    final currentState = state;
    if (currentState is! PatternHackerLoaded) return;
    if (!currentState.canSubmit) return;
    if (_isProcessingAction) return;

    _isProcessingAction = true;

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
    } finally {
      _isProcessingAction = false;
    }
  }

  Future<void> _handleCorrectAnswer(PatternHackerLoaded currentState) async {
    if (!currentState.isLastChallengeInLevel) {
      emit(
        PatternHackerChallengeResult(
          isCorrect: true,
          previousState: currentState,
        ),
      );
      return;
    }

    await _updateCurrentAttempt(
      currentState: currentState,
      completed: true,
    );

    await _service.postLevelEvent(
      childId: _childId,
      sessionId: _sessionId,
      activitySessionId: _activitySessionId,
      action: 'COMPLETED',
    );

    if (currentState.isLastLevel) {
      await _completeGame(currentState.elapsed);
      return;
    }

    emit(
      PatternHackerLevelComplete(
        previousState: currentState,
        message: 'أحسنت! أكملت المستوى ${currentState.currentLevelNumber} 🎉',
      ),
    );
  }

  Future<void> _handleWrongAnswer(PatternHackerLoaded currentState) async {
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

    emit(
      PatternHackerChallengeResult(
        isCorrect: false,
        previousState: currentState,
      ),
    );
  }

  Future<void> continueAfterChallengeResult() async {
    final currentState = state;

    if (currentState is! PatternHackerChallengeResult) return;
    if (!currentState.isCorrect) return;
    if (_isProcessingAction) return;

    _isProcessingAction = true;

    try {
      final loadedState = currentState.previousState;
      final nextChallengeIndex = loadedState.currentChallengeIndex + 1;

      await _saveProgress(
        levelIndex: loadedState.currentLevelIndex,
        challengeIndex: nextChallengeIndex,
      );

      emit(
        loadedState.copyWith(
          currentChallengeIndex: nextChallengeIndex,
          clearSelectedIcon: true,
        ),
      );
    } catch (error) {
      emit(PatternHackerError(error.toString()));
    } finally {
      _isProcessingAction = false;
    }
  }

  Future<void> retryCurrentChallenge() async {
    final currentState = state;

    if (currentState is! PatternHackerChallengeResult) return;
    if (currentState.isCorrect) return;
    if (_isProcessingAction) return;

    _isProcessingAction = true;

    try {
      final loadedState = currentState.previousState;
      final nextAttemptNumber = loadedState.attemptNumber + 1;

      final nextAttempt = await _createAttemptForLevel(
        level: loadedState.level,
        attemptNumber: nextAttemptNumber,
      );

      await _service.postLevelEvent(
        childId: _childId,
        sessionId: _sessionId,
        activitySessionId: _activitySessionId,
        action: 'RETRIED',
      );

      await _saveProgress(
        levelIndex: loadedState.currentLevelIndex,
        challengeIndex: loadedState.currentChallengeIndex,
      );

      emit(
        loadedState.copyWith(
          currentAttemptId: nextAttempt.id,
          attemptNumber: nextAttemptNumber,
          currentAttemptStartedAt: nextAttempt.startedAt,
          clearSelectedIcon: true,
        ),
      );
    } catch (error) {
      emit(PatternHackerError(error.toString()));
    } finally {
      _isProcessingAction = false;
    }
  }

  Future<void> continueAfterLevelComplete() async {
    final currentState = state;

    if (currentState is! PatternHackerLevelComplete) return;
    if (_isProcessingAction) return;

    _isProcessingAction = true;

    try {
      await _moveToNextLevel(currentState.previousState);
    } catch (error) {
      emit(PatternHackerError(error.toString()));
    } finally {
      _isProcessingAction = false;
    }
  }

  /// Public helper required by the spec — advances to the next challenge in the
  /// current level if there is one.
  void nextChallenge() {
    final currentState = state;
    if (currentState is! PatternHackerLoaded) return;
    if (currentState.isLastChallengeInLevel) return;

    final nextChallengeIndex = currentState.currentChallengeIndex + 1;

    unawaited(
      _saveProgress(
        levelIndex: currentState.currentLevelIndex,
        challengeIndex: nextChallengeIndex,
      ),
    );

    emit(
      currentState.copyWith(
        currentChallengeIndex: nextChallengeIndex,
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

    await _saveProgress(
      levelIndex: nextLevelIndex,
      challengeIndex: 0,
    );

    emit(
      previousState.copyWith(
        currentLevelIndex: nextLevelIndex,
        currentChallengeIndex: 0,
        clearSelectedIcon: true,
        currentAttemptId: nextAttempt.id,
        attemptNumber: 1,
        currentAttemptStartedAt: nextAttempt.startedAt,
      ),
    );
  }

  Future<void> _completeGame(Duration elapsed) async {
    _activityCompleted = true;

    await _service.postActivityEvent(
      childId: _childId,
      sessionId: _sessionId,
      activityId: _activityId,
      action: 'COMPLETED',
    );

    await _service.completeActivitySession(_activitySessionId);
    await _clearSavedProgress();

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

    return _AttemptInfo(
      id: attemptId,
      startedAt: startedAt,
    );
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
  // Lifecycle
  // ---------------------------------------------------------------------------

  Future<void> endActivityIfNotCompleted() async {
    if (_activityCompleted) return;
    if (!_gameLoaded) return;

    final currentState = state;

    if (currentState is PatternHackerLoaded) {
      await _saveProgress(
        levelIndex: currentState.currentLevelIndex,
        challengeIndex: currentState.currentChallengeIndex,
      );
    }

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

class _PatternHackerSavedProgress {
  final int levelIndex;
  final int challengeIndex;

  const _PatternHackerSavedProgress({
    required this.levelIndex,
    required this.challengeIndex,
  });
}

class _PatternHackerStartPosition {
  final int levelIndex;
  final int challengeIndex;

  const _PatternHackerStartPosition({
    required this.levelIndex,
    required this.challengeIndex,
  });
}