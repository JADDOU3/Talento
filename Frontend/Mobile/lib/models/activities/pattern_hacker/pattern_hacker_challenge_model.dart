import 'pattern_hacker_choice_model.dart';

/// A single Pattern Hacker challenge.
///
/// A challenge is built by merging the meta of two images that share the same
/// `challengeId`:
///   - The TARGET image provides `sequence` + `expectedNext`.
///   - The CHOICE image provides `choices`.
class PatternHackerChallengeModel {
  final int challengeId;

  /// Icons shown in order before the blank slot.
  final List<String> sequence;

  /// The correct next icon name (from the TARGET meta).
  final String expectedNext;

  /// The tappable options shown under the sequence.
  final List<PatternHackerChoiceModel> choices;

  const PatternHackerChallengeModel({
    required this.challengeId,
    required this.sequence,
    required this.expectedNext,
    required this.choices,
  });

  /// A challenge is only playable if it has a sequence AND choices.
  bool get isValid => sequence.isNotEmpty && choices.isNotEmpty;

  /// Returns true if the given icon name is the correct answer.
  /// We trust the choice's own `isCorrect` flag first, then fall back to
  /// comparing against `expectedNext`.
  bool isCorrectIcon(String iconName) {
    for (final choice in choices) {
      if (choice.icon == iconName) {
        return choice.isCorrect;
      }
    }

    if (expectedNext.isNotEmpty) {
      return iconName == expectedNext;
    }

    return false;
  }

  factory PatternHackerChallengeModel.fromMergedMeta(
    int challengeId,
    Map<String, dynamic> meta,
  ) {
    return PatternHackerChallengeModel(
      challengeId: challengeId,
      sequence: _parseStringList(meta['sequence']),
      expectedNext: (meta['expectedNext'] ?? '').toString(),
      choices: _parseChoices(meta['choices']),
    );
  }

  static List<PatternHackerChoiceModel> _parseChoices(dynamic value) {
    if (value is! List) return <PatternHackerChoiceModel>[];

    final parsed = value
        .whereType<Map>()
        .map(
          (item) => PatternHackerChoiceModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .toList();

    // Shuffle once when the challenge is built so the correct answer is not
    // always in the same position.
    parsed.shuffle();

    return parsed;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is! List) return <String>[];
    return value.map((item) => item.toString()).toList();
  }
}
