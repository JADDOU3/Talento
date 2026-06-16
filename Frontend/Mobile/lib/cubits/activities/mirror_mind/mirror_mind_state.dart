import '../../../models/activities/mirror_mind/mirror_mind_challenge_model.dart';
import '../../../models/activities/mirror_mind/mirror_mind_level_model.dart';

abstract class MirrorMindState {
  const MirrorMindState();
}

class MirrorMindInitial extends MirrorMindState {
  const MirrorMindInitial();
}

class MirrorMindLoading extends MirrorMindState {
  const MirrorMindLoading();
}

class MirrorMindError extends MirrorMindState {
  final String message;

  const MirrorMindError(this.message);
}

class MirrorMindLoaded extends MirrorMindState {
  final List<MirrorMindLevelModel> levels;
  final int currentLevelIndex;
  final int currentChallengeIndex;
  final int? selectedChoiceIndex;
  final int currentAttemptId;
  final int attemptNumber;
  final String currentAttemptStartedAt;
  final Duration elapsed;

  const MirrorMindLoaded({
    required this.levels,
    required this.currentLevelIndex,
    required this.currentChallengeIndex,
    required this.selectedChoiceIndex,
    required this.currentAttemptId,
    required this.attemptNumber,
    required this.currentAttemptStartedAt,
    required this.elapsed,
  });

  MirrorMindLevelModel get level => levels[currentLevelIndex];

  MirrorMindChallengeModel get challenge =>
      level.challenges[currentChallengeIndex];

  int get totalChallenges => level.challenges.length;

  int get currentChallengeNumber => currentChallengeIndex + 1;

  int get currentLevelNumber {
    if (level.levelNumber > 0) return level.levelNumber;
    return currentLevelIndex + 1;
  }

  bool get isLastChallengeInLevel {
    return currentChallengeIndex >= level.challenges.length - 1;
  }

  bool get isLastLevel {
    return currentLevelIndex + 1 >= levels.length;
  }

  bool get canSubmit => selectedChoiceIndex != null;

  bool get hasValidSelectedChoice {
    if (selectedChoiceIndex == null) return false;

    return selectedChoiceIndex! >= 0 &&
        selectedChoiceIndex! < challenge.choices.length;
  }

  MirrorMindLoaded copyWith({
    List<MirrorMindLevelModel>? levels,
    int? currentLevelIndex,
    int? currentChallengeIndex,
    int? selectedChoiceIndex,
    bool clearSelectedChoice = false,
    int? currentAttemptId,
    int? attemptNumber,
    String? currentAttemptStartedAt,
    Duration? elapsed,
  }) {
    return MirrorMindLoaded(
      levels: levels ?? this.levels,
      currentLevelIndex: currentLevelIndex ?? this.currentLevelIndex,
      currentChallengeIndex: currentChallengeIndex ?? this.currentChallengeIndex,
      selectedChoiceIndex: clearSelectedChoice
          ? null
          : selectedChoiceIndex ?? this.selectedChoiceIndex,
      currentAttemptId: currentAttemptId ?? this.currentAttemptId,
      attemptNumber: attemptNumber ?? this.attemptNumber,
      currentAttemptStartedAt:
      currentAttemptStartedAt ?? this.currentAttemptStartedAt,
      elapsed: elapsed ?? this.elapsed,
    );
  }
}

class MirrorMindChallengeResult extends MirrorMindState {
  final bool isCorrect;
  final MirrorMindLoaded previousState;

  const MirrorMindChallengeResult({
    required this.isCorrect,
    required this.previousState,
  });
}

class MirrorMindLevelComplete extends MirrorMindState {
  final MirrorMindLoaded previousState;
  final String message;

  const MirrorMindLevelComplete({
    required this.previousState,
    required this.message,
  });
}

class MirrorMindPartOneComplete extends MirrorMindState {
  final Duration elapsed;

  const MirrorMindPartOneComplete({
    required this.elapsed,
  });
}