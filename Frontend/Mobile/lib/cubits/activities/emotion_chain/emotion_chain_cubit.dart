import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/activities/emotion_chain/emotion_chain_challenge_model.dart';
import '../../../models/activities/emotion_chain/emotion_chain_level_model.dart';
import '../../../services/activities/emotion_chain_service.dart';
import 'emotion_chain_state.dart';

class EmotionChainCubit extends Cubit<EmotionChainState> {
  EmotionChainCubit({EmotionChainService? service})
      : _service = service ?? EmotionChainService(),
        super(const EmotionChainInitial());

  final EmotionChainService _service;

  late int _activityId;
  late int _activitySessionId;
  late int _childId;
  late int _sessionId;

  List<EmotionChainLevelModel> _levels = const [];
  int _currentLevelIndex = 0;
  int _currentChallengeIndex = 0;

  int _currentAttemptId = 0;
  int _attemptNumber = 1;
  String _currentAttemptStartedAt = '';

  Timer? _timer;
  bool _activityCompleted = false;
  bool _gameLoaded = false;

  EmotionChainLevelModel get _level => _levels[_currentLevelIndex];
  EmotionChainChallengeModel get _challenge =>
      _level.challenges[_currentChallengeIndex];

  bool get _isLastChallengeInLevel =>
      _currentChallengeIndex >= _level.challenges.length - 1;
  bool get _isLastLevel => _currentLevelIndex >= _levels.length - 1;

  bool get isActivityCompleted => _activityCompleted;

  // ---------------------------------------------------------------------------
  // Load
  // ---------------------------------------------------------------------------

  Future<void> loadGame({
    required int activityId,
    required int activitySessionId,
    required int childId,
    required int sessionId,
  }) async {
    emit(const EmotionChainLoading());

    _activityId = activityId;
    _activitySessionId = activitySessionId;
    _childId = childId;
    _sessionId = sessionId;
    _activityCompleted = false;
    _gameLoaded = false;
    _currentLevelIndex = 0;
    _currentChallengeIndex = 0;

    try {
      final levels = await _service.getLevelsByActivity(activityId);
      _levels = levels.where((l) => l.challenges.isNotEmpty).toList();

      if (_levels.isEmpty) {
        emit(const EmotionChainError('No Emotion Chain levels were found.'));
        return;
      }

      await _createAttempt(attemptNumber: 1);

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

      // Every level starts with its first challenge's video.
      emit(EmotionChainVideoPlaying(level: _level));
    } catch (error) {
      emit(EmotionChainError(error.toString()));
    }
  }

  // ---------------------------------------------------------------------------
  // Video finished -> show first step
  // ---------------------------------------------------------------------------

  void onVideoFinished() {
    _emitStepReady(reset: true);
  }

  void _emitStepReady({required bool reset}) {
    final hasTimer = _challenge.hasTimer;
    final seconds = hasTimer ? _challenge.timer : null;

    emit(EmotionChainStepReady(
      level: _level,
      currentChallengeIndex: _currentChallengeIndex,
      currentAttemptId: _currentAttemptId,
      attemptNumber: _attemptNumber,
      timerSeconds: seconds,
      timerRemaining: seconds,
    ));

    if (hasTimer) {
      _startTimer();
    } else {
      _stopTimer();
    }
  }

  // ---------------------------------------------------------------------------
  // QR scan
  // ---------------------------------------------------------------------------

  Future<void> onQrScanned(String result) async {
    final current = state;
    if (current is! EmotionChainStepReady) return;
    if (current.isTimeUp) return; // already failed by timeout

    _stopTimer();

    final correct = _isCorrectScan(result, _challenge);

    try {
      if (correct) {
        await _handleCorrect();
      } else {
        await _handleWrong();
      }
    } catch (error) {
      emit(EmotionChainError(error.toString()));
    }
  }

  /// QR validation.
  /// When the backend provides an expected value (meta.expectedAnswer / answer /
  /// correctCard) we compare against it. The backend does NOT send that yet, so
  /// for now ANY non-empty scanned QR is accepted as correct.
  /// TODO: once the backend returns the expected card value, comparison kicks in
  /// automatically — no code change needed here.
  bool _isCorrectScan(String scanned, EmotionChainChallengeModel challenge) {
    final value = scanned.trim();
    if (value.isEmpty) return false;

    final expected = challenge.expectedAnswer?.trim();
    if (expected != null && expected.isNotEmpty) {
      return value.toLowerCase() == expected.toLowerCase();
    }

    // No expected value from backend yet -> accept any scanned card.
    return true;
  }

  Future<void> _handleCorrect() async {
    await _service.updateLevelAttempt(
      attemptId: _currentAttemptId,
      attemptNumber: _attemptNumber,
      startedAt: _currentAttemptStartedAt,
      activitySessionId: _activitySessionId,
      levelId: _level.id,
      completed: true,
    );
    await _service.postLevelEvent(
      childId: _childId,
      sessionId: _sessionId,
      activitySessionId: _activitySessionId,
      action: 'COMPLETED',
    );

    final wasLastInLevel = _isLastChallengeInLevel;
    final wasLastLevel = _isLastLevel;

    if (wasLastInLevel && wasLastLevel) {
      // Save the full activity completion first, then keep the unified
      // correct-answer screen visible until the child presses "التالي".
      await _completeActivity(emitCompletionState: false);
    }

    emit(
      EmotionChainStepResult(
        isCorrect: true,
        level: _level,
        challengeIndex: _currentChallengeIndex,
      ),
    );
  }

  Future<void> _handleWrong() async {
    await _service.updateLevelAttempt(
      attemptId: _currentAttemptId,
      attemptNumber: _attemptNumber,
      startedAt: _currentAttemptStartedAt,
      activitySessionId: _activitySessionId,
      levelId: _level.id,
      completed: false,
    );
    await _service.postLevelEvent(
      childId: _childId,
      sessionId: _sessionId,
      activitySessionId: _activitySessionId,
      action: 'FAILED',
    );

    await _createAttempt(attemptNumber: _attemptNumber + 1);

    await _service.postLevelEvent(
      childId: _childId,
      sessionId: _sessionId,
      activitySessionId: _activitySessionId,
      action: 'RETRIED',
    );

    emit(EmotionChainStepResult(
      isCorrect: false,
      level: _level,
      challengeIndex: _currentChallengeIndex,
    ));
  }

  /// Called from the correct result screen's "التالي" button.
  Future<void> continueAfterCorrect() async {
    final current = state;

    if (current is! EmotionChainStepResult || !current.isCorrect) {
      return;
    }

    // The final activity completion is already saved. The result screen
    // handles the navigation back to the roadmap.
    if (_activityCompleted) {
      return;
    }

    try {
      if (_isLastChallengeInLevel) {
        await _moveToNextLevel();
        return;
      }

      _currentChallengeIndex += 1;
      await _createAttempt(attemptNumber: 1);
      _emitStepReady(reset: true);
    } catch (error) {
      emit(EmotionChainError(error.toString()));
    }
  }

  /// Called from the result screen's "Try Again" button.
  void retryStep() {
    final current = state;
    if (current is! EmotionChainStepResult) return;
    _emitStepReady(reset: true);
  }

  Future<void> _moveToNextLevel() async {
    _currentLevelIndex += 1;
    _currentChallengeIndex = 0;
    await _createAttempt(attemptNumber: 1);

    await _service.postLevelEvent(
      childId: _childId,
      sessionId: _sessionId,
      activitySessionId: _activitySessionId,
      action: 'STARTED',
    );

    emit(EmotionChainVideoPlaying(level: _level));
  }

  Future<void> _completeActivity({
    bool emitCompletionState = true,
  }) async {
    _activityCompleted = true;
    _stopTimer();

    await _service.postActivityEvent(
      childId: _childId,
      sessionId: _sessionId,
      activityId: _activityId,
      action: 'COMPLETED',
    );
    await _service.completeActivitySession(_activitySessionId);

    if (emitCompletionState) {
      emit(const EmotionChainActivityComplete());
    }
  }

  // ---------------------------------------------------------------------------
  // Timer (Level 1 only)
  // ---------------------------------------------------------------------------

  void onTimerTick() {
    final current = state;
    if (current is! EmotionChainStepReady) return;
    if (current.timerRemaining == null) return;

    final remaining = current.timerRemaining! - 1;

    if (remaining <= 0) {
      emit(current.copyWith(timerRemaining: 0));
      _stopTimer();
      // Time up -> wrong, scanner never opens.
      _handleWrong();
      return;
    }

    emit(current.copyWith(timerRemaining: remaining));
  }

  void _startTimer() {
    _stopTimer();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) => onTimerTick(),
    );
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  // ---------------------------------------------------------------------------
  // Attempt helper
  // ---------------------------------------------------------------------------

  Future<void> _createAttempt({required int attemptNumber}) async {
    final startedAt = DateTime.now().toIso8601String();
    final id = await _service.createLevelAttempt(
      attemptNumber: attemptNumber,
      startedAt: startedAt,
      activitySessionId: _activitySessionId,
      levelId: _level.id,
    );
    _currentAttemptId = id;
    _attemptNumber = attemptNumber;
    _currentAttemptStartedAt = startedAt;
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  Future<void> endActivityIfNotCompleted() async {
    if (_activityCompleted || !_gameLoaded) return;
    try {
      await _service.postActivityEvent(
        childId: _childId,
        sessionId: _sessionId,
        activityId: _activityId,
        action: 'ENDED',
      );
    } catch (_) {}
  }

  @override
  Future<void> close() async {
    _stopTimer();
    await endActivityIfNotCompleted();
    return super.close();
  }
}
