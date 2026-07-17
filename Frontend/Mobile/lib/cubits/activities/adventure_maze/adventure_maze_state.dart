import '../../../activities/adventure_maze/config/adventure_maze_level_config.dart';
import '../../../models/activities/adventure_maze/adventure_maze_models.dart';

abstract class AdventureMazeState {
  const AdventureMazeState();
}

class AdventureMazeInitial extends AdventureMazeState {
  const AdventureMazeInitial();
}

class AdventureMazeLoading extends AdventureMazeState {
  const AdventureMazeLoading();
}

class AdventureMazeError extends AdventureMazeState {
  final String message;
  const AdventureMazeError(this.message);
}

/// Active gameplay.
class AdventureMazeLoaded extends AdventureMazeState {
  final AdventureMazeLevel level;
  final AdventureMazeLevelConfig config;
  final List<StarChallenge> challenges;
  final Set<int> collectedChallengeIds;
  final int currentAttemptId;
  final int attemptNumber;
  final Duration elapsed;

  /// Which star (challengeId) is currently open in the popup, if any.
  /// null = no popup, game is running.
  final int? activeChallengeId;

  const AdventureMazeLoaded({
    required this.level,
    required this.config,
    required this.challenges,
    required this.collectedChallengeIds,
    required this.currentAttemptId,
    required this.attemptNumber,
    this.elapsed = Duration.zero,
    this.activeChallengeId,
  });

  AdventureMazeLoaded copyWith({
    Set<int>? collectedChallengeIds,
    int? currentAttemptId,
    int? attemptNumber,
    Duration? elapsed,
    int? activeChallengeId,
    bool clearActiveChallenge = false,
  }) {
    return AdventureMazeLoaded(
      level: level,
      config: config,
      challenges: challenges,
      collectedChallengeIds:
          collectedChallengeIds ?? this.collectedChallengeIds,
      currentAttemptId: currentAttemptId ?? this.currentAttemptId,
      attemptNumber: attemptNumber ?? this.attemptNumber,
      elapsed: elapsed ?? this.elapsed,
      activeChallengeId: clearActiveChallenge
          ? null
          : (activeChallengeId ?? this.activeChallengeId),
    );
  }

  bool get allStarsCollected =>
      collectedChallengeIds.length >= challenges.length;
}

/// Ball fell into a hole — brief feedback, screen resets the ball.
/// Collected stars persist.
class AdventureMazeFailed extends AdventureMazeState {
  final int currentAttemptId;
  final int attemptNumber;
  const AdventureMazeFailed({
    required this.currentAttemptId,
    required this.attemptNumber,
  });
}

class AdventureMazeComplete extends AdventureMazeState {
  const AdventureMazeComplete();
}
