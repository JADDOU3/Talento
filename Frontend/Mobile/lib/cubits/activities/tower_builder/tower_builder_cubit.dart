import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../models/activities/tower_builder/tower_builder_level_model.dart';
import '../../../services/activities/tower_builder_service.dart';
import 'tower_builder_state.dart';

class TowerBuilderCubit extends Cubit<TowerBuilderState> {
  final TowerBuilderService _service;

  static const FlutterSecureStorage _progressStorage =
  FlutterSecureStorage();

  TowerBuilderCubit({
    TowerBuilderService? service,
  })  : _service = service ?? TowerBuilderService(),
        super(const TowerBuilderInitial());

  bool _isCompleted = false;
  bool _isContinuingResult = false;
  bool _isLoading = false;
  bool _exitLogged = false;

  int? _activityId;
  int? _activitySessionId;
  int? _childId;
  int? _sessionId;

  List<TowerBuilderLevelModel> _levels = [];
  int _currentLevelIndex = 0;
  int _currentChallengeIndex = 0;

  TowerBuilderLevelModel? _currentLevel;
  int _attemptNumber = 1;
  int _currentAttemptId = 0;
  String? _currentAttemptStartedAt;

  _TowerBuilderPendingAction _pendingAction =
      _TowerBuilderPendingAction.none;

  bool get _isLastLevel {
    return _currentLevelIndex >= _levels.length - 1;
  }

  bool get _isLastChallenge {
    final currentLevel = _currentLevel;

    if (currentLevel == null) return true;

    return _currentChallengeIndex >= currentLevel.challenges.length - 1;
  }

  TowerBuilderLevelModel get _activeLevel {
    return _currentLevel!.withActiveChallenge(_currentChallengeIndex);
  }

  String? get _progressStorageKey {
    final childId = _childId;
    final activityId = _activityId;

    if (childId == null || activityId == null) return null;

    return 'tower_builder_progress_child_${childId}_activity_$activityId';
  }

  // ===================== LOCAL PROGRESS BACKUP =====================

  Future<_TowerBuilderSavedProgress?> _readSavedProgress() async {
    final key = _progressStorageKey;
    if (key == null) return null;

    final raw = await _progressStorage.read(key: key);

    if (raw == null || raw.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);

      if (decoded is! Map) return null;

      final levelIndex = _readInt(decoded['levelIndex']);
      final challengeIndex = _readInt(decoded['challengeIndex']);

      if (levelIndex == null || levelIndex < 0) return null;

      return _TowerBuilderSavedProgress(
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
    final key = _progressStorageKey;
    if (key == null) return;

    await _progressStorage.write(
      key: key,
      value: jsonEncode({
        'levelIndex': levelIndex,
        'challengeIndex': challengeIndex,
        'updatedAt': DateTime.now().toIso8601String(),
      }),
    );
  }

  Future<void> _clearSavedProgress() async {
    final key = _progressStorageKey;
    if (key == null) return;

    await _progressStorage.delete(key: key);
  }

  // ===================== LOAD =====================

  Future<void> loadGame({
    required int activityId,
    required int activitySessionId,
    required int childId,
    required int sessionId,
    int? startLevelId,
    int initialLevelNumber = 1,
  }) async {
    if (_isLoading) return;
    _isLoading = true;

    emit(const TowerBuilderLoading());

    _activityId = activityId;
    _activitySessionId = activitySessionId;
    _childId = childId;
    _sessionId = sessionId;

    _isCompleted = false;
    _isContinuingResult = false;
    _exitLogged = false;
    _pendingAction = _TowerBuilderPendingAction.none;

    try {
      _levels = await _service.getLevels(activityId);

      _levels = _levels
          .where((level) => level.challenges.isNotEmpty)
          .toList();

      if (_levels.isEmpty) {
        throw Exception('لا توجد مستويات أو تحديات لنشاط بناء البرج.');
      }

      final startPosition = await _resolveStartPosition(
        levels: _levels,
        startLevelId: startLevelId,
        initialLevelNumber: initialLevelNumber,
      );

      _currentLevelIndex = startPosition.levelIndex;
      _currentChallengeIndex = startPosition.challengeIndex;
      _currentLevel = _levels[_currentLevelIndex];

      await _saveProgress(
        levelIndex: _currentLevelIndex,
        challengeIndex: _currentChallengeIndex,
      );

      _attemptNumber = 1;

      debugPrint(
        'TOWER BUILDER: starting from '
            'levelIndex=$_currentLevelIndex, '
            'challengeIndex=$_currentChallengeIndex, '
            'levelId=${_currentLevel!.id}',
      );

      final attemptInfo = await _service.createLevelAttempt(
        attemptNumber: _attemptNumber,
        activitySessionId: activitySessionId,
        levelId: _currentLevel!.id,
      );

      _currentAttemptId = attemptInfo.id;
      _currentAttemptStartedAt = attemptInfo.startedAt;

      await _logActivityStarted();
      await _logLevelStarted();

      _isLoading = false;
      _emitLoaded();
    } catch (error) {
      _isLoading = false;

      emit(
        TowerBuilderError(
          message: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<_TowerBuilderStartPosition> _resolveStartPosition({
    required List<TowerBuilderLevelModel> levels,
    required int? startLevelId,
    required int initialLevelNumber,
  }) async {
    if (levels.isEmpty) {
      return const _TowerBuilderStartPosition(
        levelIndex: 0,
        challengeIndex: 0,
      );
    }

    int backendLevelIndex;

    if (startLevelId != null && startLevelId > 0) {
      final indexFromId = levels.indexWhere(
            (level) => level.id == startLevelId,
      );

      backendLevelIndex = indexFromId == -1
          ? _levelIndexFromNumber(
        initialLevelNumber: initialLevelNumber,
        levelsLength: levels.length,
      )
          : indexFromId;
    } else {
      backendLevelIndex = _levelIndexFromNumber(
        initialLevelNumber: initialLevelNumber,
        levelsLength: levels.length,
      );
    }

    final savedProgress = await _readSavedProgress();

    if (savedProgress != null &&
        savedProgress.levelIndex >= 0 &&
        savedProgress.levelIndex < levels.length &&
        savedProgress.levelIndex >= backendLevelIndex) {
      final maxChallengeIndex =
          levels[savedProgress.levelIndex].challenges.length - 1;

      return _TowerBuilderStartPosition(
        levelIndex: savedProgress.levelIndex,
        challengeIndex: _clampInt(
          savedProgress.challengeIndex,
          0,
          maxChallengeIndex,
        ),
      );
    }

    return _TowerBuilderStartPosition(
      levelIndex: backendLevelIndex,
      challengeIndex: 0,
    );
  }

  int _levelIndexFromNumber({
    required int initialLevelNumber,
    required int levelsLength,
  }) {
    if (levelsLength <= 0) return 0;

    if (initialLevelNumber <= 0 ||
        initialLevelNumber > levelsLength) {
      return 0;
    }

    return _clampInt(
      initialLevelNumber - 1,
      0,
      levelsLength - 1,
    );
  }

  int _clampInt(int value, int min, int max) {
    if (max < min) return min;
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  void onHintPressed() {
    // Part 2 placeholder.
  }

  // ===================== CHECKLIST RESULT =====================

  Future<void> onChecklistSubmitted({
    required bool allChecked,
  }) async {
    if (_currentLevel == null ||
        _activitySessionId == null ||
        _currentAttemptStartedAt == null) {
      emit(
        const TowerBuilderError(
          message: 'لا توجد محاولة مستوى فعّالة.',
        ),
      );
      return;
    }

    if (state is TowerBuilderChecklistResult ||
        state is TowerBuilderLevelComplete ||
        _isContinuingResult) {
      return;
    }

    try {
      if (allChecked) {
        await _handleSuccessfulAttempt();
      } else {
        await _handleFailedAttempt();
      }
    } catch (error) {
      emit(
        TowerBuilderError(
          message: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _handleSuccessfulAttempt() async {
    // Tower Builder may contain several challenges inside one backend level.
    // Keep the same level attempt active between those challenges, and only
    // mark the backend level as completed after its final challenge.
    if (!_isLastChallenge) {
      _pendingAction = _TowerBuilderPendingAction.nextChallenge;

      emit(
        const TowerBuilderChecklistResult(
          allChecked: true,
        ),
      );
      return;
    }

    await _completeCurrentAttempt();
    await _logLevelCompleted();

    if (_isLastLevel) {
      await _completeActivity();

      _pendingAction = _TowerBuilderPendingAction.none;
      emit(const TowerBuilderLevelComplete());
      return;
    }

    _pendingAction = _TowerBuilderPendingAction.nextLevel;

    emit(
      const TowerBuilderChecklistResult(
        allChecked: true,
      ),
    );
  }

  Future<void> _handleFailedAttempt() async {
    await _failCurrentAttempt();
    await _logLevelFailed();

    _attemptNumber++;

    final newAttemptInfo = await _service.createLevelAttempt(
      attemptNumber: _attemptNumber,
      activitySessionId: _activitySessionId!,
      levelId: _currentLevel!.id,
    );

    _currentAttemptId = newAttemptInfo.id;
    _currentAttemptStartedAt = newAttemptInfo.startedAt;

    await _logLevelRetried();

    await _saveProgress(
      levelIndex: _currentLevelIndex,
      challengeIndex: _currentChallengeIndex,
    );

    _pendingAction = _TowerBuilderPendingAction.retryCurrentChallenge;

    emit(
      const TowerBuilderChecklistResult(
        allChecked: false,
      ),
    );
  }

  /// Continues only after the child presses the button on the unified
  /// feedback screen. There is no automatic transition.
  Future<void> continueAfterChecklistResult() async {
    if (state is! TowerBuilderChecklistResult) return;
    if (_isContinuingResult) return;

    _isContinuingResult = true;

    final pendingAction = _pendingAction;
    _pendingAction = _TowerBuilderPendingAction.none;

    try {
      switch (pendingAction) {
        case _TowerBuilderPendingAction.retryCurrentChallenge:
          _emitLoaded();
          break;

        case _TowerBuilderPendingAction.nextChallenge:
          await _moveToNextChallenge();
          break;

        case _TowerBuilderPendingAction.nextLevel:
          await _moveToNextLevel();
          break;

        case _TowerBuilderPendingAction.none:
          break;
      }
    } catch (error) {
      emit(
        TowerBuilderError(
          message: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    } finally {
      _isContinuingResult = false;
    }
  }

  Future<void> _moveToNextChallenge() async {
    _currentChallengeIndex++;

    await _saveProgress(
      levelIndex: _currentLevelIndex,
      challengeIndex: _currentChallengeIndex,
    );

    // The backend attempt belongs to the whole level, so the same attempt
    // remains active while moving between challenges in that level.
    _emitLoaded();
  }

  Future<void> _moveToNextLevel() async {
    _currentLevelIndex++;
    _currentChallengeIndex = 0;
    _attemptNumber = 1;
    _currentLevel = _levels[_currentLevelIndex];

    await _saveProgress(
      levelIndex: _currentLevelIndex,
      challengeIndex: _currentChallengeIndex,
    );

    final nextAttemptInfo = await _service.createLevelAttempt(
      attemptNumber: _attemptNumber,
      activitySessionId: _activitySessionId!,
      levelId: _currentLevel!.id,
    );

    _currentAttemptId = nextAttemptInfo.id;
    _currentAttemptStartedAt = nextAttemptInfo.startedAt;

    await _logLevelStarted();

    _emitLoaded();
  }

  // ===================== ATTEMPTS =====================

  Future<void> _completeCurrentAttempt() async {
    await _service.updateLevelAttempt(
      attemptId: _currentAttemptId,
      attemptNumber: _attemptNumber,
      startedAt: _currentAttemptStartedAt!,
      activitySessionId: _activitySessionId!,
      levelId: _currentLevel!.id,
      completed: true,
    );
  }

  Future<void> _failCurrentAttempt() async {
    await _service.updateLevelAttempt(
      attemptId: _currentAttemptId,
      attemptNumber: _attemptNumber,
      startedAt: _currentAttemptStartedAt!,
      activitySessionId: _activitySessionId!,
      levelId: _currentLevel!.id,
      completed: false,
    );
  }

  // ===================== ACTIVITY COMPLETION =====================

  Future<void> _completeActivity() async {
    if (_isCompleted) return;

    await _logActivityCompleted();
    await _completeActivitySession();

    _isCompleted = true;
    await _clearSavedProgress();
  }

  // ===================== EXIT =====================

  Future<void> logExitIfNotCompleted() async {
    if (_isCompleted || _exitLogged) return;

    _exitLogged = true;

    try {
      await _saveProgress(
        levelIndex: _currentLevelIndex,
        challengeIndex: _currentChallengeIndex,
      );

      await _logActivityEnded();
    } catch (error) {
      debugPrint('TOWER BUILDER EXIT ERROR: $error');
    }
  }

  // ===================== STATE =====================

  void _emitLoaded() {
    if (_currentLevel == null) return;

    emit(
      TowerBuilderLoaded(
        level: _activeLevel,
        currentAttemptId: _currentAttemptId,
        attemptNumber: _attemptNumber,
        elapsed: Duration.zero,
      ),
    );
  }

  // ===================== EVENTS =====================

  Future<void> _logActivityStarted() async {
    await _service.logActivityEvent(
      childId: _childId!,
      sessionId: _sessionId!,
      activityId: _activityId!,
      action: 'STARTED',
      responseLanguage: 'ar',
    );
  }

  Future<void> _logActivityCompleted() async {
    await _service.logActivityEvent(
      childId: _childId!,
      sessionId: _sessionId!,
      activityId: _activityId!,
      action: 'COMPLETED',
      responseLanguage: 'ar',
    );
  }

  Future<void> _logActivityEnded() async {
    await _service.logActivityEvent(
      childId: _childId!,
      sessionId: _sessionId!,
      activityId: _activityId!,
      action: 'ENDED',
      responseLanguage: 'ar',
    );
  }

  Future<void> _logLevelStarted() async {
    await _service.logLevelEvent(
      childId: _childId!,
      sessionId: _sessionId!,
      activitySessionId: _activitySessionId!,
      action: 'STARTED',
    );
  }

  Future<void> _logLevelCompleted() async {
    await _service.logLevelEvent(
      childId: _childId!,
      sessionId: _sessionId!,
      activitySessionId: _activitySessionId!,
      action: 'COMPLETED',
    );
  }

  Future<void> _logLevelFailed() async {
    await _service.logLevelEvent(
      childId: _childId!,
      sessionId: _sessionId!,
      activitySessionId: _activitySessionId!,
      action: 'FAILED',
    );
  }

  Future<void> _logLevelRetried() async {
    await _service.logLevelEvent(
      childId: _childId!,
      sessionId: _sessionId!,
      activitySessionId: _activitySessionId!,
      action: 'RETRIED',
    );
  }

  Future<void> _completeActivitySession() async {
    await _service.completeActivitySession(_activitySessionId!);
  }

  @override
  Future<void> close() async {
    await logExitIfNotCompleted();
    return super.close();
  }
}

class _TowerBuilderSavedProgress {
  final int levelIndex;
  final int challengeIndex;

  const _TowerBuilderSavedProgress({
    required this.levelIndex,
    required this.challengeIndex,
  });
}

class _TowerBuilderStartPosition {
  final int levelIndex;
  final int challengeIndex;

  const _TowerBuilderStartPosition({
    required this.levelIndex,
    required this.challengeIndex,
  });
}

enum _TowerBuilderPendingAction {
  none,
  retryCurrentChallenge,
  nextChallenge,
  nextLevel,
}
