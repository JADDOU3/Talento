import 'mirror_mind_choice_model.dart';

enum MirrorMindChallengeType {
  targetIdentification,
  mirrorSequence,
  arrowMirroring,
  unknown,
}

class MirrorMindChallengeModel {
  final int challengeId;
  final MirrorMindChallengeType type;

  // Level 1
  final String? target;

  // Level 2
  final List<String> left;
  final String? expectedRight;

  // Level 3
  final List<String> sequence;
  final String? expectedNext;

  final List<MirrorMindChoiceModel> choices;

  const MirrorMindChallengeModel({
    required this.challengeId,
    required this.type,
    this.target,
    this.left = const [],
    this.expectedRight,
    this.sequence = const [],
    this.expectedNext,
    this.choices = const [],
  });

  String? get correctIcon {
    for (final choice in choices) {
      if (choice.isCorrect) return choice.icon;
    }

    return expectedRight ?? expectedNext ?? target;
  }

  bool get hasChoices => choices.isNotEmpty;

  bool isCorrectChoice(String iconName) {
    return choices.any(
          (choice) => choice.icon == iconName && choice.isCorrect,
    );
  }

  MirrorMindChallengeModel copyWith({
    int? challengeId,
    MirrorMindChallengeType? type,
    String? target,
    List<String>? left,
    String? expectedRight,
    List<String>? sequence,
    String? expectedNext,
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
        type: MirrorMindChallengeType.targetIdentification,
        target: (meta['target'] ?? '').toString(),
        choices: choices,
      );
    }

    if (meta.containsKey('left')) {
      return MirrorMindChallengeModel(
        challengeId: challengeId,
        type: MirrorMindChallengeType.mirrorSequence,
        left: _parseStringList(meta['left']),
        expectedRight: meta['expectedRight']?.toString(),
        choices: choices,
      );
    }

    if (meta.containsKey('sequence')) {
      return MirrorMindChallengeModel(
        challengeId: challengeId,
        type: MirrorMindChallengeType.arrowMirroring,
        sequence: _parseStringList(meta['sequence']),
        expectedNext: meta['expectedNext']?.toString(),
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
}