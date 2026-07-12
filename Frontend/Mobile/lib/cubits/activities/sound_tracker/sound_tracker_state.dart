import '../../../models/activities/sound_tracker/sound_tracker_level_model.dart';

abstract class SoundTrackerState {
  const SoundTrackerState();
}

class SoundTrackerInitial extends SoundTrackerState {
  const SoundTrackerInitial();
}

class SoundTrackerLoading extends SoundTrackerState {
  const SoundTrackerLoading();
}

class SoundTrackerError extends SoundTrackerState {
  final String message;

  const SoundTrackerError(this.message);
}

class SoundTrackerLoaded extends SoundTrackerState {
  final List<SoundTrackerLevelModel> levels;
  final int currentLevelIndex;
  final int currentAttemptId;
  final int attemptNumber;
  final String currentAttemptStartedAt;
  final bool audioFinished;

  // Level 1 => sectionCount = 1
  // Level 2 => sectionCount = 2
  // Level 3 => sectionCount = 3
  final int sectionCount;

  final List<bool> sectionAnswered;
  final List<bool> sectionCorrect;
  final List<String?> sectionScannedValues;

  const SoundTrackerLoaded({
    required this.levels,
    required this.currentLevelIndex,
    required this.currentAttemptId,
    required this.attemptNumber,
    required this.currentAttemptStartedAt,
    required this.audioFinished,
    required this.sectionCount,
    required this.sectionAnswered,
    required this.sectionCorrect,
    required this.sectionScannedValues,
  });

  SoundTrackerLevelModel get level => levels[currentLevelIndex];

  int get currentLevelNumber {
    if (level.levelNumber > 0) return level.levelNumber;
    return currentLevelIndex + 1;
  }

  int get totalLevels => levels.length;

  bool get isLastLevel => currentLevelIndex + 1 >= levels.length;

  bool get isMultiSection => sectionCount > 1;

  bool get canGoNext => audioFinished;

  bool get allSectionsAnswered {
    if (sectionAnswered.isEmpty) return false;
    return sectionAnswered.every((answered) => answered);
  }

  bool get allSectionsCorrect {
    if (sectionCorrect.isEmpty) return false;
    return sectionCorrect.every((correct) => correct);
  }

  bool get hasAnyWrongSection {
    return sectionCorrect.any((correct) => !correct);
  }

  int get firstUnansweredSectionIndex {
    for (int i = 0; i < sectionAnswered.length; i++) {
      if (!sectionAnswered[i]) return i;
    }

    return -1;
  }

  bool canScanSection(int sectionIndex) {
    if (sectionIndex < 0 || sectionIndex >= sectionCount) return false;

    // Section 1 is always available.
    if (sectionIndex == 0) return true;

    // Section 2 only opens after Section 1 is correct.
    // Section 3 only opens after Section 2 is correct.
    return sectionAnswered[sectionIndex - 1] &&
        sectionCorrect[sectionIndex - 1];
  }

  bool isSectionAnswered(int sectionIndex) {
    if (sectionIndex < 0 || sectionIndex >= sectionAnswered.length) {
      return false;
    }

    return sectionAnswered[sectionIndex];
  }

  bool isSectionCorrect(int sectionIndex) {
    if (sectionIndex < 0 || sectionIndex >= sectionCorrect.length) {
      return false;
    }

    return sectionCorrect[sectionIndex];
  }

  String? scannedValueForSection(int sectionIndex) {
    if (sectionIndex < 0 || sectionIndex >= sectionScannedValues.length) {
      return null;
    }

    return sectionScannedValues[sectionIndex];
  }

  SoundTrackerLoaded copyWith({
    List<SoundTrackerLevelModel>? levels,
    int? currentLevelIndex,
    int? currentAttemptId,
    int? attemptNumber,
    String? currentAttemptStartedAt,
    bool? audioFinished,
    int? sectionCount,
    List<bool>? sectionAnswered,
    List<bool>? sectionCorrect,
    List<String?>? sectionScannedValues,
  }) {
    return SoundTrackerLoaded(
      levels: levels ?? this.levels,
      currentLevelIndex: currentLevelIndex ?? this.currentLevelIndex,
      currentAttemptId: currentAttemptId ?? this.currentAttemptId,
      attemptNumber: attemptNumber ?? this.attemptNumber,
      currentAttemptStartedAt:
      currentAttemptStartedAt ?? this.currentAttemptStartedAt,
      audioFinished: audioFinished ?? this.audioFinished,
      sectionCount: sectionCount ?? this.sectionCount,
      sectionAnswered: sectionAnswered ?? this.sectionAnswered,
      sectionCorrect: sectionCorrect ?? this.sectionCorrect,
      sectionScannedValues:
      sectionScannedValues ?? this.sectionScannedValues,
    );
  }
}

class SoundTrackerResult extends SoundTrackerState {
  final bool isCorrect;
  final SoundTrackerLoaded previousState;
  final String message;

  const SoundTrackerResult({
    required this.isCorrect,
    required this.previousState,
    required this.message,
  });
}


class SoundTrackerActivityComplete extends SoundTrackerState {
  const SoundTrackerActivityComplete();
}