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
  final String? selectedIcon;
  final int currentAttemptId;
  final int attemptNumber;
  final Duration elapsed;

  const MirrorMindLoaded({
    required this.levels,
    required this.currentLevelIndex,
    required this.currentChallengeIndex,
    required this.selectedIcon,
    required this.currentAttemptId,
    required this.attemptNumber,
    required this.elapsed,
  });

  MirrorMindLevelModel get level => levels[currentLevelIndex];

  MirrorMindChallengeModel get challenge =>
      level.challenges[currentChallengeIndex];

  int get totalChallenges => level.challenges.length;

  bool get isLastChallengeInLevel {
    return currentChallengeIndex >= level.challenges.length - 1;
  }

  bool get isLastPartOneLevel {
    return currentLevelIndex >= 2;
  }

  bool get canSubmit => selectedIcon != null && selectedIcon!.isNotEmpty;

  MirrorMindLoaded copyWith({
    List<MirrorMindLevelModel>? levels,
    int? currentLevelIndex,
    int? currentChallengeIndex,
    String? selectedIcon,
    bool clearSelectedIcon = false,
    int? currentAttemptId,
    int? attemptNumber,
    Duration? elapsed,
  }) {
    return MirrorMindLoaded(
      levels: levels ?? this.levels,
      currentLevelIndex: currentLevelIndex ?? this.currentLevelIndex,
      currentChallengeIndex: currentChallengeIndex ?? this.currentChallengeIndex,
      selectedIcon:
      clearSelectedIcon ? null : selectedIcon ?? this.selectedIcon,
      currentAttemptId: currentAttemptId ?? this.currentAttemptId,
      attemptNumber: attemptNumber ?? this.attemptNumber,
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

  const MirrorMindLevelComplete({
    required this.previousState,
  });
}

class MirrorMindPartOneComplete extends MirrorMindState {
  final Duration elapsed;

  const MirrorMindPartOneComplete({
    required this.elapsed,
  });
}