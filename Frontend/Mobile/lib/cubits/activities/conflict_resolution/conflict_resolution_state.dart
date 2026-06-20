import '../../../models/activities/conflict_resolution/conflict_resolution_challenge_model.dart';
import '../../../models/activities/conflict_resolution/conflict_resolution_level_model.dart';

abstract class ConflictResolutionState {
  const ConflictResolutionState();
}

class ConflictResolutionInitial extends ConflictResolutionState {
  const ConflictResolutionInitial();
}

class ConflictResolutionLoading extends ConflictResolutionState {
  const ConflictResolutionLoading();
}

class ConflictResolutionError extends ConflictResolutionState {
  final String message;

  const ConflictResolutionError(this.message);
}

class ConflictResolutionLoaded extends ConflictResolutionState {
  final List<ConflictResolutionLevelModel> levels;
  final int currentLevelIndex;
  final int currentChallengeIndex;
  final int currentAttemptId;
  final int attemptNumber;
  final String currentAttemptStartedAt;
  final Duration elapsed;
  final bool videoFinished;
  final int? timerSeconds;
  final int? timerRemaining;

  const ConflictResolutionLoaded({
    required this.levels,
    required this.currentLevelIndex,
    required this.currentChallengeIndex,
    required this.currentAttemptId,
    required this.attemptNumber,
    required this.currentAttemptStartedAt,
    required this.elapsed,
    required this.videoFinished,
    required this.timerSeconds,
    required this.timerRemaining,
  });

  ConflictResolutionLevelModel get level => levels[currentLevelIndex];

  ConflictResolutionChallengeModel get challenge {
    return level.challenges[currentChallengeIndex];
  }

  int get currentLevelNumber => currentLevelIndex + 1;

  int get totalLevels => levels.length;

  int get currentChallengeNumber => currentChallengeIndex + 1;

  int get totalChallenges => level.challenges.length;

  bool get isLastChallengeInLevel {
    return currentChallengeIndex >= level.challenges.length - 1;
  }

  bool get isLastLevel {
    return currentLevelIndex >= levels.length - 1;
  }

  bool get canContinue => videoFinished;

  ConflictResolutionLoaded copyWith({
    List<ConflictResolutionLevelModel>? levels,
    int? currentLevelIndex,
    int? currentChallengeIndex,
    int? currentAttemptId,
    int? attemptNumber,
    String? currentAttemptStartedAt,
    Duration? elapsed,
    bool? videoFinished,
    int? timerSeconds,
    int? timerRemaining,
    bool clearTimer = false,
  }) {
    return ConflictResolutionLoaded(
      levels: levels ?? this.levels,
      currentLevelIndex: currentLevelIndex ?? this.currentLevelIndex,
      currentChallengeIndex:
      currentChallengeIndex ?? this.currentChallengeIndex,
      currentAttemptId: currentAttemptId ?? this.currentAttemptId,
      attemptNumber: attemptNumber ?? this.attemptNumber,
      currentAttemptStartedAt:
      currentAttemptStartedAt ?? this.currentAttemptStartedAt,
      elapsed: elapsed ?? this.elapsed,
      videoFinished: videoFinished ?? this.videoFinished,
      timerSeconds: clearTimer ? null : timerSeconds ?? this.timerSeconds,
      timerRemaining:
      clearTimer ? null : timerRemaining ?? this.timerRemaining,
    );
  }
}

class ConflictResolutionChallengeResult extends ConflictResolutionState {
  final bool isCorrect;
  final ConflictResolutionLoaded previousState;

  const ConflictResolutionChallengeResult({
    required this.isCorrect,
    required this.previousState,
  });
}

class ConflictResolutionLevelComplete extends ConflictResolutionState {
  final ConflictResolutionLoaded previousState;
  final String message;

  const ConflictResolutionLevelComplete({
    required this.previousState,
    required this.message,
  });
}

class ConflictResolutionActivityComplete extends ConflictResolutionState {
  final Duration elapsed;

  const ConflictResolutionActivityComplete({
    required this.elapsed,
  });
}