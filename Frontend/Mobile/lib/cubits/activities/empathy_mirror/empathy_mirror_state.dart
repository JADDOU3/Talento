import '../../../models/empathy_mirror/empathy_mirror_models.dart';

abstract class EmpathyMirrorState {
  const EmpathyMirrorState();
}

class EmpathyMirrorInitial extends EmpathyMirrorState {
  const EmpathyMirrorInitial();
}

class EmpathyMirrorLoading extends EmpathyMirrorState {
  const EmpathyMirrorLoading();
}

class EmpathyMirrorError extends EmpathyMirrorState {
  final String message;
  const EmpathyMirrorError(this.message);
}

class EmpathyMirrorLoaded extends EmpathyMirrorState {
  final EmpathyMirrorLevel level;
  final int currentChallengeIndex;
  final int currentAttemptId;
  final int attemptNumber;
  final bool videoFinished;
  final bool character1Answered;
  final bool character1Correct;
  final bool character2Answered;
  final bool character2Correct;

  const EmpathyMirrorLoaded({
    required this.level,
    required this.currentChallengeIndex,
    required this.currentAttemptId,
    required this.attemptNumber,
    this.videoFinished = false,
    this.character1Answered = false,
    this.character1Correct = false,
    this.character2Answered = false,
    this.character2Correct = false,
  });

  EmpathyMirrorImage get currentChallenge =>
      level.challenges[currentChallengeIndex];

  bool get isLevel2 => level.isChoiceLevel;

  /// Level 3 = split screen. Detected (in priority order) when:
  /// 1. Any challenge is tagged with a "character" (1 or 2) in its meta —
  ///    the current backend format.
  /// 2. Any challenge has type "video_continue" — an older backend format.
  /// 3. Fallback: the level simply has 2+ TARGET challenges and no choices.
  bool get isLevel3 {
    if (level.isChoiceLevel) return false; // that's Level 2
    if (level.challenges.any((c) => c.character != null)) return true;
    if (level.challenges.any((c) => c.isVideoContinue)) return true;
    return level.challenges.length >= 2;
  }

  /// Choices for the current challenge from the matching CHOICE image.
  List<ChoiceModel> get currentChoices {
    final cid = currentChallenge.challengeId;
    for (final img in level.choiceImages) {
      final imgCid = _toInt(img.meta['challengeId']);
      if (imgCid == cid) return img.choices;
    }
    return [];
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  EmpathyMirrorLoaded copyWith({
    EmpathyMirrorLevel? level,
    int? currentChallengeIndex,
    int? currentAttemptId,
    int? attemptNumber,
    bool? videoFinished,
    bool? character1Answered,
    bool? character1Correct,
    bool? character2Answered,
    bool? character2Correct,
  }) {
    return EmpathyMirrorLoaded(
      level: level ?? this.level,
      currentChallengeIndex:
      currentChallengeIndex ?? this.currentChallengeIndex,
      currentAttemptId: currentAttemptId ?? this.currentAttemptId,
      attemptNumber: attemptNumber ?? this.attemptNumber,
      videoFinished: videoFinished ?? this.videoFinished,
      character1Answered: character1Answered ?? this.character1Answered,
      character1Correct: character1Correct ?? this.character1Correct,
      character2Answered: character2Answered ?? this.character2Answered,
      character2Correct: character2Correct ?? this.character2Correct,
    );
  }
}

class EmpathyMirrorChallengeResult extends EmpathyMirrorState {
  final bool isCorrect;
  final bool isFollowup;
  final bool isSplitScreen;
  final int? characterIndex;
  final EmpathyMirrorLoaded snapshot;

  const EmpathyMirrorChallengeResult({
    required this.isCorrect,
    required this.snapshot,
    this.isFollowup = false,
    this.isSplitScreen = false,
    this.characterIndex,
  });
}

class EmpathyMirrorLevelComplete extends EmpathyMirrorState {
  const EmpathyMirrorLevelComplete();
}
