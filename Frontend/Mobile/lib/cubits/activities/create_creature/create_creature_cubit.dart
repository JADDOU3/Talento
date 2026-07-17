import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/activities/create_creature/create_creature_challenge_model.dart';
import '../../../services/activities/create_creature_service.dart';
import 'create_creature_state.dart';
import 'dart:io';
import '../../../activities/create_creature/icon_arabic_labels.dart';

class CreateCreatureCubit extends Cubit<CreateCreatureState> {
  static const Duration _maximumRecordingDuration = Duration(minutes: 3);

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
  Duration _recordingDuration = Duration.zero;

  CreateCreatureLoaded? _getLoaded() {
    final currentState = state;
    if (currentState is CreateCreatureLoaded) return currentState;
    if (currentState is CreateCreatureStepCompleted) return currentState.previousState;
    if (currentState is CreateCreatureVoiceCheckFailed) return currentState.previousState;
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
    _recordingDuration = Duration.zero;

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

      // final appearanceChallenge = level.challenges
      //     .where((c) => c.type == CreateCreatureChallengeType.preview)
      //     .firstOrNull;
      // final creatureLookup = appearanceChallenge?.lookup ?? const [];

      emit(
        CreateCreatureLoaded(
          level: level,
          currentAttemptId: attemptId,
          attemptNumber: 1,
          currentAttemptStartedAt: startedAt,
          elapsed: Duration.zero,
          // creatureLookup: creatureLookup,
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

  void onGenderSelected(String icon) {
    final loaded = _getLoaded();
    if (loaded == null) return;
    _emitLoaded(loaded.copyWith(genderSelection: icon));
  }

  void onHairColorSelected(String icon) {
    print('HAIR COLOR SELECTED: "$icon"');
    final loaded = _getLoaded();
    if (loaded == null) return;
    _emitLoaded(loaded.copyWith(hairColorSelection: icon));
  }

  Future<void> onGenderHairConfirmed() async {
    final loaded = _getLoaded();
    if (loaded == null) return;
    if (!loaded.genderHairComplete) return;

    try {
      for (int i = 0; i < 2; i++) {
        await _createCreatureService.postLevelEvent(
          childId: _childId,
          sessionId: _sessionId,
          activitySessionId: _activitySessionId,
          action: 'COMPLETED',
        );
      }

      emit(
        CreateCreatureStepCompleted(
          step: 'genderHair',
          previousState: loaded,
        ),
      );
      // _loadCreatureBaseImage();
    } catch (error) {
      emit(CreateCreatureError(error.toString()));
    }
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

  void onHomeSelected(String icon) {
    final loaded = _getLoaded();
    if (loaded == null) return;
    _emitLoaded(loaded.copyWith(homeSelection: icon));
  }

  Future<void> onAbilityHomeConfirmed() async {
    final loaded = _getLoaded();
    if (loaded == null) return;
    if (!loaded.abilityHomeComplete) return;

    try {
      for (int i = 0; i < 2; i++) {
        await _createCreatureService.postLevelEvent(
          childId: _childId,
          sessionId: _sessionId,
          activitySessionId: _activitySessionId,
          action: 'COMPLETED',
        );
      }

      emit(
        CreateCreatureStepCompleted(
          step: 'abilityHome',
          previousState: loaded,
        ),
      );
    } catch (error) {
      emit(CreateCreatureError(error.toString()));
    }
  }

  void onRecordingComplete(
      String filePath,
      Duration recordingDuration,
      ) {
    final loaded = _getLoaded();
    if (loaded == null) return;

    if (recordingDuration > _maximumRecordingDuration) {
      emit(
        const CreateCreatureError(
          'لا يمكن أن تزيد مدة التسجيل عن 3 دقائق.',
        ),
      );
      return;
    }

    _recordingDuration = recordingDuration;
    _emitLoaded(loaded.copyWith(recordedFilePath: filePath));
  }

  void onRecordingCleared() {
    final loaded = _getLoaded();
    if (loaded == null) return;

    _recordingDuration = Duration.zero;
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

    final abilityKeyword = iconArabicLabels[loaded.abilitySelection];
    final homeKeyword = iconArabicLabels[loaded.homeSelection];

    if (abilityKeyword == null || homeKeyword == null) {
      emit(const CreateCreatureError('Missing ability or home keyword mapping.'));
      return;
    }

    final keywords = [abilityKeyword, homeKeyword];

    if (state is CreateCreatureVoiceCheckFailed) {
      try {
        await _createCreatureService.postLevelEvent(
          childId: _childId,
          sessionId: _sessionId,
          activitySessionId: _activitySessionId,
          action: 'RETRIED',
        );
      } catch (_) {}
    }

    try {
      final response = await _createCreatureService.transcribeWithKeywords(
        file: File(loaded.recordedFilePath!),
        activityId: _activityId,
        activitySessionId: _activitySessionId,
        levelId: loaded.level.id,
        keywords: keywords,
        recordingDuration: _recordingDuration,
      );

      final success = response['success'] == true;
      final text = response['text']?.toString() ?? '';
      final missingKeywords = (response['missingKeywords'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [];

      if (success) {
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
      } else {
        await _createCreatureService.postLevelEvent(
          childId: _childId,
          sessionId: _sessionId,
          activitySessionId: _activitySessionId,
          action: 'FAILED',
        );

        emit(CreateCreatureVoiceCheckFailed(
          missingKeywords: missingKeywords,
          transcribedText: text,
          previousState: loaded,
        ));
      }
    } catch (error) {
      emit(CreateCreatureError(error.toString()));
    }
  }

  void onTimerTick() {
    final loaded = _getLoaded();
    if (loaded == null) return;
    final currentState = state;
    if (currentState is CreateCreatureStepCompleted) {
      emit(CreateCreatureStepCompleted(
        step: currentState.step,
        previousState: loaded.copyWith(elapsed: loaded.elapsed + const Duration(seconds: 1)),
      ));
    } else if (currentState is CreateCreatureVoiceCheckFailed) {
      emit(CreateCreatureVoiceCheckFailed(
        missingKeywords: currentState.missingKeywords,
        transcribedText: currentState.transcribedText,
        previousState: loaded.copyWith(elapsed: loaded.elapsed + const Duration(seconds: 1)),
      ));
    } else {
      emit(loaded.copyWith(elapsed: loaded.elapsed + const Duration(seconds: 1)));
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

// void _loadCreatureBaseImage() {
//   final loaded = _getLoaded();
//   if (loaded == null) return;

//   final gender = loaded.genderSelection;
//   final hairColor = loaded.hairColorSelection;
//   if (gender == null || hairColor == null) return;

//   final match = _resolveCreatureEntry(loaded.creatureLookup, gender, hairColor);

//   if (match == null) {
//     print(
//       'CREATE CREATURE: no lookup entry for gender=$gender hairColor=$hairColor',
//     );
//     return;
//   }

//   final url = match['url']?.toString();

//   if (url == null || url.isEmpty) {
//     print(
//       'CREATE CREATURE: no url in lookup entry for gender=$gender hairColor=$hairColor',
//     );
//     return;
//   }

//   print('CREATE CREATURE: resolved creature image url=$url');

//   _setCreatureImageUrl(url);
// }

// Map<String, dynamic>? _resolveCreatureEntry(
//     List<Map<String, dynamic>> lookup,
//     String gender,
//     String hairColor,
//     ) {
//   final match = lookup.firstWhere(
//         (e) => e['gender'] == gender && e['hairColor'] == hairColor,
//     orElse: () => {},
//   );
//   return match.isEmpty ? null : match;
// }

// void _setCreatureImageLoading(bool loading) {
//   final currentState = state;
//   if (currentState is CreateCreatureStepCompleted) {
//     emit(CreateCreatureStepCompleted(
//       step: currentState.step,
//       previousState:
//       currentState.previousState.copyWith(creatureImageLoading: loading),
//     ));
//   } else if (currentState is CreateCreatureLoaded) {
//     emit(currentState.copyWith(creatureImageLoading: loading));
//   }
// }

// void _setCreatureImageUrl(String url) {
//   final currentState = state;
//   if (currentState is CreateCreatureStepCompleted) {
//     emit(CreateCreatureStepCompleted(
//       step: currentState.step,
//       previousState: currentState.previousState.copyWith(
//         creatureBaseImageUrl: url,
//         creatureImageLoading: false,
//       ),
//     ));
//   } else if (currentState is CreateCreatureLoaded) {
//     emit(currentState.copyWith(
//       creatureBaseImageUrl: url,
//       creatureImageLoading: false,
//     ));
//   }
// }
}