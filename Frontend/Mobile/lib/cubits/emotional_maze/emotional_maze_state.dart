import '../../../models/activities/emotional_maze/emotional_maze_models.dart';
import '../../activities/emotional_maze/config/emotional_maze_level_config.dart';

abstract class EmotionalMazeState {
  const EmotionalMazeState();
}

class EmotionalMazeInitial extends EmotionalMazeState {
  const EmotionalMazeInitial();
}

class EmotionalMazeLoading extends EmotionalMazeState {
  const EmotionalMazeLoading();
}

class EmotionalMazeLoaded extends EmotionalMazeState {
  final EmotionalMazeLevel level;
  final MazeLevelConfig config;
  final Duration elapsed;

  const EmotionalMazeLoaded({
    required this.level,
    required this.config,
    required this.elapsed,
  });
}

class EmotionalMazeComplete extends EmotionalMazeState {
  final EmotionalMazeLevel level;
  final Duration elapsed;

  const EmotionalMazeComplete({required this.level, required this.elapsed});
}

class EmotionalMazeError extends EmotionalMazeState {
  final String message;

  const EmotionalMazeError(this.message);
}