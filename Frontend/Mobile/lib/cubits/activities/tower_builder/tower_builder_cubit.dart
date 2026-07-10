import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/activities/tower_builder/tower_builder_level_model.dart';
import '../../../services/activities/tower_builder_service.dart';
import 'tower_builder_state.dart';

class TowerBuilderCubit extends Cubit<TowerBuilderState> {
  final TowerBuilderService _service;

  TowerBuilderCubit({
    TowerBuilderService? service,
  })  : _service = service ?? TowerBuilderService(),
        super(const TowerBuilderInitial());

  bool _isCompleted = false;
  bool _isContinuingResult = false;

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

  Future<void> loadGame({
    required int activityId,
    required int activitySessionId,
    required int childId,
    required int sessionId,
    int? startLevelId,
  }) async {
    emit(const TowerBuilderLoading());

    _activityId = activityId;
    _activitySessionId = activitySessionId;
    _childId = childId;
    _sessionId = sessionId;

    _isCompleted = false;
    _isContinuingResult = false;
    _pendingAction = _TowerBuilderPendingAction.none;

    try {
      _levels = await _service.getLevels(activityId);

      if (_levels.isEmpty) {
        throw Exception('No Tower Builder levels found.');
      }

      if (startLevelId != null) {
        final foundIndex = _levels.indexWhere(
              (level) => level.id == startLevelId,
        );

        _currentLevelIndex = foundIndex == -1 ? 0 : foundIndex;
      } else {
        _currentLevelIndex = 0;
      }

      _currentChallengeIndex = 0;
      _attemptNumber = 1;

      final level = _levels[_currentLevelIndex];

      final attemptInfo = await _service.createLevelAttempt(
        attemptNumber: _attemptNumber,
        activitySessionId: activitySessionId,
        levelId: level.id,
      );

      _currentLevel = level;
      _currentAttemptId = attemptInfo.id;
      _currentAttemptStartedAt = attemptInfo.startedAt;

      await _logActivityStarted();
      await _logLevelStarted();

      _emitLoaded();
    } catch (error) {
      emit(
        TowerBuilderError(
          message: error.toString(),
        ),
      );
    }
  }

  void onHintPressed() {
    // Part 2 placeholder.
  }

  Future<void> onChecklistSubmitted({
    required bool allChecked,
  }) async {
    if (_currentLevel == null ||
        _activitySessionId == null ||
        _currentAttemptStartedAt == null) {
      emit(
        const TowerBuilderError(
          message: 'No active level attempt found.',
        ),
      );
      return;
    }

    if (state is TowerBuilderChecklistResult || _isContinuingResult) {
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
          message: error.toString(),
        ),
      );
    }
  }

  Future<void> _handleSuccessfulAttempt() async {
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
      _isCompleted = true;

      await _logActivityCompleted();
      await _completeActivitySession();

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

    _pendingAction = _TowerBuilderPendingAction.retryCurrentChallenge;

    emit(
      const TowerBuilderChecklistResult(
        allChecked: false,
      ),
    );
  }

  /// Continues only after the child presses the button on the shared
  /// feedback screen. There is no automatic transition from result states.
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
          _currentChallengeIndex++;
          _emitLoaded();
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
          message: error.toString(),
        ),
      );
    } finally {
      _isContinuingResult = false;
    }
  }

  Future<void> _moveToNextLevel() async {
    _currentLevelIndex++;
    _currentChallengeIndex = 0;
    _attemptNumber = 1;

    final nextLevel = _levels[_currentLevelIndex];

    final nextAttemptInfo = await _service.createLevelAttempt(
      attemptNumber: _attemptNumber,
      activitySessionId: _activitySessionId!,
      levelId: nextLevel.id,
    );

    _currentLevel = nextLevel;
    _currentAttemptId = nextAttemptInfo.id;
    _currentAttemptStartedAt = nextAttemptInfo.startedAt;

    await _logLevelStarted();

    _emitLoaded();
  }

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
      responseLanguage: 'en',
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
    if (!_isCompleted &&
        _activityId != null &&
        _activitySessionId != null &&
        _childId != null &&
        _sessionId != null) {
      try {
        await _logActivityEnded();
      } catch (_) {
        // Avoid crashing while disposing the cubit.
      }
    }

    return super.close();
  }
}

enum _TowerBuilderPendingAction {
  none,
  retryCurrentChallenge,
  nextChallenge,
  nextLevel,
}
