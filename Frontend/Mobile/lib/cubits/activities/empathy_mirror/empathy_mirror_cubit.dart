import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../models/empathy_mirror/empathy_mirror_models.dart';
import '../../../services/activities/empathy_mirror_service.dart';
import 'empathy_mirror_state.dart';

class EmpathyMirrorCubit extends Cubit<EmpathyMirrorState> {
  final EmpathyMirrorService _service;

  static const FlutterSecureStorage _progressStorage =
  FlutterSecureStorage();

  final int activityId;
  final int activitySessionId;
  final int childId;
  final int sessionId;
  final int? startLevelId;
  final int initialLevelNumber;

  List<EmpathyMirrorLevel> _levels = [];
  int _levelIndex = 0;
  int _challengeIndex = 0;
  int _attemptNumber = 1;
  int _currentAttemptId = 0;
  String _currentAttemptStartedAt = '';

  bool _activityCompleted = false;
  bool _isLoading = false;
  bool _isSubmittingAnswer = false;
  bool _isCompletingActivity = false;
  bool _exitLogged = false;

  /// TEST MODE: when true, any non-empty QR/barcode scan counts as correct.
  /// Set to false before release to enforce the backend answer values.
  static const bool kAcceptAnyQr = true;

  EmpathyMirrorCubit({
    required EmpathyMirrorService service,
    required this.activityId,
    required this.activitySessionId,
    required this.childId,
    required this.sessionId,
    this.startLevelId,
    this.initialLevelNumber = 1,
  })  : _service = service,
        super(const EmpathyMirrorInitial());

  EmpathyMirrorLevel get _level => _levels[_levelIndex];

  String get _progressStorageKey {
    return 'empathy_mirror_progress_child_${childId}_activity_$activityId';
  }

  // ===================== LOCAL PROGRESS BACKUP =====================

  Future<_EmpathyMirrorSavedProgress?> _readSavedProgress() async {
    final raw = await _progressStorage.read(key: _progressStorageKey);

    if (raw == null || raw.trim().isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;

      final levelIndex = _readInt(decoded['levelIndex']);
      final challengeIndex = _readInt(decoded['challengeIndex']);

      if (levelIndex == null || levelIndex < 0) return null;

      return _EmpathyMirrorSavedProgress(
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
    await _progressStorage.write(
      key: _progressStorageKey,
      value: jsonEncode({
        'levelIndex': levelIndex,
        'challengeIndex': challengeIndex,
        'updatedAt': DateTime.now().toIso8601String(),
      }),
    );
  }

  Future<void> _clearSavedProgress() async {
    await _progressStorage.delete(key: _progressStorageKey);
  }

  // ===================== LOAD =====================

  Future<void> loadGame() async {
    if (_isLoading) return;

    _isLoading = true;
    _activityCompleted = false;
    _isSubmittingAnswer = false;
    _isCompletingActivity = false;
    _exitLogged = false;

    emit(const EmpathyMirrorLoading());

    try {
      _levels = await _service.getLevels(activityId);
      _levels = _levels.where((level) => level.challenges.isNotEmpty).toList();

      if (_levels.isEmpty) {
        throw Exception('لا توجد مستويات أو تحديات لهذا النشاط');
      }

      final startPosition = await _resolveStartPosition();
      _levelIndex = startPosition.levelIndex;
      _challengeIndex = startPosition.challengeIndex;
      _attemptNumber = 1;

      await _saveCurrentProgress();

      final attempt = await _service.createLevelAttempt(
        attemptNumber: _attemptNumber,
        activitySessionId: activitySessionId,
        levelId: _level.id,
      );

      _currentAttemptId = attempt.id;
      _currentAttemptStartedAt = attempt.startedAt;

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

      debugPrint(
        'EMPATHY START: levelIndex=$_levelIndex, '
            'challengeIndex=$_challengeIndex, levelId=${_level.id}',
      );

      _isLoading = false;
      _emitLoaded();
    } catch (error) {
      _isLoading = false;
      emit(
        EmpathyMirrorError(
          error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }

  Future<_EmpathyMirrorStartPosition> _resolveStartPosition() async {
    int backendLevelIndex;

    if (startLevelId != null && startLevelId! > 0) {
      final indexFromId = _levels.indexWhere(
            (level) => level.id == startLevelId,
      );

      backendLevelIndex = indexFromId == -1
          ? _levelIndexFromNumber(initialLevelNumber)
          : indexFromId;
    } else {
      backendLevelIndex = _levelIndexFromNumber(initialLevelNumber);
    }

    final savedProgress = await _readSavedProgress();

    if (savedProgress != null &&
        savedProgress.levelIndex >= backendLevelIndex &&
        savedProgress.levelIndex < _levels.length) {
      final savedLevel = _levels[savedProgress.levelIndex];
      final maxChallengeIndex = savedLevel.challenges.length - 1;

      return _EmpathyMirrorStartPosition(
        levelIndex: savedProgress.levelIndex,
        challengeIndex: _clampInt(
          savedProgress.challengeIndex,
          0,
          maxChallengeIndex,
        ),
      );
    }

    return _EmpathyMirrorStartPosition(
      levelIndex: backendLevelIndex,
      challengeIndex: 0,
    );
  }

  int _levelIndexFromNumber(int levelNumber) {
    if (levelNumber <= 0 || levelNumber > _levels.length) return 0;
    return _clampInt(levelNumber - 1, 0, _levels.length - 1);
  }

  int _clampInt(int value, int min, int max) {
    if (max < min) return min;
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  // ===================== VIDEO =====================

  void onVideoFinished() {
    final current = state;
    if (current is EmpathyMirrorLoaded) {
      emit(current.copyWith(videoFinished: true));
    }
  }

  void replayVideo() {
    final current = state;
    if (current is EmpathyMirrorLoaded) {
      emit(current.copyWith(videoFinished: false));
    }
  }

  // ===================== NORMAL ANSWERS =====================

  Future<void> onQrScanned(String result) async {
    final current = state;
    if (current is! EmpathyMirrorLoaded || _isSubmittingAnswer) return;

    final challenge = current.currentChallenge;
    final correctAnswer = _level.correctAnswers[challenge.challengeId];

    final isCorrect = kAcceptAnyQr
        ? result.trim().isNotEmpty
        : correctAnswer == null
        ? result.trim().isNotEmpty
        : result.trim().toLowerCase() ==
        correctAnswer.trim().toLowerCase();

    debugPrint(
      'EMPATHY QR: value=$result, expected=$correctAnswer, '
          'correct=$isCorrect',
    );

    await _handleAnswer(
      current,
      isCorrect: isCorrect,
      isFollowup: challenge.isFollowup,
    );
  }

  Future<void> onCardSelected(String icon) async {
    final current = state;
    if (current is! EmpathyMirrorLoaded || _isSubmittingAnswer) return;

    final challenge = current.currentChallenge;
    final correctAnswer = _level.correctAnswers[challenge.challengeId];
    final isCorrect = icon.trim().toLowerCase() ==
        (correctAnswer ?? '').trim().toLowerCase();

    debugPrint(
      'EMPATHY CARD: value=$icon, expected=$correctAnswer, '
          'correct=$isCorrect',
    );

    await _handleAnswer(
      current,
      isCorrect: isCorrect,
      isFollowup: challenge.isFollowup,
    );
  }

  Future<void> _handleAnswer(
      EmpathyMirrorLoaded current, {
        required bool isCorrect,
        bool isFollowup = false,
      }) async {
    if (_isSubmittingAnswer) return;
    _isSubmittingAnswer = true;

    try {
      if (!isCorrect) {
        final retrySnapshot = await _handleWrongAttempt(current);

        emit(
          EmpathyMirrorChallengeResult(
            isCorrect: false,
            isFollowup: isFollowup,
            snapshot: retrySnapshot,
          ),
        );
        return;
      }

      final isLastChallenge =
          current.currentChallengeIndex >= _level.challenges.length - 1;

      if (!isLastChallenge) {
        _challengeIndex = current.currentChallengeIndex + 1;
        await _saveCurrentProgress();

        emit(
          EmpathyMirrorChallengeResult(
            isCorrect: true,
            isFollowup: isFollowup,
            snapshot: current.copyWith(
              currentChallengeIndex: _challengeIndex,
              videoFinished: false,
            ),
          ),
        );
        return;
      }

      await _completeCurrentLevelAttempt();

      final nextSnapshot = await _moveAfterCompletedLevel(
        completedSnapshot: current,
      );

      emit(
        EmpathyMirrorChallengeResult(
          isCorrect: true,
          isFollowup: isFollowup,
          snapshot: nextSnapshot,
        ),
      );
    } catch (error) {
      emit(
        EmpathyMirrorError(
          error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    } finally {
      _isSubmittingAnswer = false;
    }
  }

  // ===================== SPLIT SCREEN =====================

  Future<void> onCharacterScanned(
      int characterIndex,
      String result,
      ) async {
    final current = state;
    if (current is! EmpathyMirrorLoaded || _isSubmittingAnswer) return;

    final challenge = _level.challengeForCharacter(characterIndex);
    if (challenge == null) return;

    final correctAnswer = _level.correctAnswers[challenge.challengeId];
    final isCorrect = kAcceptAnyQr
        ? result.trim().isNotEmpty
        : correctAnswer == null
        ? result.trim().isNotEmpty
        : result.trim().toLowerCase() ==
        correctAnswer.trim().toLowerCase();

    debugPrint(
      'EMPATHY CHARACTER $characterIndex: value=$result, '
          'expected=$correctAnswer, correct=$isCorrect',
    );

    _isSubmittingAnswer = true;

    try {
      if (!isCorrect) {
        final retrySnapshot = await _handleWrongAttempt(current);

        emit(
          retrySnapshot.copyWith(
            character1Answered:
            characterIndex == 1 ? true : current.character1Answered,
            character1Correct:
            characterIndex == 1 ? false : current.character1Correct,
            character2Answered:
            characterIndex == 2 ? true : current.character2Answered,
            character2Correct:
            characterIndex == 2 ? false : current.character2Correct,
          ),
        );
        return;
      }

      final answeredSnapshot = current.copyWith(
        character1Answered:
        characterIndex == 1 ? true : current.character1Answered,
        character1Correct:
        characterIndex == 1 ? true : current.character1Correct,
        character2Answered:
        characterIndex == 2 ? true : current.character2Answered,
        character2Correct:
        characterIndex == 2 ? true : current.character2Correct,
      );

      final bothCorrect = answeredSnapshot.character1Correct &&
          answeredSnapshot.character2Correct;

      if (!bothCorrect) {
        emit(answeredSnapshot);
        return;
      }

      await _completeCurrentLevelAttempt();

      final nextSnapshot = await _moveAfterCompletedLevel(
        completedSnapshot: answeredSnapshot,
      );

      emit(
        EmpathyMirrorChallengeResult(
          isCorrect: true,
          isSplitScreen: true,
          snapshot: nextSnapshot,
        ),
      );
    } catch (error) {
      emit(
        EmpathyMirrorError(
          error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    } finally {
      _isSubmittingAnswer = false;
    }
  }

  // ===================== ATTEMPT FLOW =====================

  Future<EmpathyMirrorLoaded> _handleWrongAttempt(
      EmpathyMirrorLoaded current,
      ) async {
    await _service.updateLevelAttempt(
      attemptId: _currentAttemptId,
      attemptNumber: _attemptNumber,
      startedAt: _currentAttemptStartedAt,
      activitySessionId: activitySessionId,
      levelId: _level.id,
      completed: false,
    );

    await _service.logLevelEvent(
      childId: childId,
      sessionId: sessionId,
      activitySessionId: activitySessionId,
      action: 'FAILED',
    );

    _attemptNumber += 1;

    final retryAttempt = await _service.createLevelAttempt(
      attemptNumber: _attemptNumber,
      activitySessionId: activitySessionId,
      levelId: _level.id,
    );

    _currentAttemptId = retryAttempt.id;
    _currentAttemptStartedAt = retryAttempt.startedAt;

    await _service.logLevelEvent(
      childId: childId,
      sessionId: sessionId,
      activitySessionId: activitySessionId,
      action: 'RETRIED',
    );

    await _saveCurrentProgress();

    return current.copyWith(
      currentAttemptId: _currentAttemptId,
      attemptNumber: _attemptNumber,
    );
  }

  Future<void> _completeCurrentLevelAttempt() async {
    await _service.updateLevelAttempt(
      attemptId: _currentAttemptId,
      attemptNumber: _attemptNumber,
      startedAt: _currentAttemptStartedAt,
      activitySessionId: activitySessionId,
      levelId: _level.id,
      completed: true,
    );

    await _service.logLevelEvent(
      childId: childId,
      sessionId: sessionId,
      activitySessionId: activitySessionId,
      action: 'COMPLETED',
    );
  }

  Future<EmpathyMirrorLoaded> _moveAfterCompletedLevel({
    required EmpathyMirrorLoaded completedSnapshot,
  }) async {
    final isLastLevel = _levelIndex >= _levels.length - 1;

    if (isLastLevel) {
      await _completeActivity();
      return completedSnapshot;
    }

    _levelIndex += 1;
    _challengeIndex = 0;
    _attemptNumber = 1;

    await _saveCurrentProgress();

    final nextAttempt = await _service.createLevelAttempt(
      attemptNumber: _attemptNumber,
      activitySessionId: activitySessionId,
      levelId: _level.id,
    );

    _currentAttemptId = nextAttempt.id;
    _currentAttemptStartedAt = nextAttempt.startedAt;

    await _service.logLevelEvent(
      childId: childId,
      sessionId: sessionId,
      activitySessionId: activitySessionId,
      action: 'STARTED',
    );

    return EmpathyMirrorLoaded(
      level: _level,
      currentChallengeIndex: _challengeIndex,
      currentAttemptId: _currentAttemptId,
      attemptNumber: _attemptNumber,
    );
  }

  // ===================== RESULT CONTINUATION =====================

  void nextChallenge() {
    final current = state;
    if (current is! EmpathyMirrorChallengeResult) return;

    if (_activityCompleted) {
      emit(const EmpathyMirrorLevelComplete());
      return;
    }

    emit(current.snapshot);
  }

  // ===================== ACTIVITY COMPLETION =====================

  Future<void> _completeActivity() async {
    if (_activityCompleted) return;
    if (_isCompletingActivity) {
      throw Exception('يتم حفظ إكمال النشاط الآن، حاول مرة أخرى');
    }

    _isCompletingActivity = true;

    try {
      await _service.logActivityEvent(
        childId: childId,
        sessionId: sessionId,
        activityId: activityId,
        action: 'COMPLETED',
      );

      await _service.completeActivitySession(activitySessionId);

      _activityCompleted = true;

      try {
        await _clearSavedProgress();
      } catch (error) {
        debugPrint('EMPATHY CLEAR LOCAL PROGRESS ERROR: $error');
      }
    } finally {
      _isCompletingActivity = false;
    }
  }

  // ===================== EXIT =====================

  Future<void> logExitIfNotCompleted() async {
    if (_activityCompleted || _exitLogged) return;

    _exitLogged = true;

    try {
      await _saveCurrentProgress();

      await _service.logActivityEvent(
        childId: childId,
        sessionId: sessionId,
        activityId: activityId,
        action: 'ENDED',
      );
    } catch (error) {
      _exitLogged = false;
      debugPrint('EMPATHY EXIT ERROR: $error');
    }
  }

  // ===================== STATE HELPERS =====================

  Future<void> _saveCurrentProgress() async {
    await _saveProgress(
      levelIndex: _levelIndex,
      challengeIndex: _challengeIndex,
    );
  }

  void _emitLoaded() {
    emit(
      EmpathyMirrorLoaded(
        level: _level,
        currentChallengeIndex: _challengeIndex,
        currentAttemptId: _currentAttemptId,
        attemptNumber: _attemptNumber,
      ),
    );
  }
}

class _EmpathyMirrorSavedProgress {
  final int levelIndex;
  final int challengeIndex;

  const _EmpathyMirrorSavedProgress({
    required this.levelIndex,
    required this.challengeIndex,
  });
}

class _EmpathyMirrorStartPosition {
  final int levelIndex;
  final int challengeIndex;

  const _EmpathyMirrorStartPosition({
    required this.levelIndex,
    required this.challengeIndex,
  });
}
