import '../../../models/activities/creative_maze/creative_maze_level_model.dart';
import '../../../activities/creative_maze/config/creative_maze_level_config.dart';

abstract class CreativeMazeState {
  const CreativeMazeState();
}

class CreativeMazeInitial extends CreativeMazeState {
  const CreativeMazeInitial();
}

class CreativeMazeLoading extends CreativeMazeState {
  const CreativeMazeLoading();
}

class CreativeMazeError extends CreativeMazeState {
  final String message;
  const CreativeMazeError(this.message);
}

class CreativeMazeLoaded extends CreativeMazeState {
  final CreativeMazeLevelModel level;
  final CreativeMazeLevelConfig config;
  final int currentAttemptId;
  final int attemptNumber;
  final String currentAttemptStartedAt;
  final Duration elapsed;

  /// Number of coins the child has collected so far in this level.
  final int collectedCoins;

  /// Indexes of coins that have already been picked up (won't respawn).
  final Set<int> collectedCoinIndexes;

  const CreativeMazeLoaded({
    required this.level,
    required this.config,
    required this.currentAttemptId,
    required this.attemptNumber,
    required this.currentAttemptStartedAt,
    this.elapsed = Duration.zero,
    this.collectedCoins = 0,
    this.collectedCoinIndexes = const {},
  });

  CreativeMazeLoaded copyWith({
    CreativeMazeLevelModel? level,
    CreativeMazeLevelConfig? config,
    int? currentAttemptId,
    int? attemptNumber,
    String? currentAttemptStartedAt,
    Duration? elapsed,
    int? collectedCoins,
    Set<int>? collectedCoinIndexes,
  }) {
    return CreativeMazeLoaded(
      level: level ?? this.level,
      config: config ?? this.config,
      currentAttemptId: currentAttemptId ?? this.currentAttemptId,
      attemptNumber: attemptNumber ?? this.attemptNumber,
      currentAttemptStartedAt:
      currentAttemptStartedAt ?? this.currentAttemptStartedAt,
      elapsed: elapsed ?? this.elapsed,
      collectedCoins: collectedCoins ?? this.collectedCoins,
      collectedCoinIndexes: collectedCoinIndexes ?? this.collectedCoinIndexes,
    );
  }
}

/// Emitted when the ball reaches the end point. Carries the completion time so
/// the complete screen can show the child how long they took.
class CreativeMazeComplete extends CreativeMazeState {
  final Duration completionTime;
  final int coinsCollected;
  const CreativeMazeComplete({
    required this.completionTime,
    this.coinsCollected = 0,
  });
}
