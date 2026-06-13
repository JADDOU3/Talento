import '../../models/color_lab/color_lab_models.dart';

abstract class ColorLabState {
  const ColorLabState();
}

class ColorLabInitial extends ColorLabState {
  const ColorLabInitial();
}

class ColorLabLoading extends ColorLabState {
  const ColorLabLoading();
}

class ColorLabError extends ColorLabState {
  final String message;
  const ColorLabError(this.message);
}

/// Active gameplay state — the screen rebuilds from this.
class ColorLabLoaded extends ColorLabState {
  final ColorLabLevel level;
  final int currentChallengeIndex;
  final List<ColorLabPaletteColor> selectedColors;
  final int currentAttemptId;
  final int attemptNumber;
  final Duration elapsed;
  final int undosUsed;
  final int maxUndos;

  const ColorLabLoaded({
    required this.level,
    required this.currentChallengeIndex,
    required this.selectedColors,
    required this.currentAttemptId,
    required this.attemptNumber,
    required this.elapsed,
    this.undosUsed = 0,
    this.maxUndos = 3,
  });

  /// Remaining undos for the current challenge.
  int get undosLeft => (maxUndos - undosUsed).clamp(0, maxUndos);

  /// The current TARGET challenge.
  ColorLabImage get currentChallenge => level.challenges[currentChallengeIndex];

  /// The palette image for this level.
  ColorLabImage? get palette => level.paletteImage;

  ColorLabLoaded copyWith({
    ColorLabLevel? level,
    int? currentChallengeIndex,
    List<ColorLabPaletteColor>? selectedColors,
    int? currentAttemptId,
    int? attemptNumber,
    Duration? elapsed,
    int? undosUsed,
    int? maxUndos,
  }) {
    return ColorLabLoaded(
      level: level ?? this.level,
      currentChallengeIndex:
          currentChallengeIndex ?? this.currentChallengeIndex,
      selectedColors: selectedColors ?? this.selectedColors,
      currentAttemptId: currentAttemptId ?? this.currentAttemptId,
      attemptNumber: attemptNumber ?? this.attemptNumber,
      elapsed: elapsed ?? this.elapsed,
      undosUsed: undosUsed ?? this.undosUsed,
      maxUndos: maxUndos ?? this.maxUndos,
    );
  }
}

/// Briefly shown after submit — correct or wrong feedback.
class ColorLabChallengeResult extends ColorLabState {
  final bool isCorrect;
  final ColorLabLoaded snapshot; // so UI can keep showing the game behind feedback
  const ColorLabChallengeResult({
    required this.isCorrect,
    required this.snapshot,
  });
}

/// All challenges in all levels finished.
class ColorLabLevelComplete extends ColorLabState {
  const ColorLabLevelComplete();
}
