import '../../../activities/bodily_maze/config/bodily_maze_level_config.dart';
import '../../../models/activities/bodily_maze/bodily_maze_models.dart';

abstract class BodilyMazeState {
  const BodilyMazeState();
}

class BodilyMazeInitial extends BodilyMazeState {
  const BodilyMazeInitial();
}

class BodilyMazeLoading extends BodilyMazeState {
  const BodilyMazeLoading();
}

class BodilyMazeError extends BodilyMazeState {
  final String message;
  const BodilyMazeError(this.message);
}

/// Active gameplay.
class BodilyMazeLoaded extends BodilyMazeState {
  final BodilyMazeLevel level;
  final MazeLevelConfig config;
  final int currentAttemptId;
  final int attemptNumber;
  final Duration elapsed;

  const BodilyMazeLoaded({
    required this.level,
    required this.config,
    required this.currentAttemptId,
    required this.attemptNumber,
    this.elapsed = Duration.zero,
  });

  BodilyMazeLoaded copyWith({
    int? currentAttemptId,
    int? attemptNumber,
    Duration? elapsed,
  }) {
    return BodilyMazeLoaded(
      level: level,
      config: config,
      currentAttemptId: currentAttemptId ?? this.currentAttemptId,
      attemptNumber: attemptNumber ?? this.attemptNumber,
      elapsed: elapsed ?? this.elapsed,
    );
  }
}

/// Ball fell into a hole — brief feedback, then the screen resets the ball
/// to the start point. The game is NOT exited.
class BodilyMazeFailed extends BodilyMazeState {
  final int currentAttemptId;
  final int attemptNumber;
  const BodilyMazeFailed({
    required this.currentAttemptId,
    required this.attemptNumber,
  });
}

/// Ball reached the end — level complete.
class BodilyMazeComplete extends BodilyMazeState {
  const BodilyMazeComplete();
}
