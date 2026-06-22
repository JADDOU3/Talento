import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/activities/story_spinner/icon_arabic_labels.dart';
import '../../../models/activities/story_spinner/story_spinner_level_model.dart';
import '../../../services/activities/story_spinner_service.dart';
import 'story_spinner_state.dart';

class StorySpinnerCubit extends Cubit<StorySpinnerState> {
  StorySpinnerCubit({
    StorySpinnerService? storySpinnerService,
  })  : _service = storySpinnerService ?? StorySpinnerService(),
        super(const StorySpinnerInitial());

  final StorySpinnerService _service;

  Timer? _timer;

  late int _activityId;
  late int _activitySessionId;
  late int _childId;
  late int _sessionId;

  String _currentAttemptStartedAt = '';
  int _currentLevelId = 0;

  bool _activityCompleted = false;
  bool _gameLoaded = false;
  bool _wheelsLogged = false;
  bool _voiceCheckFailedOnce = false;

  Future<void> loadGame({
    required int activityId,
    required int activitySessionId,
    required int childId,
    required int sessionId,
  }) async {
    emit(const StorySpinnerLoading());

    _activityId = activityId;
    _activitySessionId = activitySessionId;
    _childId = childId;
    _sessionId = sessionId;
    _activityCompleted = false;
    _gameLoaded = false;
    _wheelsLogged = false;
    _voiceCheckFailedOnce = false;
    _currentAttemptStartedAt = '';
    _currentLevelId = 0;

    try {
      final levels = await _service.getLevelsByActivity(activityId);

      final playableLevels = levels.where((level) {
        return level.spinChallenges.length >= 3 && level.voiceChallenge != null;
      }).toList();

      if (playableLevels.isEmpty) {
        emit(
          const StorySpinnerError(
            'No complete Story Spinner level was found.',
          ),
        );
        return;
      }

      final level = playableLevels.first;

      _currentLevelId = level.id;
      _currentAttemptStartedAt = DateTime.now().toIso8601String();

      final attemptId = await _service.createLevelAttempt(
        attemptNumber: 1,
        startedAt: _currentAttemptStartedAt,
        activitySessionId: activitySessionId,
        levelId: level.id,
      );

      await _service.postActivityEvent(
        childId: childId,
        sessionId: sessionId,
        activityId: activityId,
        action: 'STARTED',
      );

      await _service.postLevelEvent(
        childId: childId,
        sessionId: sessionId,
        activitySessionId: activitySessionId,
        action: 'STARTED',
      );

      _gameLoaded = true;

      emit(
        StorySpinnerLoaded(
          level: level,
          currentAttemptId: attemptId,
          attemptNumber: 1,
          elapsed: Duration.zero,
        ),
      );

      _startTimer();
    } catch (error) {
      emit(StorySpinnerError(error.toString()));
    }
  }

  void onSpinStarted(String wheelStep) {
    final currentState = state;

    if (currentState is! StorySpinnerLoaded) return;
    if (currentState.isSpinning) return;

    final icons = _iconsForStep(currentState.level, wheelStep);

    if (icons.isEmpty) return;

    emit(
      currentState.copyWith(
        isSpinning: true,
        spinningStep: wheelStep.trim().toLowerCase(),
      ),
    );
  }

  void onSpinLanded(String wheelStep, String icon) {
    final currentState = state;

    if (currentState is! StorySpinnerLoaded) return;

    final normalizedStep = wheelStep.trim().toLowerCase();

    switch (normalizedStep) {
      case 'character':
        emit(
          currentState.copyWith(
            characterIcon: icon,
            isSpinning: false,
            clearSpinningStep: true,
          ),
        );
        return;

      case 'event':
        emit(
          currentState.copyWith(
            eventIcon: icon,
            isSpinning: false,
            clearSpinningStep: true,
          ),
        );
        return;

      case 'place':
        emit(
          currentState.copyWith(
            placeIcon: icon,
            isSpinning: false,
            clearSpinningStep: true,
          ),
        );
        return;

      default:
        emit(
          currentState.copyWith(
            isSpinning: false,
            clearSpinningStep: true,
          ),
        );
    }
  }

  Future<void> onWheelsConfirmed() async {
    final currentState = state;

    if (currentState is! StorySpinnerLoaded) return;
    if (!currentState.allWheelsLanded) return;

    try {
      if (!_wheelsLogged) {
        await _logSpinChallengesCompleted();
        _wheelsLogged = true;
      }

      emit(const StorySpinnerStepCompleted('wheels'));

      if (!isClosed) {
        emit(currentState);
      }
    } catch (error) {
      emit(StorySpinnerError(error.toString()));
    }
  }

  void onRecordingComplete(String filePath) {
    final currentState = state;

    if (currentState is! StorySpinnerLoaded) return;

    emit(
      currentState.copyWith(
        recordedFilePath: filePath,
        isCompleting: false,
        clearVoiceCheckResult: true,
      ),
    );
  }

  Future<void> onStoryDone() async {
    final currentState = state;

    if (currentState is! StorySpinnerLoaded) return;
    if (!currentState.hasRecording) return;
    if (currentState.isCompleting) return;

    try {
      final keywords = _arabicKeywordsForSelectedIcons(currentState);
      final recordedFilePath = currentState.recordedFilePath!;

      emit(
        currentState.copyWith(
          isCompleting: true,
          clearVoiceCheckResult: true,
        ),
      );

      if (_voiceCheckFailedOnce) {
        await _service.postLevelEvent(
          childId: _childId,
          sessionId: _sessionId,
          activitySessionId: _activitySessionId,
          action: 'RETRIED',
        );
      }

      final voiceCheckResult = await _service.transcribeWithKeywords(
        filePath: recordedFilePath,
        activityId: _activityId,
        keywords: keywords,
      );

      if (!voiceCheckResult.success) {
        await _service.postLevelEvent(
          childId: _childId,
          sessionId: _sessionId,
          activitySessionId: _activitySessionId,
          action: 'FAILED',
        );

        _voiceCheckFailedOnce = true;

        final latestState = state;
        final loadedState = latestState is StorySpinnerLoaded
            ? latestState
            : currentState;

        emit(
          loadedState.copyWith(
            isCompleting: false,
            missingKeywords: voiceCheckResult.missingKeywords,
            transcribedText: voiceCheckResult.text,
          ),
        );
        return;
      }

      await _service.postLevelEvent(
        childId: _childId,
        sessionId: _sessionId,
        activitySessionId: _activitySessionId,
        action: 'COMPLETED',
      );

      await _service.updateLevelAttempt(
        attemptId: currentState.currentAttemptId,
        attemptNumber: currentState.attemptNumber,
        startedAt: _currentAttemptStartedAt,
        activitySessionId: _activitySessionId,
        levelId: _currentLevelId,
        completed: true,
      );

      await _service.postActivityEvent(
        childId: _childId,
        sessionId: _sessionId,
        activityId: _activityId,
        action: 'COMPLETED',
        responseLanguage: 'ar',
      );

      await _service.completeActivitySession(_activitySessionId);

      _activityCompleted = true;
      _stopTimer();

      emit(const StorySpinnerActivityComplete());
    } catch (error) {
      emit(StorySpinnerError(error.toString()));
    }
  }

  Future<void> dispose() async {
    await _logEndedIfNeeded();
  }

  @override
  Future<void> close() async {
    await _logEndedIfNeeded();
    _stopTimer();
    return super.close();
  }

  List<String> _arabicKeywordsForSelectedIcons(
      StorySpinnerLoaded currentState,
      ) {
    final selectedIcons = <String?>[
      currentState.characterIcon,
      currentState.eventIcon,
      currentState.placeIcon,
    ];

    final keywords = <String>[];

    for (final icon in selectedIcons) {
      final normalizedIcon = icon?.trim();

      if (normalizedIcon == null || normalizedIcon.isEmpty) {
        throw Exception('Please spin all story elements first.');
      }

      final keyword = iconArabicLabels[normalizedIcon];

      if (keyword == null || keyword.trim().isEmpty) {
        throw Exception('Missing Arabic label for icon: $normalizedIcon');
      }

      keywords.add(keyword);
    }

    return keywords;
  }

  List<String> _iconsForStep(
      StorySpinnerLevelModel level,
      String step,
      ) {
    final challenge = level.spinChallengeForStep(step);

    if (challenge == null) return <String>[];

    return challenge.icons;
  }

  Future<void> _logSpinChallengesCompleted() async {
    final currentState = state;

    if (currentState is! StorySpinnerLoaded) return;

    final spinChallenges = currentState.level.spinChallenges;

    for (final _ in spinChallenges) {
      await _service.postLevelEvent(
        childId: _childId,
        sessionId: _sessionId,
        activitySessionId: _activitySessionId,
        action: 'COMPLETED',
      );
    }
  }

  Future<void> _logEndedIfNeeded() async {
    if (_activityCompleted) return;
    if (!_gameLoaded) return;

    try {
      await _service.postActivityEvent(
        childId: _childId,
        sessionId: _sessionId,
        activityId: _activityId,
        action: 'ENDED',
      );
    } catch (_) {
      // Do not break navigation/dispose if logging fails.
    } finally {
      _gameLoaded = false;
    }
  }

  void _startTimer() {
    _stopTimer();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final currentState = state;

      if (currentState is! StorySpinnerLoaded) return;

      emit(
        currentState.copyWith(
          elapsed: currentState.elapsed + const Duration(seconds: 1),
        ),
      );
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }
}