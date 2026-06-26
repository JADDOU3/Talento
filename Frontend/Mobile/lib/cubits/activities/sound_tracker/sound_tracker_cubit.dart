import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/activities/sound_tracker/sound_tracker_level_model.dart';
import '../../../services/activities/sound_tracker_service.dart';
import 'sound_tracker_state.dart';

class SoundTrackerCubit extends Cubit<SoundTrackerState> {
  SoundTrackerCubit({
    SoundTrackerService? soundTrackerService,
  })  : _soundTrackerService = soundTrackerService ?? SoundTrackerService(),
        super(const SoundTrackerInitial());

  final SoundTrackerService _soundTrackerService;

  late int _activityId;
  late int _activitySessionId;
  late int _childId;
  late int _sessionId;

  bool _activityCompleted = false;
  bool _gameLoaded = false;

  Future<void> loadGame({
    required int activityId,
    required int activitySessionId,
    required int childId,
    required int sessionId,
    int? startLevelId,
    int? startLevelNumber,
  }) async {
    emit(const SoundTrackerLoading());

    _activityId = activityId;
    _activitySessionId = activitySessionId;
    _childId = childId;
    _sessionId = sessionId;
    _activityCompleted = false;
    _gameLoaded = false;

    try {
      final levels = await _soundTrackerService.getLevelsByActivity(
        activityId,
      );

      final playableLevels = levels.where((level) => level.hasAudio).toList();

      if (playableLevels.isEmpty) {
        emit(const SoundTrackerError('No Sound Tracker levels were found.'));
        return;
      }

      final startLevelIndex = _resolveStartLevelIndex(
        levels: playableLevels,
        startLevelId: startLevelId,
        startLevelNumber: startLevelNumber,
      );

      final startLevel = playableLevels[startLevelIndex];

      final firstAttempt = await _createAttemptForLevel(
        level: startLevel,
        attemptNumber: 1,
      );

      await _soundTrackerService.postActivityEvent(
        childId: _childId,
        sessionId: _sessionId,
        activityId: _activityId,
        action: 'STARTED',
      );

      await _soundTrackerService.postLevelEvent(
        childId: _childId,
        sessionId: _sessionId,
        activitySessionId: _activitySessionId,
        action: 'STARTED',
      );

      _gameLoaded = true;

      emit(
        _buildLoadedState(
          levels: playableLevels,
          currentLevelIndex: startLevelIndex,
          attempt: firstAttempt,
          attemptNumber: 1,
          audioFinished: false,
        ),
      );
    } catch (error) {
      emit(SoundTrackerError(error.toString()));
    }
  }

  void onAudioFinished() {
    final currentState = state;

    if (currentState is! SoundTrackerLoaded) return;

    if (currentState.audioFinished) return;

    emit(
      currentState.copyWith(
        audioFinished: true,
      ),
    );
  }

  Future<void> onQrScanned(String result) async {
    final currentState = state;

    if (currentState is! SoundTrackerLoaded) return;
    if (currentState.isMultiSection) return;

    final isCorrect = currentState.level.isCorrectForSection(
      sectionIndex: 0,
      scannedValue: result,
    );

    try {
      if (isCorrect) {
        await _handleCorrectLevel(currentState);
      } else {
        await _handleWrongLevel(currentState);
      }
    } catch (error) {
      emit(SoundTrackerError(error.toString()));
    }
  }

  Future<void> onSectionScanned({
    required int sectionIndex,
    required String result,
  }) async {
    final currentState = state;

    if (currentState is! SoundTrackerLoaded) return;
    if (!currentState.isMultiSection) return;
    if (!currentState.canScanSection(sectionIndex)) return;

    final isCorrect = currentState.level.isCorrectForSection(
      sectionIndex: sectionIndex,
      scannedValue: result,
    );

    final updatedAnswered = List<bool>.from(currentState.sectionAnswered);
    final updatedCorrect = List<bool>.from(currentState.sectionCorrect);
    final updatedScannedValues =
    List<String?>.from(currentState.sectionScannedValues);

    updatedAnswered[sectionIndex] = true;
    updatedCorrect[sectionIndex] = isCorrect;
    updatedScannedValues[sectionIndex] = result;

    final updatedState = currentState.copyWith(
      sectionAnswered: updatedAnswered,
      sectionCorrect: updatedCorrect,
      sectionScannedValues: updatedScannedValues,
    );

    emit(updatedState);

    if (!isCorrect) {
      return;
    }

    if (updatedState.allSectionsCorrect) {
      try {
        await _handleCorrectLevel(updatedState);
      } catch (error) {
        emit(SoundTrackerError(error.toString()));
      }
    }
  }

  Future<void> resetWrongSection(int sectionIndex) async {
    final currentState = state;

    if (currentState is! SoundTrackerLoaded) return;
    if (!currentState.isMultiSection) return;
    if (sectionIndex < 0 || sectionIndex >= currentState.sectionCount) return;

    final updatedAnswered = List<bool>.from(currentState.sectionAnswered);
    final updatedCorrect = List<bool>.from(currentState.sectionCorrect);
    final updatedScannedValues =
    List<String?>.from(currentState.sectionScannedValues);

    updatedAnswered[sectionIndex] = false;
    updatedCorrect[sectionIndex] = false;
    updatedScannedValues[sectionIndex] = null;

    emit(
      currentState.copyWith(
        sectionAnswered: updatedAnswered,
        sectionCorrect: updatedCorrect,
        sectionScannedValues: updatedScannedValues,
      ),
    );
  }

  Future<void> _handleCorrectLevel(SoundTrackerLoaded currentState) async {
    await _updateCurrentAttempt(
      currentState: currentState,
      completed: true,
    );

    await _soundTrackerService.postLevelEvent(
      childId: _childId,
      sessionId: _sessionId,
      activitySessionId: _activitySessionId,
      action: 'COMPLETED',
    );

    emit(
      SoundTrackerResult(
        isCorrect: true,
        previousState: currentState,
        message: 'أحسنت! إجابتك صحيحة.',
      ),
    );
  }

  Future<void> _handleWrongLevel(SoundTrackerLoaded currentState) async {
    await _updateCurrentAttempt(
      currentState: currentState,
      completed: false,
    );

    await _soundTrackerService.postLevelEvent(
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

    await _soundTrackerService.postLevelEvent(
      childId: _childId,
      sessionId: _sessionId,
      activitySessionId: _activitySessionId,
      action: 'RETRIED',
    );

    emit(
      SoundTrackerResult(
        isCorrect: false,
        previousState: currentState.copyWith(
          currentAttemptId: nextAttempt.id,
          attemptNumber: nextAttemptNumber,
          currentAttemptStartedAt: nextAttempt.startedAt,
          audioFinished: currentState.audioFinished,
        ),
        message: 'جرّب مرة ثانية.',
      ),
    );
  }

  Future<void> goToNextLevel() async {
    final currentState = state;

    SoundTrackerLoaded? loadedState;

    if (currentState is SoundTrackerLoaded) {
      loadedState = currentState;
    } else if (currentState is SoundTrackerResult) {
      loadedState = currentState.previousState;
    } else if (currentState is SoundTrackerLevelComplete) {
      loadedState = currentState.previousState;
    }

    if (loadedState == null) return;

    try {
      if (loadedState.isLastLevel) {
        await _completeActivity();
        return;
      }

      emit(
        SoundTrackerLevelComplete(
          previousState: loadedState,
          message: _levelCompleteMessage(loadedState.currentLevelNumber),
        ),
      );

      await Future.delayed(const Duration(milliseconds: 700));

      await _moveToNextLevel(loadedState);
    } catch (error) {
      emit(SoundTrackerError(error.toString()));
    }
  }

  Future<void> retryCurrentLevel() async {
    final currentState = state;

    SoundTrackerLoaded? loadedState;

    if (currentState is SoundTrackerResult) {
      loadedState = currentState.previousState;
    } else if (currentState is SoundTrackerLoaded) {
      loadedState = currentState;
    }

    if (loadedState == null) return;

    final cleanState = _buildLoadedState(
      levels: loadedState.levels,
      currentLevelIndex: loadedState.currentLevelIndex,
      attempt: _AttemptInfo(
        id: loadedState.currentAttemptId,
        startedAt: loadedState.currentAttemptStartedAt,
      ),
      attemptNumber: loadedState.attemptNumber,
      audioFinished: false,
    );

    emit(cleanState);
  }

  Future<void> _moveToNextLevel(SoundTrackerLoaded previousState) async {
    final nextLevelIndex = previousState.currentLevelIndex + 1;
    final nextLevel = previousState.levels[nextLevelIndex];

    final nextAttempt = await _createAttemptForLevel(
      level: nextLevel,
      attemptNumber: 1,
    );

    await _soundTrackerService.postLevelEvent(
      childId: _childId,
      sessionId: _sessionId,
      activitySessionId: _activitySessionId,
      action: 'STARTED',
    );

    emit(
      _buildLoadedState(
        levels: previousState.levels,
        currentLevelIndex: nextLevelIndex,
        attempt: nextAttempt,
        attemptNumber: 1,
        audioFinished: false,
      ),
    );
  }

  Future<void> _completeActivity() async {
    _activityCompleted = true;

    await _soundTrackerService.postActivityEvent(
      childId: _childId,
      sessionId: _sessionId,
      activityId: _activityId,
      action: 'COMPLETED',
    );

    await _soundTrackerService.completeActivitySession(_activitySessionId);

    emit(const SoundTrackerActivityComplete());
  }

  SoundTrackerLoaded _buildLoadedState({
    required List<SoundTrackerLevelModel> levels,
    required int currentLevelIndex,
    required _AttemptInfo attempt,
    required int attemptNumber,
    required bool audioFinished,
  }) {
    final level = levels[currentLevelIndex];
    final sectionCount = level.sectionCount;

    return SoundTrackerLoaded(
      levels: levels,
      currentLevelIndex: currentLevelIndex,
      currentAttemptId: attempt.id,
      attemptNumber: attemptNumber,
      currentAttemptStartedAt: attempt.startedAt,
      audioFinished: audioFinished,
      sectionCount: sectionCount,
      sectionAnswered: List<bool>.filled(sectionCount, false),
      sectionCorrect: List<bool>.filled(sectionCount, false),
      sectionScannedValues: List<String?>.filled(sectionCount, null),
    );
  }

  Future<_AttemptInfo> _createAttemptForLevel({
    required SoundTrackerLevelModel level,
    required int attemptNumber,
  }) async {
    final startedAt = DateTime.now().toIso8601String();

    final attemptId = await _soundTrackerService.createLevelAttempt(
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
    required SoundTrackerLoaded currentState,
    required bool completed,
  }) {
    return _soundTrackerService.updateLevelAttempt(
      attemptId: currentState.currentAttemptId,
      attemptNumber: currentState.attemptNumber,
      startedAt: currentState.currentAttemptStartedAt,
      activitySessionId: _activitySessionId,
      levelId: currentState.level.id,
      completed: completed,
    );
  }

  int _resolveStartLevelIndex({
    required List<SoundTrackerLevelModel> levels,
    int? startLevelId,
    int? startLevelNumber,
  }) {
    if (levels.isEmpty) return 0;

    if (startLevelId != null && startLevelId > 0) {
      final indexById = levels.indexWhere(
            (level) => level.id == startLevelId,
      );

      if (indexById != -1) return indexById;
    }

    if (startLevelNumber != null && startLevelNumber > 0) {
      final indexByNumber = levels.indexWhere(
            (level) => level.levelNumber == startLevelNumber,
      );

      if (indexByNumber != -1) return indexByNumber;
    }

    return 0;
  }

  String _levelCompleteMessage(int levelNumber) {
    switch (levelNumber) {
      case 1:
        return 'رائع! تعرفت على الصوت الأول.';
      case 2:
        return 'ممتاز! رتبت صوتين بالطريقة الصحيحة.';
      case 3:
        return 'مذهل! تابعت ثلاثة أصوات بالترتيب.';
      default:
        return 'أحسنت! أنهيت هذا المستوى.';
    }
  }

  Future<void> endActivityIfNotCompleted() async {
    if (_activityCompleted) return;
    if (!_gameLoaded) return;

    try {
      await _soundTrackerService.postActivityEvent(
        childId: _childId,
        sessionId: _sessionId,
        activityId: _activityId,
        action: 'ENDED',
      );
    } catch (_) {
      // Do not block closing the screen if ending event fails.
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