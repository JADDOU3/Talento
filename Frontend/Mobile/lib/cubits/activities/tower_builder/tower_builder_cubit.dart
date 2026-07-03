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

  bool get _isLastLevel {
    return _currentLevelIndex >= _levels.length - 1;
  }
  bool get _isLastChallenge {
    if (_currentLevel == null) return true;
    return _currentChallengeIndex >= _currentLevel!.challenges.length - 1;
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

      emit(
        TowerBuilderLoaded(
          level: _activeLevel,
          currentAttemptId: _currentAttemptId,
          attemptNumber: _attemptNumber,
          elapsed: Duration.zero,
        ),
      );
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
      _currentChallengeIndex++;

      emit(
        TowerBuilderLoaded(
          level: _activeLevel,
          currentAttemptId: _currentAttemptId,
          attemptNumber: _attemptNumber,
          elapsed: Duration.zero,
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

      emit(const TowerBuilderLevelComplete());
      return;
    }

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

    emit(
      TowerBuilderLoaded(
        level: _activeLevel,
        currentAttemptId: _currentAttemptId,
        attemptNumber: _attemptNumber,
        elapsed: Duration.zero,
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

    emit(
      const TowerBuilderChecklistResult(
        allChecked: false,
      ),
    );

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