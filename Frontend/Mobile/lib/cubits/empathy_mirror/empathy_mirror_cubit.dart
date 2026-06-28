import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/empathy_mirror/empathy_mirror_models.dart';
import '../../services/activities/empathy_mirror_service.dart';
import 'empathy_mirror_state.dart';

class EmpathyMirrorCubit extends Cubit<EmpathyMirrorState> {
  final EmpathyMirrorService _service;

  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;

  List<EmpathyMirrorLevel> _levels = [];
  int _levelIndex = 0;
  bool _activityCompleted = false;
  bool _isLoading = false;

  /// TEST MODE: when true, ANY non-empty QR/barcode scan counts as correct,
  /// so you can walk through all levels with any code in real life.
  /// Set to false before release to enforce real answer validation.
  static const bool kAcceptAnyQr = true;

  EmpathyMirrorCubit({
    required EmpathyMirrorService service,
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
  })  : _service = service,
        super(const EmpathyMirrorInitial());

  EmpathyMirrorLevel get _level => _levels[_levelIndex];

  // ─── Load ──────────────────────────────────────────────────────────────────

  Future<void> loadGame() async {
    if (_isLoading) return;
    _isLoading = true;
    emit(const EmpathyMirrorLoading());

    try {
      _levels = await _service.getLevels(activityId);

      if (_levels.isEmpty) {
        emit(const EmpathyMirrorError('لا توجد مستويات لهذا النشاط'));
        _isLoading = false;
        return;
      }

      _levelIndex = 0;

      final attemptId = await _service.createLevelAttempt(
        attemptNumber: 1,
        activitySessionId: activitySessionId,
        levelId: _level.id,
      );

      await _service.logActivityEvent(
        childId: childId,
        sessionId: sessionId,
        activityId: activityId,
        action: 'STARTED',
      );
      await _service.logLevelEvent(
        childId: childId,
        sessionId: sessionId,
        activitySessionId: activitySessionId,
        action: 'STARTED',
      );

      _isLoading = false;
      emit(EmpathyMirrorLoaded(
        level: _level,
        currentChallengeIndex: 0,
        currentAttemptId: attemptId,
        attemptNumber: 1,
      ));
    } catch (e) {
      _isLoading = false;
      emit(EmpathyMirrorError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  // ─── Video finished ────────────────────────────────────────────────────────

  void onVideoFinished() {
    final s = state;
    if (s is EmpathyMirrorLoaded) {
      emit(s.copyWith(videoFinished: true));
    }
  }

  /// Replays the video for the current challenge (locks Continue again until
  /// it finishes once more).
  void replayVideo() {
    final s = state;
    if (s is EmpathyMirrorLoaded) {
      emit(s.copyWith(videoFinished: false));
    }
  }

  // ─── QR scanned (Levels 1, 3, 4, 5) ──────────────────────────────────────

  Future<void> onQrScanned(String result) async {
    final s = state;
    if (s is! EmpathyMirrorLoaded) return;

    final challenge = s.currentChallenge;
    final correctAnswer =
    _level.correctAnswers[challenge.challengeId];

    // TODO: coordinate with team on exact QR value format.
    final isCorrect = kAcceptAnyQr
        ? result.trim().isNotEmpty
        : (correctAnswer == null
        ? result.trim().isNotEmpty
        : result.trim().toLowerCase() ==
        correctAnswer.trim().toLowerCase());

    debugPrint(
        'QR SCANNED: $result | expected: $correctAnswer | correct: $isCorrect');

    await _handleAnswer(s, isCorrect: isCorrect);
  }

  // ─── Card selected (Level 2) ───────────────────────────────────────────────

  Future<void> onCardSelected(String icon) async {
    final s = state;
    if (s is! EmpathyMirrorLoaded) return;

    final challenge = s.currentChallenge;
    final correctAnswer = _level.correctAnswers[challenge.challengeId];
    final isCorrect = icon.trim().toLowerCase() ==
        (correctAnswer ?? '').trim().toLowerCase();

    debugPrint(
        'CARD SELECTED: $icon | expected: $correctAnswer | correct: $isCorrect');

    await _handleAnswer(s, isCorrect: isCorrect, isFollowup: challenge.isFollowup);
  }

  // ─── Split-screen character scanned (Level 3) ─────────────────────────────

  Future<void> onCharacterScanned(int characterIndex, String result) async {
    final s = state;
    if (s is! EmpathyMirrorLoaded) return;

    // Find the challenge tagged for this character (1 or 2) — NOT by array
    // index, since challenge[0] may be the shared intro video, not a
    // character-specific question.
    final challenge = _level.challengeForCharacter(characterIndex);
    if (challenge == null) return;

    final correctAnswer = _level.correctAnswers[challenge.challengeId];
    final isCorrect = kAcceptAnyQr
        ? result.trim().isNotEmpty
        : (correctAnswer == null
        ? result.trim().isNotEmpty
        : result.trim().toLowerCase() ==
        correctAnswer.trim().toLowerCase());

    debugPrint(
        'CHAR $characterIndex SCANNED: $result | correct: $isCorrect');

    // Update attempt for this character's challenge.
    try {
      await _service.updateLevelAttempt(
        attemptId: s.currentAttemptId,
        completed: isCorrect,
      );
      await _service.logLevelEvent(
        childId: childId,
        sessionId: sessionId,
        activitySessionId: activitySessionId,
        action: isCorrect ? 'COMPLETED' : 'FAILED',
      );

      if (!isCorrect) {
        final newAttempt = await _service.createLevelAttempt(
          attemptNumber: s.attemptNumber + 1,
          activitySessionId: activitySessionId,
          levelId: _level.id,
        );
        await _service.logLevelEvent(
          childId: childId,
          sessionId: sessionId,
          activitySessionId: activitySessionId,
          action: 'RETRIED',
        );
        emit(s.copyWith(
          currentAttemptId: newAttempt,
          attemptNumber: s.attemptNumber + 1,
          character1Answered: characterIndex == 1 ? true : s.character1Answered,
          character1Correct: characterIndex == 1 ? false : s.character1Correct,
          character2Answered: characterIndex == 2 ? true : s.character2Answered,
          character2Correct: characterIndex == 2 ? false : s.character2Correct,
        ));
        return;
      }
    } catch (e) {
      debugPrint('CHAR SCAN ERROR: $e');
    }

    final newState = s.copyWith(
      character1Answered: characterIndex == 1 ? true : s.character1Answered,
      character1Correct: characterIndex == 1 ? true : s.character1Correct,
      character2Answered: characterIndex == 2 ? true : s.character2Answered,
      character2Correct: characterIndex == 2 ? true : s.character2Correct,
    );

    // Both characters answered correctly → level done
    if (newState.character1Correct && newState.character2Correct) {
      final hasNextLevel = _levelIndex < _levels.length - 1;

      if (hasNextLevel) {
        _levelIndex++;
        try {
          final newAttempt = await _service.createLevelAttempt(
            attemptNumber: 1,
            activitySessionId: activitySessionId,
            levelId: _level.id,
          );
          await _service.logLevelEvent(
            childId: childId,
            sessionId: sessionId,
            activitySessionId: activitySessionId,
            action: 'STARTED',
          );
          emit(EmpathyMirrorLoaded(
            level: _level,
            currentChallengeIndex: 0,
            currentAttemptId: newAttempt,
            attemptNumber: 1,
          ));
        } catch (e) {
          debugPrint('NEXT LEVEL ERROR: $e');
        }
        return;
      }

      await _completeActivity();
      emit(const EmpathyMirrorLevelComplete());
      return;
    }

    emit(newState);
  }

  // ─── Core answer handler ───────────────────────────────────────────────────

  Future<void> _handleAnswer(
      EmpathyMirrorLoaded s, {
        required bool isCorrect,
        bool isFollowup = false,
      }) async {
    try {
      await _service.updateLevelAttempt(
        attemptId: s.currentAttemptId,
        completed: isCorrect,
      );
      await _service.logLevelEvent(
        childId: childId,
        sessionId: sessionId,
        activitySessionId: activitySessionId,
        action: isCorrect ? 'COMPLETED' : 'FAILED',
      );

      if (!isCorrect) {
        final newAttempt = await _service.createLevelAttempt(
          attemptNumber: s.attemptNumber + 1,
          activitySessionId: activitySessionId,
          levelId: _level.id,
        );
        await _service.logLevelEvent(
          childId: childId,
          sessionId: sessionId,
          activitySessionId: activitySessionId,
          action: 'RETRIED',
        );
        emit(EmpathyMirrorChallengeResult(
          isCorrect: false,
          isFollowup: isFollowup,
          snapshot: s.copyWith(
            currentAttemptId: newAttempt,
            attemptNumber: s.attemptNumber + 1,
          ),
        ));
        return;
      }
    } catch (e) {
      debugPrint('ANSWER HANDLER ERROR: $e');
    }

    // Correct → check if more challenges
    final isLastChallenge =
        s.currentChallengeIndex >= _level.challenges.length - 1;

    if (isLastChallenge) {
      // Level 2: if c1 correct and followup exists, advance to c2.
      if (s.isLevel2 && !isFollowup && _level.challenges.length > 1) {
        final newAttempt = await _service.createLevelAttempt(
          attemptNumber: 1,
          activitySessionId: activitySessionId,
          levelId: _level.id,
        );
        emit(EmpathyMirrorChallengeResult(
          isCorrect: true,
          isFollowup: false,
          snapshot: s.copyWith(
            currentChallengeIndex: s.currentChallengeIndex + 1,
            currentAttemptId: newAttempt,
            attemptNumber: 1,
          ),
        ));
        return;
      }

      // All challenges in THIS level done → is there a next level?
      final hasNextLevel = _levelIndex < _levels.length - 1;

      if (hasNextLevel) {
        // Move to the next level.
        _levelIndex++;
        final newAttempt = await _service.createLevelAttempt(
          attemptNumber: 1,
          activitySessionId: activitySessionId,
          levelId: _level.id,
        );
        await _service.logLevelEvent(
          childId: childId,
          sessionId: sessionId,
          activitySessionId: activitySessionId,
          action: 'STARTED',
        );
        emit(EmpathyMirrorChallengeResult(
          isCorrect: true,
          isFollowup: isFollowup,
          snapshot: EmpathyMirrorLoaded(
            level: _level,
            currentChallengeIndex: 0,
            currentAttemptId: newAttempt,
            attemptNumber: 1,
          ),
        ));
        return;
      }

      // No more levels → complete the whole activity.
      await _completeActivity();
      emit(EmpathyMirrorChallengeResult(
        isCorrect: true,
        isFollowup: isFollowup,
        snapshot: s,
      ));
      return;
    }

    // Advance to next challenge in same level.
    final newAttempt = await _service.createLevelAttempt(
      attemptNumber: 1,
      activitySessionId: activitySessionId,
      levelId: _level.id,
    );
    emit(EmpathyMirrorChallengeResult(
      isCorrect: true,
      isFollowup: isFollowup,
      snapshot: s.copyWith(
        currentChallengeIndex: s.currentChallengeIndex + 1,
        currentAttemptId: newAttempt,
        attemptNumber: 1,
        videoFinished: false,
      ),
    ));
  }

  // ─── Next challenge (called from screen after result shown) ───────────────

  void nextChallenge() {
    final s = state;
    if (s is! EmpathyMirrorChallengeResult) return;

    if (!s.isCorrect) {
      // Retry — go back to loaded with new attempt id.
      emit(s.snapshot);
      return;
    }

    // Check if activity is fully complete.
    if (_activityCompleted) {
      emit(const EmpathyMirrorLevelComplete());
      return;
    }

    emit(s.snapshot);
  }

  // ─── Complete activity ─────────────────────────────────────────────────────

  Future<void> _completeActivity() async {
    if (_activityCompleted) return;
    _activityCompleted = true;

    try {
      await _service.logActivityEvent(
        childId: childId,
        sessionId: sessionId,
        activityId: activityId,
        action: 'COMPLETED',
      );
      await _service.completeActivitySession(activitySessionId);
    } catch (e) {
      debugPrint('COMPLETE ERROR: $e');
    }
  }

  // ─── Exit (Step D) ─────────────────────────────────────────────────────────

  Future<void> logExitIfNotCompleted() async {
    if (_activityCompleted) return;
    try {
      await _service.logActivityEvent(
        childId: childId,
        sessionId: sessionId,
        activityId: activityId,
        action: 'ENDED',
      );
    } catch (e) {
      debugPrint('EXIT ERROR: $e');
    }
  }
}
