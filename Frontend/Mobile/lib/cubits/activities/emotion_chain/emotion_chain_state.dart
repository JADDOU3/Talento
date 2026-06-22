import '../../../models/activities/emotion_chain/emotion_chain_challenge_model.dart';
import '../../../models/activities/emotion_chain/emotion_chain_level_model.dart';

abstract class EmotionChainState {
  const EmotionChainState();
}

class EmotionChainInitial extends EmotionChainState {
  const EmotionChainInitial();
}

class EmotionChainLoading extends EmotionChainState {
  const EmotionChainLoading();
}

class EmotionChainError extends EmotionChainState {
  final String message;
  const EmotionChainError(this.message);
}

/// The first challenge of [level] plays its video.
class EmotionChainVideoPlaying extends EmotionChainState {
  final EmotionChainLevelModel level;
  const EmotionChainVideoPlaying({required this.level});

  EmotionChainChallengeModel get videoChallenge => level.challenges.first;
}

/// A step is shown and waiting for a QR scan.
class EmotionChainStepReady extends EmotionChainState {
  final EmotionChainLevelModel level;
  final int currentChallengeIndex;
  final int currentAttemptId;
  final int attemptNumber;
  final int? timerSeconds; // null if no timer
  final int? timerRemaining; // live countdown, null if no timer

  const EmotionChainStepReady({
    required this.level,
    required this.currentChallengeIndex,
    required this.currentAttemptId,
    required this.attemptNumber,
    required this.timerSeconds,
    required this.timerRemaining,
  });

  EmotionChainChallengeModel get challenge =>
      level.challenges[currentChallengeIndex];

  bool get hasTimer => timerSeconds != null;
  bool get isTimeUp => timerRemaining != null && timerRemaining! <= 0;

  EmotionChainStepReady copyWith({int? timerRemaining}) {
    return EmotionChainStepReady(
      level: level,
      currentChallengeIndex: currentChallengeIndex,
      currentAttemptId: currentAttemptId,
      attemptNumber: attemptNumber,
      timerSeconds: timerSeconds,
      timerRemaining: timerRemaining ?? this.timerRemaining,
    );
  }
}

/// Brief result feedback (correct / wrong) before advancing or retrying.
class EmotionChainStepResult extends EmotionChainState {
  final bool isCorrect;
  final EmotionChainLevelModel level;
  final int challengeIndex;

  const EmotionChainStepResult({
    required this.isCorrect,
    required this.level,
    required this.challengeIndex,
  });

  EmotionChainChallengeModel get challenge => level.challenges[challengeIndex];
}

/// A level finished but more levels remain (intermediate).
class EmotionChainLevelComplete extends EmotionChainState {
  final int levelNumber;
  const EmotionChainLevelComplete({required this.levelNumber});
}

/// All levels finished.
class EmotionChainActivityComplete extends EmotionChainState {
  const EmotionChainActivityComplete();
}
