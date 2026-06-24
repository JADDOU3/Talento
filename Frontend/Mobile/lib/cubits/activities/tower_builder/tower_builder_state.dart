import 'package:equatable/equatable.dart';

import '../../../models/activities/tower_builder/tower_builder_level_model.dart';

abstract class TowerBuilderState extends Equatable {
  const TowerBuilderState();

  @override
  List<Object?> get props => [];
}

class TowerBuilderInitial extends TowerBuilderState {
  const TowerBuilderInitial();
}

class TowerBuilderLoading extends TowerBuilderState {
  const TowerBuilderLoading();
}

class TowerBuilderError extends TowerBuilderState {
  final String message;

  const TowerBuilderError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

class TowerBuilderLoaded extends TowerBuilderState {
  final TowerBuilderLevelModel level;
  final int currentAttemptId;
  final int attemptNumber;
  final Duration elapsed;

  const TowerBuilderLoaded({
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

class TowerBuilderChecklistResult extends TowerBuilderState {
  final bool allChecked;

  const TowerBuilderChecklistResult({
    required this.allChecked,
  });

  @override
  List<Object?> get props => [allChecked];
}

class TowerBuilderLevelComplete extends TowerBuilderState {
  const TowerBuilderLevelComplete();
}