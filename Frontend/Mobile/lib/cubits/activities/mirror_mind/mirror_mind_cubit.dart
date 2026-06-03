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
  bool _gameLoaded = false;

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
    _gameLoaded = false;

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

      _gameLoaded = true;

      emit(
        MirrorMindLoaded(
          levels: playableLevels,
          currentLevelIndex: 0,
          currentChallengeIndex: 0,
          selectedChoiceIndex: null,
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

  void selectChoice(int choiceIndex) {
    final currentState = state;

    if (currentState is! MirrorMindLoaded) return;

    if (choiceIndex < 0 || choiceIndex >= currentState.challenge.choices.length) {
      return;
    }

    if (currentState.selectedChoiceIndex == choiceIndex) {
      emit(currentState.copyWith(clearSelectedChoice: true));
      return;
    }

    emit(currentState.copyWith(selectedChoiceIndex: choiceIndex));
  }

  void clearSelection() {
    final currentState = state;

    if (currentState is! MirrorMindLoaded) return;

    emit(currentState.copyWith(clearSelectedChoice: true));
  }

  Future<void> submitAnswer() async {
    final currentState = state;

    if (currentState is! MirrorMindLoaded) return;
    if (!currentState.canSubmit) return;
    if (!currentState.hasValidSelectedChoice) return;

    final selectedChoiceIndex = currentState.selectedChoiceIndex!;

    final isCorrect = currentState.challenge.isCorrectChoiceIndex(
      selectedChoiceIndex,
    );

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
      emit(
        loadedState.copyWith(
          currentChallengeIndex: loadedState.currentChallengeIndex + 1,
          clearSelectedChoice: true,
        ),
      );
      return;
    }

    if (loadedState.isLastPartOneLevel ||
        loadedState.currentLevelIndex >= loadedState.levels.length - 1) {
      await _completePartOne(loadedState.elapsed);
      return;
    }

    emit(
      MirrorMindLevelComplete(
        previousState: loadedState,
        message: _levelCompleteMessage(loadedState.currentLevelIndex),
      ),
    );

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
        clearSelectedChoice: true,
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
        clearSelectedChoice: true,
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

  String _levelCompleteMessage(int levelIndex) {
    if (levelIndex == 0) {
      return 'لقد اكتشفت أول سر للمرآة!';
    }

    if (levelIndex == 1) {
      return 'رائع! أصبحت تفهم انعكاس أكثر من شكل.';
    }

    return 'ممتاز! لقد أتقنت اتجاهات المرآة.';
  }

  Future<void> endActivityIfNotCompleted() async {
    if (_activityCompleted) return;
    if (!_gameLoaded) return;

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