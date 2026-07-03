import '../../../models/activities/cognitive_maze/cognitive_maze_models.dart';
import '../../activities/cognitive_maze/config/cognitive_maze_level_config.dart';

abstract class CognitiveMazeState {
  const CognitiveMazeState();
}

class CognitiveMazeInitial extends CognitiveMazeState {
  const CognitiveMazeInitial();
}

class CognitiveMazeLoading extends CognitiveMazeState {
  const CognitiveMazeLoading();
}

class CognitiveMazeLoaded extends CognitiveMazeState {
  final CognitiveMazeLevel level;
  final CognitiveMazeLevelConfig config;
  final Duration elapsed;

  const CognitiveMazeLoaded({
    required this.level,
    required this.config,
    required this.elapsed,
  });
}

/// Transient state: emitted the instant the ball lands on an incorrect
/// endpoint. The screen's playfield keeps rendering from the last
/// CognitiveMazeLoaded (same fallback pattern used for Complete), while a
/// BlocListener reacts to this specific state to show a one-off "wrong
/// answer, try again" toast. The ball itself is already reset to start by
/// the game engine before this is even emitted.
class CognitiveMazeWrongAnswer extends CognitiveMazeState {
  final CognitiveMazeLevel level;
  final CognitiveMazeLevelConfig config;
  final Duration elapsed;

  const CognitiveMazeWrongAnswer({
    required this.level,
    required this.config,
    required this.elapsed,
  });
}

class CognitiveMazeComplete extends CognitiveMazeState {
  final CognitiveMazeLevel level;
  final Duration elapsed;

  const CognitiveMazeComplete({required this.level, required this.elapsed});
}

class CognitiveMazeError extends CognitiveMazeState {
  final String message;

  const CognitiveMazeError(this.message);
}