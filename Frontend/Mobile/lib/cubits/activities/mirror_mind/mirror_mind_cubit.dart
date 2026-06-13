import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../models/activities/mirror_mind/mirror_mind_level_model.dart';
import '../../../services/activities/mirror_mind_service.dart';
import 'mirror_mind_state.dart';

class MirrorMindCubit extends Cubit<MirrorMindState> {
  MirrorMindCubit({
    MirrorMindService? mirrorMindService,
  })  : _mirrorMindService = mirrorMindService ?? MirrorMindService(),
        super(const MirrorMindInitial());

  final MirrorMindService _mirrorMindService;

  static const FlutterSecureStorage _progressStorage =
  FlutterSecureStorage();

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
    required int initialLevelNumber,
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
          .toList();

      if (playableLevels.isEmpty) {
        emit(const MirrorMindError('No Mirror Mind levels were found.'));
        return;
      }

      final startPosition = await _resolveStartPosition(
        levels: playableLevels,
        initialLevelNumber: initialLevelNumber,
      );

      final startLevel = playableLevels[startPosition.levelIndex];

      final firstAttempt = await _createAttemptForLevel(
        level: startLevel,
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
          currentLevelIndex: startPosition.levelIndex,
          currentChallengeIndex: startPosition.challengeIndex,
          selectedChoiceIndex: null,
          currentAttemptId: firstAttempt.id,
          attemptNumber: 1,
          currentAttemptStartedAt: firstAttempt.startedAt,
          elapsed: Duration.zero,
        ),
      );

      await _saveProgress(
        levelIndex: startPosition.levelIndex,
        challengeIndex: startPosition.challengeIndex,
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

  Future<void> submitDrawingAnswer({
    required bool isCorrect,
  }) async {
    final currentState = state;

    if (currentState is! MirrorMindLoaded) return;

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
      final nextChallengeIndex = loadedState.currentChallengeIndex + 1;

      await _saveProgress(
        levelIndex: loadedState.currentLevelIndex,
        challengeIndex: nextChallengeIndex,
      );

      emit(
        loadedState.copyWith(
          currentChallengeIndex: nextChallengeIndex,
          clearSelectedChoice: true,
        ),
      );
      return;
    }

    await _updateCurrentAttempt(
      currentState: loadedState,
      completed: true,
    );

    await _mirrorMindService.postLevelEvent(
      childId: _childId,
      sessionId: _sessionId,
      activitySessionId: _activitySessionId,
      action: 'COMPLETED',
    );

    if (loadedState.isLastLevel) {
      await _completeActivity(loadedState.elapsed);
      return;
    }

    emit(
      MirrorMindLevelComplete(
        previousState: loadedState,
        message: _levelCompleteMessage(loadedState.currentLevelNumber),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 900));

    await _moveToNextLevel(loadedState);
  }

  Future<void> _handleWrongAnswer(MirrorMindLoaded currentState) async {
    await _updateCurrentAttempt(
      currentState: currentState,
      completed: false,
    );

    await _mirrorMindService.postLevelEvent(
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

    await _saveProgress(
      levelIndex: currentState.currentLevelIndex,
      challengeIndex: currentState.currentChallengeIndex,
    );

    emit(
      currentState.copyWith(
        currentAttemptId: nextAttempt.id,
        attemptNumber: nextAttemptNumber,
        currentAttemptStartedAt: nextAttempt.startedAt,
        clearSelectedChoice: true,
      ),
    );
  }

  Future<void> _moveToNextLevel(MirrorMindLoaded previousState) async {
    final nextLevelIndex = previousState.currentLevelIndex + 1;
    final nextLevel = previousState.levels[nextLevelIndex];

    await _saveProgress(
      levelIndex: nextLevelIndex,
      challengeIndex: 0,
    );

    final nextAttempt = await _createAttemptForLevel(
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
        currentAttemptId: nextAttempt.id,
        attemptNumber: 1,
        currentAttemptStartedAt: nextAttempt.startedAt,
      ),
    );
  }

  Future<void> _completeActivity(Duration elapsed) async {
    _activityCompleted = true;
    _timer?.cancel();

    await _mirrorMindService.postActivityEvent(
      childId: _childId,
      sessionId: _sessionId,
      activityId: _activityId,
      action: 'COMPLETED',
    );

    await _mirrorMindService.completeActivitySession(_activitySessionId);

    await _clearProgress();

    emit(MirrorMindPartOneComplete(elapsed: elapsed));
  }

  Future<_AttemptInfo> _createAttemptForLevel({
    required MirrorMindLevelModel level,
    required int attemptNumber,
  }) async {
    final startedAt = DateTime.now().toIso8601String();

    final attemptId = await _mirrorMindService.createLevelAttempt(
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
    required MirrorMindLoaded currentState,
    required bool completed,
  }) {
    return _mirrorMindService.updateLevelAttempt(
      attemptId: currentState.currentAttemptId,
      attemptNumber: currentState.attemptNumber,
      startedAt: currentState.currentAttemptStartedAt,
      activitySessionId: _activitySessionId,
      levelId: currentState.level.id,
      completed: completed,
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

  String _levelCompleteMessage(int levelNumber) {
    switch (levelNumber) {
      case 1:
        return 'لقد اكتشفت أول سر للمرآة!';
      case 2:
        return 'رائع! أصبحت تفهم انعكاس أكثر من شكل.';
      case 3:
        return 'ممتاز! لقد أتقنت اتجاهات المرآة.';
      case 4:
        return 'جميل! أكملت النصف الناقص ببراعة.';
      case 5:
        return 'رائع! اكتشفت الشكل المختبئ بين النقاط.';
      case 6:
        return 'مذهل! ذاكرتك تعرف طريق المرآة.';
      default:
        return 'أحسنت! اقتربت من سر المرآة الأخير.';
    }
  }

  String get _progressStorageKey {
    return 'mirror_mind_progress_child_${_childId}_activity_${_activityId}';
  }

  Future<_SavedProgress?> _readSavedProgress() async {
    final rawProgress = await _progressStorage.read(
      key: _progressStorageKey,
    );

    if (rawProgress == null || rawProgress.trim().isEmpty) {
      return null;
    }

    try {
      final data = jsonDecode(rawProgress);

      if (data is! Map<String, dynamic>) return null;

      final levelIndex = data['levelIndex'];
      final challengeIndex = data['challengeIndex'];

      if (levelIndex is! int || challengeIndex is! int) {
        return null;
      }

      return _SavedProgress(
        levelIndex: levelIndex,
        challengeIndex: challengeIndex,
      );
    } catch (_) {
      return null;
    }
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

  Future<void> _clearProgress() async {
    await _progressStorage.delete(
      key: _progressStorageKey,
    );
  }

  Future<_SavedProgress> _resolveStartPosition({
    required List<MirrorMindLevelModel> levels,
    required int initialLevelNumber,
  }) async {
    if (initialLevelNumber > levels.length) {
      await _clearProgress();

      return const _SavedProgress(
        levelIndex: 0,
        challengeIndex: 0,
      );
    }

    final roadmapLevelIndex = (initialLevelNumber - 1).clamp(
      0,
      levels.length - 1,
    );

    final savedProgress = await _readSavedProgress();

    if (savedProgress == null) {
      return _SavedProgress(
        levelIndex: roadmapLevelIndex,
        challengeIndex: 0,
      );
    }

    if (savedProgress.levelIndex < roadmapLevelIndex) {
      return _SavedProgress(
        levelIndex: roadmapLevelIndex,
        challengeIndex: 0,
      );
    }

    if (savedProgress.levelIndex >= levels.length) {
      return _SavedProgress(
        levelIndex: roadmapLevelIndex,
        challengeIndex: 0,
      );
    }

    final savedLevel = levels[savedProgress.levelIndex];

    if (savedProgress.challengeIndex < 0 ||
        savedProgress.challengeIndex >= savedLevel.challenges.length) {
      return _SavedProgress(
        levelIndex: savedProgress.levelIndex,
        challengeIndex: 0,
      );
    }

    return savedProgress;
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

class _AttemptInfo {
  final int id;
  final String startedAt;

  const _AttemptInfo({
    required this.id,
    required this.startedAt,
  });
}

class _SavedProgress {
  final int levelIndex;
  final int challengeIndex;

  const _SavedProgress({
    required this.levelIndex,
    required this.challengeIndex,
  });
}