import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/activities/shape_creator/shape_creator_level_model.dart';
import '../../../services/activities/shape_creator_service.dart';
import 'shape_creator_state.dart';
import 'dart:async';

class ShapeCreatorCubit extends Cubit<ShapeCreatorState> {
  final ShapeCreatorService _service;

  ShapeCreatorCubit({
    ShapeCreatorService? service,
  })  : _service = service ?? ShapeCreatorService(),
        super(const ShapeCreatorInitial());

  bool _isCompleted = false;

  int? _activityId;
  int? _activitySessionId;
  int? _childId;
  int? _sessionId;

  List<ShapeCreatorLevelModel> _levels = [];
  int _currentLevelIndex = 0;
  int _currentChallengeIndex = 0;

  ShapeCreatorLevelModel? _currentLevel;
  int _attemptNumber = 1;
  int _currentAttemptId = 0;
  String? _currentAttemptStartedAt;
  Timer? _timer;
Duration _elapsed = Duration.zero;

  bool get _isLastLevel {
    return _currentLevelIndex >= _levels.length - 1;
  }

  Future<void> loadGame({
    required int activityId,
    required int activitySessionId,
    required int childId,
    required int sessionId,
  }) async {
    emit(const ShapeCreatorLoading());

    _activityId = activityId;
    _activitySessionId = activitySessionId;
    _childId = childId;
    _sessionId = sessionId;

    try {
      _levels = await _service.getLevels(activityId);

      if (_levels.isEmpty) {
        throw Exception('No Shape Creator levels found.');
      }

      _currentLevelIndex = 0;
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
      _startTimer();

      emit(
        ShapeCreatorLoaded(
          level: level,
          currentAttemptId: _currentAttemptId,
          attemptNumber: _attemptNumber,
          elapsed: _elapsed,
          currentChallengeIndex: _currentChallengeIndex,
        ),
      );
    } catch (error) {
      emit(
        ShapeCreatorError(
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
        const ShapeCreatorError(
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
        ShapeCreatorError(
          message: error.toString(),
        ),
      );
    }
  }

  Future<void> _handleSuccessfulAttempt() async {
    await _completeCurrentAttempt();
    await _logLevelCompleted();

if (_currentLevel != null &&
    _currentChallengeIndex <
        _currentLevel!.challengeImages.length - 1) {
  _currentChallengeIndex++;

  emit(
    ShapeCreatorLoaded(
      level: _currentLevel!,
      currentAttemptId: _currentAttemptId,
      attemptNumber: _attemptNumber,
      elapsed: _elapsed,
      currentChallengeIndex: _currentChallengeIndex,
    ),
  );

  return;
}

if (_isLastLevel) {
  _isCompleted = true;

  await _logActivityCompleted();
  await _completeActivitySession();

  emit(const ShapeCreatorLevelComplete());
  return;
}

// هنا انتهى مستوى لكن ما زال يوجد مستويات أخرى
print("BEFORE LEVEL FINISHED");

emit(
  ShapeCreatorLevelFinished(
    levelNumber: _currentLevel!.levelNumber,
  ),
);

print("AFTER LEVEL FINISHED");

await Future.delayed(
  const Duration(seconds: 2),
);

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
_startTimer();

emit(
  ShapeCreatorLoaded(
    level: nextLevel,
    currentAttemptId: _currentAttemptId,
    attemptNumber: _attemptNumber,
    elapsed: _elapsed,
    currentChallengeIndex: _currentChallengeIndex,
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
    _startTimer();

    emit(
      const ShapeCreatorChecklistResult(
        allChecked: false,
      ),
    );

    emit(
      ShapeCreatorLoaded(
        level: _currentLevel!,
        currentAttemptId: _currentAttemptId,
        attemptNumber: _attemptNumber,
        elapsed: _elapsed,
        currentChallengeIndex: _currentChallengeIndex,
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
      responseLanguage: 'en',
    );
  }

  Future<void> _logActivityCompleted() async {
    await _service.logActivityEvent(
      childId: _childId!,
      sessionId: _sessionId!,
      activityId: _activityId!,
      action: 'COMPLETED',
      responseLanguage: 'en',
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
    _timer?.cancel();
    return super.close();
  }
  void _startTimer() {
  _timer?.cancel();

  _elapsed = Duration.zero;

  _timer = Timer.periodic(
    const Duration(seconds: 1),
    (_) {
      if (state is ShapeCreatorLoaded) {
        final currentState = state as ShapeCreatorLoaded;

        emit(
          ShapeCreatorLoaded(
            level: currentState.level,
            currentAttemptId: currentState.currentAttemptId,
            attemptNumber: currentState.attemptNumber,
            elapsed: Duration(
              seconds: _elapsed.inSeconds + 1,
            ),
            currentChallengeIndex:
                currentState.currentChallengeIndex,
          ),
        );

        _elapsed = Duration(
          seconds: _elapsed.inSeconds + 1,
        );
      }
    },
  );
}
}
