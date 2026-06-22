import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../services/activities/create_creature_service.dart';
import 'create_creature_state.dart';

class CreateCreatureCubit extends Cubit<CreateCreatureState> {
  CreateCreatureCubit({
    CreateCreatureService? createCreatureService,
  })  : _createCreatureService =
      createCreatureService ?? CreateCreatureService(),
        super(const CreateCreatureInitial());

  final CreateCreatureService _createCreatureService;

  Timer? _timer;

  late int _activityId;
  late int _activitySessionId;
  late int _childId;
  late int _sessionId;

  bool _activityCompleted = false;
  bool _gameLoaded = false;

  CreateCreatureLoaded? _getLoaded() {
    final currentState = state;
    if (currentState is CreateCreatureLoaded) return currentState;
    if (currentState is CreateCreatureStepCompleted) return currentState.previousState;
    return null;
  }

  Future<void> loadGame({
    required int activityId,
    required int activitySessionId,
    required int childId,
    required int sessionId,
  }) async {
    emit(const CreateCreatureLoading());

    _activityId = activityId;
    _activitySessionId = activitySessionId;
    _childId = childId;
    _sessionId = sessionId;
    _activityCompleted = false;
    _gameLoaded = false;

    try {
      final levels =
      await _createCreatureService.getLevelsByActivity(activityId);

      if (levels.isEmpty) {
        emit(const CreateCreatureError('No levels were found.'));
        return;
      }

      final level = levels.first;

      final startedAt = DateTime.now().toIso8601String();

      final attemptId = await _createCreatureService.createLevelAttempt(
        attemptNumber: 1,
        startedAt: startedAt,
        activitySessionId: activitySessionId,
        levelId: level.id,
      );

      await _createCreatureService.postActivityEvent(
        childId: _childId,
        sessionId: _sessionId,
        activityId: _activityId,
        action: 'STARTED',
      );

      await _createCreatureService.postLevelEvent(
        childId: _childId,
        sessionId: _sessionId,
        activitySessionId: _activitySessionId,
        action: 'STARTED',
      );

      _gameLoaded = true;

      emit(
        CreateCreatureLoaded(
          level: level,
          currentAttemptId: attemptId,
          attemptNumber: 1,
          currentAttemptStartedAt: startedAt,
          elapsed: Duration.zero,
        ),
      );

      _startTimer();
    } catch (error) {
      emit(CreateCreatureError(error.toString()));
    }
  }

  void onEyesSelected(String icon) {
    final loaded = _getLoaded();
    if (loaded == null) return;
    _emitLoaded(loaded.copyWith(eyesSelection: icon));
  }

  void onMouthSelected(String icon) {
    final loaded = _getLoaded();
    if (loaded == null) return;
    _emitLoaded(loaded.copyWith(mouthSelection: icon));
  }

  void onFeelingSelected(String icon) {
    final loaded = _getLoaded();
    if (loaded == null) return;
    _emitLoaded(loaded.copyWith(feelingSelection: icon));
  }

  Future<void> onFaceConfirmed() async {
    final loaded = _getLoaded();
    if (loaded == null) return;
    if (!loaded.faceComplete) return;

    try {
      for (int i = 0; i < 3; i++) {
        await _createCreatureService.postLevelEvent(
          childId: _childId,
          sessionId: _sessionId,
          activitySessionId: _activitySessionId,
          action: 'COMPLETED',
        );
      }

      emit(
        CreateCreatureStepCompleted(
          step: 'face',
          previousState: loaded,
        ),
      );
    } catch (error) {
      emit(CreateCreatureError(error.toString()));
    }
  }

  void onAbilitySelected(String icon) {
    final loaded = _getLoaded();
    if (loaded == null) return;
    _emitLoaded(loaded.copyWith(abilitySelection: icon));
  }

  Future<void> onAbilityConfirmed() async {
    final loaded = _getLoaded();
    if (loaded == null) return;
    if (loaded.abilitySelection == null) return;

    try {
      await _createCreatureService.postLevelEvent(
        childId: _childId,
        sessionId: _sessionId,
        activitySessionId: _activitySessionId,
        action: 'COMPLETED',
      );

      emit(
        CreateCreatureStepCompleted(
          step: 'ability',
          previousState: loaded,
        ),
      );
    } catch (error) {
      emit(CreateCreatureError(error.toString()));
    }
  }

  void onHomeSelected(String icon) {
    final loaded = _getLoaded();
    if (loaded == null) return;
    _emitLoaded(loaded.copyWith(homeSelection: icon));
  }

  Future<void> onHomeConfirmed() async {
    final loaded = _getLoaded();
    if (loaded == null) return;
    if (loaded.homeSelection == null) return;

    try {
      await _createCreatureService.postLevelEvent(
        childId: _childId,
        sessionId: _sessionId,
        activitySessionId: _activitySessionId,
        action: 'COMPLETED',
      );

      emit(
        CreateCreatureStepCompleted(
          step: 'home',
          previousState: loaded,
        ),
      );
    } catch (error) {
      emit(CreateCreatureError(error.toString()));
    }
  }

  void onRecordingComplete(String filePath) {
    final loaded = _getLoaded();
    if (loaded == null) return;
    _emitLoaded(loaded.copyWith(recordedFilePath: filePath));
  }

  void onRecordingCleared() {
    final loaded = _getLoaded();
    if (loaded == null) return;
    _emitLoaded(loaded.copyWith(clearRecordedFilePath: true));
  }

  void resumeLoadedState() {
    final currentState = state;
    if (currentState is CreateCreatureStepCompleted) {
      emit(currentState.previousState);
    }
  }

  void _emitLoaded(CreateCreatureLoaded loaded) {
    emit(loaded);
  }

  Future<void> onStoryDone() async {
    final loaded = _getLoaded();
    if (loaded == null) return;
    if (!loaded.hasRecording) return;

    try {
      await _createCreatureService.postLevelEvent(
        childId: _childId,
        sessionId: _sessionId,
        activitySessionId: _activitySessionId,
        action: 'COMPLETED',
      );

      await _createCreatureService.updateLevelAttempt(
        attemptId: loaded.currentAttemptId,
        attemptNumber: loaded.attemptNumber,
        startedAt: loaded.currentAttemptStartedAt,
        activitySessionId: _activitySessionId,
        levelId: loaded.level.id,
        completed: true,
      );

      await _createCreatureService.postActivityEvent(
        childId: _childId,
        sessionId: _sessionId,
        activityId: _activityId,
        action: 'COMPLETED',
      );

      await _createCreatureService.completeActivitySession(_activitySessionId);

      _activityCompleted = true;
      _timer?.cancel();

      emit(const CreateCreatureActivityComplete());
    } catch (error) {
      emit(CreateCreatureError(error.toString()));
    }
  }

  void onTimerTick() {
    final loaded = _getLoaded();
    if (loaded == null) return;
    // Preserve StepCompleted state if that's what we're in
    final currentState = state;
    if (currentState is CreateCreatureStepCompleted) {
      emit(CreateCreatureStepCompleted(
        step: currentState.step,
        previousState: loaded.copyWith(
          elapsed: loaded.elapsed + const Duration(seconds: 1),
        ),
      ));
    } else {
      emit(loaded.copyWith(
        elapsed: loaded.elapsed + const Duration(seconds: 1),
      ));
    }
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
    if (!_gameLoaded) return;

    try {
      await _createCreatureService.postActivityEvent(
        childId: _childId,
        sessionId: _sessionId,
        activityId: _activityId,
        action: 'ENDED',
      );
    } catch (_) {}
  }

  @override
  Future<void> close() async {
    _timer?.cancel();
    await endActivityIfNotCompleted();
    return super.close();
  }
}