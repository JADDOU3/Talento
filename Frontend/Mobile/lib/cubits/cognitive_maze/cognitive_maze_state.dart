import 'package:flutter/material.dart';

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

  /// Colors collected so far — only meaningful for star-collect levels.
  final Set<Color> collectedColors;

  const CognitiveMazeLoaded({
    required this.level,
    required this.config,
    required this.elapsed,
    this.collectedColors = const {},
  });
}

class CognitiveMazeWrongAnswer extends CognitiveMazeState {
  final CognitiveMazeLevel level;
  final CognitiveMazeLevelConfig config;
  final Duration elapsed;
  final Set<Color> collectedColors;

  const CognitiveMazeWrongAnswer({
    required this.level,
    required this.config,
    required this.elapsed,
    this.collectedColors = const {},
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