import 'mirror_mind_choice_model.dart';

enum MirrorMindChallengeType {
  simpleReflection,
  mirrorSequence,
  directionReflection,
  unknown,
}

class MirrorMindChallengeModel {
  final int challengeId;
  final MirrorMindChallengeType type;

  // Level 1
  final String? target;

  // Level 2
  final List<String> left;
  final List<String> expectedRight;

  // Level 3
  final List<String> sequence;
  final List<String> expectedNext;

  final List<MirrorMindChoiceModel> choices;

  const MirrorMindChallengeModel({
    required this.challengeId,
    required this.type,
    this.target,
    this.left = const [],
    this.expectedRight = const [],
    this.sequence = const [],
    this.expectedNext = const [],
    this.choices = const [],
  });

  List<String> get originalSideIcons {
    if (target != null && target!.isNotEmpty) return [target!];
    if (left.isNotEmpty) return left;
    if (sequence.isNotEmpty) return sequence;
    return <String>[];
  }

  List<String> get correctIcons {
    for (final choice in choices) {
      if (choice.isCorrect) return choice.displayIcons;
    }

    if (expectedRight.isNotEmpty) return expectedRight;
    if (expectedNext.isNotEmpty) return expectedNext;
    if (target != null && target!.isNotEmpty) return [target!];

    return <String>[];
  }

  bool get hasChoices => choices.isNotEmpty;

  bool isCorrectChoiceIndex(int choiceIndex) {
    if (choiceIndex < 0 || choiceIndex >= choices.length) return false;
    return choices[choiceIndex].isCorrect;
  }

  MirrorMindChallengeModel copyWith({
    int? challengeId,
    MirrorMindChallengeType? type,
    String? target,
    List<String>? left,
    List<String>? expectedRight,
    List<String>? sequence,
    List<String>? expectedNext,
    List<MirrorMindChoiceModel>? choices,
  }) {
    return MirrorMindChallengeModel(
      challengeId: challengeId ?? this.challengeId,
      type: type ?? this.type,
      target: target ?? this.target,
      left: left ?? this.left,
      expectedRight: expectedRight ?? this.expectedRight,
      sequence: sequence ?? this.sequence,
      expectedNext: expectedNext ?? this.expectedNext,
      choices: choices ?? this.choices,
    );
  }

  factory MirrorMindChallengeModel.fromMergedMeta(
      int challengeId,
      Map<String, dynamic> meta,
      ) {
    final choices = _parseChoices(meta['choices']);

    if (meta.containsKey('target')) {
      return MirrorMindChallengeModel(
        challengeId: challengeId,
        type: MirrorMindChallengeType.simpleReflection,
        target: (meta['target'] ?? '').toString(),
        choices: choices,
      );
    }

    if (meta.containsKey('left')) {
      return MirrorMindChallengeModel(
        challengeId: challengeId,
        type: MirrorMindChallengeType.mirrorSequence,
        left: _parseStringList(meta['left']),
        expectedRight: _parseFlexibleStringList(meta['expectedRight']),
        choices: choices,
      );
    }

    if (meta.containsKey('sequence')) {
      return MirrorMindChallengeModel(
        challengeId: challengeId,
        type: MirrorMindChallengeType.directionReflection,
        sequence: _parseStringList(meta['sequence']),
        expectedNext: _parseFlexibleStringList(meta['expectedNext']),
        choices: choices,
      );
    }

    return MirrorMindChallengeModel(
      challengeId: challengeId,
      type: MirrorMindChallengeType.unknown,
      choices: choices,
    );
  }

  static List<MirrorMindChoiceModel> _parseChoices(dynamic value) {
    if (value is! List) return <MirrorMindChoiceModel>[];

    return value
        .whereType<Map>()
        .map(
          (item) => MirrorMindChoiceModel.fromJson(
        Map<String, dynamic>.from(item),
      ),
    )
        .toList();
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is! List) return <String>[];
    return value.map((item) => item.toString()).toList();
  }

  static List<String> _parseFlexibleStringList(dynamic value) {
    if (value == null) return <String>[];

    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }

    if (value.toString().isNotEmpty) {
      return [value.toString()];
    }

    return <String>[];
  }
}