import 'package:equatable/equatable.dart';

import '../../../models/activities/shape_creator/shape_creator_level_model.dart';

abstract class ShapeCreatorState extends Equatable {
  const ShapeCreatorState();

  @override
  List<Object?> get props => [];
}

class ShapeCreatorInitial extends ShapeCreatorState {
  const ShapeCreatorInitial();
}

class ShapeCreatorLoading extends ShapeCreatorState {
  const ShapeCreatorLoading();
}

class ShapeCreatorError extends ShapeCreatorState {
  final String message;

  const ShapeCreatorError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

class ShapeCreatorLoaded extends ShapeCreatorState {
  final ShapeCreatorLevelModel level;
  final int currentAttemptId;
  final int attemptNumber;
  final Duration elapsed;

  const ShapeCreatorLoaded({
    required this.level,
    required this.currentAttemptId,
    required this.attemptNumber,
    required this.elapsed,
  });

  @override
  List<Object?> get props => [
    level,
    currentAttemptId,
    attemptNumber,
    elapsed,
  ];
}

class ShapeCreatorChecklistResult extends ShapeCreatorState {
  final bool allChecked;

  const ShapeCreatorChecklistResult({
    required this.allChecked,
  });

  @override
  List<Object?> get props => [allChecked];
}

class ShapeCreatorLevelComplete extends ShapeCreatorState {
  const ShapeCreatorLevelComplete();
}