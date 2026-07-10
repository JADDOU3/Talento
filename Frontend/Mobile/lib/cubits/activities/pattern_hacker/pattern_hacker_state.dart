import '../../../models/activities/pattern_hacker/pattern_hacker_challenge_model.dart';
import '../../../models/activities/pattern_hacker/pattern_hacker_level_model.dart';

abstract class PatternHackerState {
  const PatternHackerState();
}

class PatternHackerInitial extends PatternHackerState {
  const PatternHackerInitial();
}

class PatternHackerLoading extends PatternHackerState {
  const PatternHackerLoading();
}

class PatternHackerError extends PatternHackerState {
  final String message;

  const PatternHackerError(this.message);
}

class PatternHackerLoaded extends PatternHackerState {
  final List<PatternHackerLevelModel> levels;
  final int currentLevelIndex;
  final int currentChallengeIndex;

  /// The icon name the child picked for the blank slot (null = nothing picked).
  final String? selectedIcon;

  final int currentAttemptId;
  final int attemptNumber;
  final String currentAttemptStartedAt;
  final Duration elapsed;

  const PatternHackerLoaded({
    required this.levels,
    required this.currentLevelIndex,
    required this.currentChallengeIndex,
    required this.selectedIcon,
    required this.currentAttemptId,
    required this.attemptNumber,
    required this.currentAttemptStartedAt,
    required this.elapsed,
  });

  PatternHackerLevelModel get level => levels[currentLevelIndex];

  PatternHackerChallengeModel get challenge =>
      level.challenges[currentChallengeIndex];

  int get totalChallenges => level.challenges.length;

  int get currentChallengeNumber => currentChallengeIndex + 1;

  int get currentLevelNumber => currentLevelIndex + 1;

  int get totalLevels => levels.length;

  bool get isLastChallengeInLevel {
    return currentChallengeIndex >= level.challenges.length - 1;
  }

  bool get isLastLevel {
    return currentLevelIndex >= levels.length - 1;
  }

  bool get canSubmit => selectedIcon != null;

  PatternHackerLoaded copyWith({
    List<PatternHackerLevelModel>? levels,
    int? currentLevelIndex,
    int? currentChallengeIndex,
    String? selectedIcon,
    bool clearSelectedIcon = false,
    int? currentAttemptId,
    int? attemptNumber,
    String? currentAttemptStartedAt,
    Duration? elapsed,
  }) {
    return PatternHackerLoaded(
      levels: levels ?? this.levels,
      currentLevelIndex: currentLevelIndex ?? this.currentLevelIndex,
      currentChallengeIndex:
      currentChallengeIndex ?? this.currentChallengeIndex,
      selectedIcon:
      clearSelectedIcon ? null : selectedIcon ?? this.selectedIcon,
      currentAttemptId: currentAttemptId ?? this.currentAttemptId,
      attemptNumber: attemptNumber ?? this.attemptNumber,
      currentAttemptStartedAt:
      currentAttemptStartedAt ?? this.currentAttemptStartedAt,
      elapsed: elapsed ?? this.elapsed,
    );
  }
}

/// Unified feedback shown after submitting a correct or wrong answer.
class PatternHackerChallengeResult extends PatternHackerState {
  final bool isCorrect;
  final PatternHackerLoaded previousState;

  const PatternHackerChallengeResult({
    required this.isCorrect,
    required this.previousState,
  });
}

/// A level was finished but more levels remain (intermediate animation).
class PatternHackerLevelComplete extends PatternHackerState {
  final PatternHackerLoaded previousState;
  final String message;

  const PatternHackerLevelComplete({
    required this.previousState,
    required this.message,
  });
}

/// All levels finished -> go to the result screen.
class PatternHackerGameComplete extends PatternHackerState {
  final Duration elapsed;

  const PatternHackerGameComplete({
    required this.elapsed,
  });
}
