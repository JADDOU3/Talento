import '../../../models/activities/story_spinner/story_spinner_level_model.dart';

abstract class StorySpinnerState {
  const StorySpinnerState();
}

class StorySpinnerInitial extends StorySpinnerState {
  const StorySpinnerInitial();
}

class StorySpinnerLoading extends StorySpinnerState {
  const StorySpinnerLoading();
}

class StorySpinnerError extends StorySpinnerState {
  final String message;

  const StorySpinnerError(this.message);
}

class StorySpinnerLoaded extends StorySpinnerState {
  final StorySpinnerLevelModel level;
  final int currentAttemptId;
  final int attemptNumber;
  final Duration elapsed;

  final String? characterIcon;
  final String? eventIcon;
  final String? placeIcon;

  final bool isSpinning;
  final String? spinningStep;

  final String? recordedFilePath;
  final bool isCompleting;

  final List<String> missingKeywords;
  final String? transcribedText;

  const StorySpinnerLoaded({
    required this.level,
    required this.currentAttemptId,
    required this.attemptNumber,
    required this.elapsed,
    this.characterIcon,
    this.eventIcon,
    this.placeIcon,
    this.isSpinning = false,
    this.spinningStep,
    this.recordedFilePath,
    this.isCompleting = false,
    this.missingKeywords = const <String>[],
    this.transcribedText,
  });

  bool get allWheelsLanded {
    return characterIcon != null && eventIcon != null && placeIcon != null;
  }

  bool get hasRecording {
    return recordedFilePath != null && recordedFilePath!.trim().isNotEmpty;
  }

  bool get voiceCheckFailed {
    return missingKeywords.isNotEmpty;
  }

  StorySpinnerLoaded copyWith({
    StorySpinnerLevelModel? level,
    int? currentAttemptId,
    int? attemptNumber,
    Duration? elapsed,
    String? characterIcon,
    String? eventIcon,
    String? placeIcon,
    bool? isSpinning,
    String? spinningStep,
    bool clearSpinningStep = false,
    String? recordedFilePath,
    bool? isCompleting,
    List<String>? missingKeywords,
    String? transcribedText,
    bool clearVoiceCheckResult = false,
  }) {
    return StorySpinnerLoaded(
      level: level ?? this.level,
      currentAttemptId: currentAttemptId ?? this.currentAttemptId,
      attemptNumber: attemptNumber ?? this.attemptNumber,
      elapsed: elapsed ?? this.elapsed,
      characterIcon: characterIcon ?? this.characterIcon,
      eventIcon: eventIcon ?? this.eventIcon,
      placeIcon: placeIcon ?? this.placeIcon,
      isSpinning: isSpinning ?? this.isSpinning,
      spinningStep: clearSpinningStep
          ? null
          : spinningStep ?? this.spinningStep,
      recordedFilePath: recordedFilePath ?? this.recordedFilePath,
      isCompleting: isCompleting ?? this.isCompleting,
      missingKeywords: clearVoiceCheckResult
          ? const <String>[]
          : missingKeywords ?? this.missingKeywords,
      transcribedText: clearVoiceCheckResult
          ? null
          : transcribedText ?? this.transcribedText,
    );
  }
}

class StorySpinnerStepCompleted extends StorySpinnerState {
  final String step;

  const StorySpinnerStepCompleted(this.step);
}

class StorySpinnerActivityComplete extends StorySpinnerState {
  const StorySpinnerActivityComplete();
}
