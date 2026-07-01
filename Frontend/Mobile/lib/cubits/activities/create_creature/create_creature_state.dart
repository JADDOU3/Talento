import '../../../models/activities/create_creature/create_creature_level_model.dart';

abstract class CreateCreatureState {
  const CreateCreatureState();
}

class CreateCreatureInitial extends CreateCreatureState {
  const CreateCreatureInitial();
}

class CreateCreatureLoading extends CreateCreatureState {
  const CreateCreatureLoading();
}

class CreateCreatureError extends CreateCreatureState {
  final String message;

  const CreateCreatureError(this.message);
}

class CreateCreatureLoaded extends CreateCreatureState {
  final CreateCreatureLevelModel level;
  final int currentAttemptId;
  final int attemptNumber;
  final String currentAttemptStartedAt;
  final Duration elapsed;

  // final String? creatureBaseImageUrl;
  // final bool? creatureImageLoading;

  final String? genderSelection;
  final String? hairColorSelection;

  // final List<Map<String, dynamic>> creatureLookup;

  final String? eyesSelection;
  final String? mouthSelection;
  final String? feelingSelection;

  final String? abilitySelection;
  final String? homeSelection;

  final String? recordedFilePath;

  const CreateCreatureLoaded({
    required this.level,
    required this.currentAttemptId,
    required this.attemptNumber,
    required this.currentAttemptStartedAt,
    required this.elapsed,
    this.genderSelection,
    this.hairColorSelection,
    // this.creatureLookup = const [],
    this.eyesSelection,
    this.mouthSelection,
    this.feelingSelection,
    this.abilitySelection,
    this.homeSelection,
    this.recordedFilePath,
    // this.creatureBaseImageUrl,
    // this.creatureImageLoading = false,
  });

  bool get genderHairComplete =>
      genderSelection != null && hairColorSelection != null;

  bool get faceComplete =>
      eyesSelection != null &&
          mouthSelection != null &&
          feelingSelection != null;

  bool get abilityHomeComplete =>
      abilitySelection != null && homeSelection != null;

  bool get hasRecording => recordedFilePath != null;

  CreateCreatureLoaded copyWith({
    int? currentAttemptId,
    int? attemptNumber,
    String? currentAttemptStartedAt,
    Duration? elapsed,
    String? genderSelection,
    String? hairColorSelection,
    // List<Map<String, dynamic>>? creatureLookup,
    String? eyesSelection,
    String? mouthSelection,
    String? feelingSelection,
    String? abilitySelection,
    String? homeSelection,
    String? recordedFilePath,
    // String? creatureBaseImageUrl,
    // bool? creatureImageLoading,
    bool clearRecordedFilePath = false,
  }) {
    return CreateCreatureLoaded(
      level: level,
      currentAttemptId: currentAttemptId ?? this.currentAttemptId,
      attemptNumber: attemptNumber ?? this.attemptNumber,
      currentAttemptStartedAt:
      currentAttemptStartedAt ?? this.currentAttemptStartedAt,
      elapsed: elapsed ?? this.elapsed,
      genderSelection: genderSelection ?? this.genderSelection,
      hairColorSelection: hairColorSelection ?? this.hairColorSelection,
      // creatureLookup: creatureLookup ?? this.creatureLookup,
      eyesSelection: eyesSelection ?? this.eyesSelection,
      mouthSelection: mouthSelection ?? this.mouthSelection,
      feelingSelection: feelingSelection ?? this.feelingSelection,
      abilitySelection: abilitySelection ?? this.abilitySelection,
      homeSelection: homeSelection ?? this.homeSelection,
      recordedFilePath: clearRecordedFilePath
          ? null
          : (recordedFilePath ?? this.recordedFilePath),
      // creatureBaseImageUrl: creatureBaseImageUrl ?? this.creatureBaseImageUrl,
      // creatureImageLoading: creatureImageLoading ?? this.creatureImageLoading,
    );
  }
}

class CreateCreatureStepCompleted extends CreateCreatureState {
  final String step;
  final CreateCreatureLoaded previousState;

  const CreateCreatureStepCompleted({
    required this.step,
    required this.previousState,
  });
}

class CreateCreatureActivityComplete extends CreateCreatureState {
  const CreateCreatureActivityComplete();
}

class CreateCreatureVoiceCheckFailed extends CreateCreatureState {
  final List<String> missingKeywords;
  final String transcribedText;
  final CreateCreatureLoaded previousState;

  const CreateCreatureVoiceCheckFailed({
    required this.missingKeywords,
    required this.transcribedText,
    required this.previousState,
  });
}