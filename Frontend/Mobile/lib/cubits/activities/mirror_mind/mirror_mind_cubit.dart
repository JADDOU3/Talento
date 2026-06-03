import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/activities/mirror_mind/mirror_mind_level_model.dart';
import '../../../services/activities/mirror_mind_service.dart';
import 'mirror_mind_state.dart';

class MirrorMindCubit extends Cubit<MirrorMindState> {
  MirrorMindCubit({
    MirrorMindService? mirrorMindService,
  })  : _mirrorMindService = mirrorMindService ?? MirrorMindService(),
        super(const MirrorMindInitial());

  final MirrorMindService _mirrorMindService;

  Timer? _timer;

  late int _activityId;
  late int _activitySessionId;
  late int _childId;
  late int _sessionId;

  bool _activityCompleted = false;

  Future<void> loadGame({
    required int activityId,
    required int activitySessionId,
    required int childId,
    required int sessionId,
  }) async {
    emit(const MirrorMindLoading());

    _activityId = activityId;
    _activitySessionId = activitySessionId;
    _childId = childId;
    _sessionId = sessionId;
    _activityCompleted = false;

    try {
      final levels = await _mirrorMindService.getLevelsByActivity(activityId);

      final playableLevels = levels
          .where((level) => level.challenges.isNotEmpty)
          .take(3)
          .toList();

      if (playableLevels.isEmpty) {
        emit(const MirrorMindError('No Mirror Mind levels were found.'));
        return;
      }

      final firstAttemptId = await _createAttemptForLevel(
        level: playableLevels.first,
        attemptNumber: 1,
      );

      await _mirrorMindService.postActivityEvent(
        childId: _childId,
        sessionId: _sessionId,
        activityId: _activityId,
        action: 'STARTED',
      );

      await _mirrorMindService.postLevelEvent(
        childId: _childId,
        sessionId: _sessionId,
        activitySessionId: _activitySessionId,
        action: 'STARTED',
      );

      emit(
        MirrorMindLoaded(
          levels: playableLevels,
          currentLevelIndex: 0,
          currentChallengeIndex: 0,
          selectedIcon: null,
          currentAttemptId: firstAttemptId,
          attemptNumber: 1,
          elapsed: Duration.zero,
        ),
      );

      _startTimer();
    } catch (error) {
      emit(MirrorMindError(error.toString()));
    }
  }

  void selectChoice(String iconName) {
    final currentState = state;

    if (currentState is! MirrorMindLoaded) return;

    if (currentState.selectedIcon == iconName) {
      emit(currentState.copyWith(clearSelectedIcon: true));
      return;
    }

    emit(currentState.copyWith(selectedIcon: iconName));
  }

  void clearSelection() {
    final currentState = state;

    if (currentState is! MirrorMindLoaded) return;

    emit(currentState.copyWith(clearSelectedIcon: true));
  }

  Future<void> submitAnswer() async {
    final currentState = state;

    if (currentState is! MirrorMindLoaded) return;
    if (!currentState.canSubmit) return;

    final selectedIcon = currentState.selectedIcon!;

    final isCorrect = currentState.challenge.isCorrectChoice(selectedIcon);

    try {
      if (isCorrect) {
        await _handleCorrectAnswer(currentState);
      } else {
        await _handleWrongAnswer(currentState);
      }
    } catch (error) {
      emit(MirrorMindError(error.toString()));
    }
  }

  Future<void> _handleCorrectAnswer(MirrorMindLoaded currentState) async {
    await _mirrorMindService.updateLevelAttempt(
      attemptId: currentState.currentAttemptId,
      completed: true,
    );

    await _mirrorMindService.postLevelEvent(
      childId: _childId,
      sessionId: _sessionId,
      activitySessionId: _activitySessionId,
      action: 'COMPLETED',
    );

    emit(
      MirrorMindChallengeResult(
        isCorrect: true,
        previousState: currentState,
      ),
    );

    await Future.delayed(const Duration(milliseconds: 900));

    final latestState = state;

    if (latestState is! MirrorMindChallengeResult) return;

    final loadedState = latestState.previousState;

    if (!loadedState.isLastChallengeInLevel) {
      final nextState = loadedState.copyWith(
        currentChallengeIndex: loadedState.currentChallengeIndex + 1,
        clearSelectedIcon: true,
      );

      emit(nextState);
      return;
    }

    if (loadedState.isLastPartOneLevel ||
        loadedState.currentLevelIndex >= loadedState.levels.length - 1) {
      await _completePartOne(loadedState.elapsed);
      return;
    }

    emit(MirrorMindLevelComplete(previousState: loadedState));

    await Future.delayed(const Duration(milliseconds: 900));

    await _moveToNextLevel(loadedState);
  }

  Future<void> _handleWrongAnswer(MirrorMindLoaded currentState) async {
    await _mirrorMindService.updateLevelAttempt(
      attemptId: currentState.currentAttemptId,
      completed: false,
    );

    await _mirrorMindService.postLevelEvent(
      childId: _childId,
      sessionId: _sessionId,
      activitySessionId: _activitySessionId,
      action: 'FAILED',
    );

    final nextAttemptNumber = currentState.attemptNumber + 1;

    final nextAttemptId = await _createAttemptForLevel(
      level: currentState.level,
      attemptNumber: nextAttemptNumber,
    );

    await _mirrorMindService.postLevelEvent(
      childId: _childId,
      sessionId: _sessionId,
      activitySessionId: _activitySessionId,
      action: 'RETRIED',
    );

    emit(
      MirrorMindChallengeResult(
        isCorrect: false,
        previousState: currentState,
      ),
    );

    await Future.delayed(const Duration(milliseconds: 900));

    final latestState = state;

    if (latestState is! MirrorMindChallengeResult) return;

    emit(
      currentState.copyWith(
        currentAttemptId: nextAttemptId,
        attemptNumber: nextAttemptNumber,
        clearSelectedIcon: true,
      ),
    );
  }

  Future<void> _moveToNextLevel(MirrorMindLoaded previousState) async {
    final nextLevelIndex = previousState.currentLevelIndex + 1;
    final nextLevel = previousState.levels[nextLevelIndex];

    final nextAttemptId = await _createAttemptForLevel(
      level: nextLevel,
      attemptNumber: 1,
    );

    await _mirrorMindService.postLevelEvent(
      childId: _childId,
      sessionId: _sessionId,
      activitySessionId: _activitySessionId,
      action: 'STARTED',
    );

    emit(
      previousState.copyWith(
        currentLevelIndex: nextLevelIndex,
        currentChallengeIndex: 0,
        clearSelectedIcon: true,
        currentAttemptId: nextAttemptId,
        attemptNumber: 1,
      ),
    );
  }

  Future<void> _completePartOne(Duration elapsed) async {
    _activityCompleted = true;
    _timer?.cancel();

    await _mirrorMindService.postActivityEvent(
      childId: _childId,
      sessionId: _sessionId,
      activityId: _activityId,
      action: 'COMPLETED',
    );

    await _mirrorMindService.completeActivitySession(_activitySessionId);

    emit(MirrorMindPartOneComplete(elapsed: elapsed));
  }

  Future<int> _createAttemptForLevel({
    required MirrorMindLevelModel level,
    required int attemptNumber,
  }) {
    return _mirrorMindService.createLevelAttempt(
      attemptNumber: attemptNumber,
      activitySessionId: _activitySessionId,
      levelId: level.id,
    );
  }

  void onTimerTick() {
    final currentState = state;

    if (currentState is! MirrorMindLoaded) return;

    emit(
      currentState.copyWith(
        elapsed: currentState.elapsed + const Duration(seconds: 1),
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

  Future<void> endActivityIfNotCompleted() async {
    if (_activityCompleted) return;

    try {
      await _mirrorMindService.postActivityEvent(
        childId: _childId,
        sessionId: _sessionId,
        activityId: _activityId,
        action: 'ENDED',
      );
    } catch (_) {
      // We do not block closing the screen if ending event fails.
    }
  }

  @override
  Future<void> close() async {
    _timer?.cancel();
    await endActivityIfNotCompleted();
    return super.close();
  }
}