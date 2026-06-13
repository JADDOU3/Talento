import 'mirror_mind_choice_model.dart';

enum MirrorMindChallengeType {
  simpleReflection,      // Level 1
  mirrorSequence,        // Level 2
  directionReflection,   // Level 3
  symmetryCompletion,    // Level 4
  connectDotsMemory,     // Level 5
  memorySequence,        // Level 6
  masterReflection,      // Level 7
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

  // Level 3 + Level 6
  final List<String> sequence;
  final List<String> expectedNext;

  // Level 4
  final String? shape;
  final String? axis;
  final String? missingSide;

  // Level 5
  final String? drawMode;
  final bool closed;

  // Level 7
  final String? mode;
  final List<String> items;
  final String? prompt;
  final Map<String, String> mapping;

  final List<MirrorMindChoiceModel> choices;

  const MirrorMindChallengeModel({
    required this.challengeId,
    required this.type,
    this.target,
    this.left = const [],
    this.expectedRight = const [],
    this.sequence = const [],
    this.expectedNext = const [],
    this.shape,
    this.axis,
    this.missingSide,
    this.drawMode,
    this.closed = false,
    this.mode,
    this.items = const [],
    this.prompt,
    this.mapping = const {},
    this.choices = const [],
  });

  List<String> get originalSideIcons {
    if (target != null && target!.isNotEmpty) return [target!];
    if (left.isNotEmpty) return left;
    if (sequence.isNotEmpty) return sequence;
    if (shape != null && shape!.isNotEmpty) return [shape!];
    if (items.isNotEmpty) return items;
    if (prompt != null && prompt!.isNotEmpty) return [prompt!];
    return <String>[];
  }

  List<String> get correctIcons {
    for (final choice in choices) {
      if (choice.isCorrect) return choice.displayIcons;
    }

    if (expectedRight.isNotEmpty) return expectedRight;
    if (expectedNext.isNotEmpty) return expectedNext;
    if (target != null && target!.isNotEmpty) return [target!];
    if (shape != null && shape!.isNotEmpty) return [shape!];

    final mappedPrompt = mapping[prompt];
    if (mappedPrompt != null && mappedPrompt.isNotEmpty) {
      return [mappedPrompt];
    }

    return <String>[];
  }

  bool get hasChoices => choices.isNotEmpty;

  bool get isVerticalAxis => (axis ?? '').toLowerCase() == 'vertical';

  bool get isHorizontalAxis => (axis ?? '').toLowerCase() == 'horizontal';

  bool get isMissingLeft => (missingSide ?? '').toLowerCase() == 'left';

  bool get isMissingRight => (missingSide ?? '').toLowerCase() == 'right';

  bool get isReflectionMode => (mode ?? '').toLowerCase() == 'reflection';

  bool get isSequenceReflectionMode =>
      (mode ?? '').toLowerCase() == 'sequence_reflection';

  bool get isSizeReflectionMode =>
      (mode ?? '').toLowerCase() == 'size_reflection';

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
    String? shape,
    String? axis,
    String? missingSide,
    String? drawMode,
    bool? closed,
    String? mode,
    List<String>? items,
    String? prompt,
    Map<String, String>? mapping,
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
      shape: shape ?? this.shape,
      axis: axis ?? this.axis,
      missingSide: missingSide ?? this.missingSide,
      drawMode: drawMode ?? this.drawMode,
      closed: closed ?? this.closed,
      mode: mode ?? this.mode,
      items: items ?? this.items,
      prompt: prompt ?? this.prompt,
      mapping: mapping ?? this.mapping,
      choices: choices ?? this.choices,
    );
  }

  factory MirrorMindChallengeModel.fromMergedMeta(
      int challengeId,
      Map<String, dynamic> meta,
      ) {
    final choices = _parseChoices(meta['choices']);

    // Level 7 — Master Reflection
    // Must be checked before sequence because some master modes may contain items/sequences.
    if (meta.containsKey('mode')) {
      return MirrorMindChallengeModel(
        challengeId: challengeId,
        type: MirrorMindChallengeType.masterReflection,
        mode: (meta['mode'] ?? '').toString(),
        items: _parseStringList(meta['items']),
        prompt: meta['prompt']?.toString(),
        mapping: _parseStringMap(meta['mapping']),
        choices: choices,
      );
    }

    // Level 5 — Connect the Dots Memory
    if (meta.containsKey('drawMode')) {
      return MirrorMindChallengeModel(
        challengeId: challengeId,
        type: MirrorMindChallengeType.connectDotsMemory,
        drawMode: (meta['drawMode'] ?? '').toString(),
        shape: meta['shape']?.toString(),
        closed: meta['closed'] == true,
        choices: choices,
      );
    }

    // Level 4 — Symmetry Completion
    if (meta.containsKey('shape') && meta.containsKey('missingSide')) {
      return MirrorMindChallengeModel(
        challengeId: challengeId,
        type: MirrorMindChallengeType.symmetryCompletion,
        shape: meta['shape']?.toString(),
        axis: meta['axis']?.toString(),
        missingSide: meta['missingSide']?.toString(),
        choices: choices,
      );
    }

    // Level 1 — Simple Reflection
    if (meta.containsKey('target')) {
      return MirrorMindChallengeModel(
        challengeId: challengeId,
        type: MirrorMindChallengeType.simpleReflection,
        target: (meta['target'] ?? '').toString(),
        choices: choices,
      );
    }

    // Level 2 — Mirror Sequence
    if (meta.containsKey('left')) {
      return MirrorMindChallengeModel(
        challengeId: challengeId,
        type: MirrorMindChallengeType.mirrorSequence,
        left: _parseStringList(meta['left']),
        expectedRight: _parseFlexibleStringList(meta['expectedRight']),
        choices: choices,
      );
    }

    // Level 3 + Level 6 both may contain "sequence".
    // Level 3 from Part 1 usually has "expectedNext".
    // Level 6 memory sequence has sequence only, and the correct reversed order comes from choices.
    if (meta.containsKey('sequence')) {
      final expectedNext = _parseFlexibleStringList(meta['expectedNext']);

      return MirrorMindChallengeModel(
        challengeId: challengeId,
        type: expectedNext.isNotEmpty
            ? MirrorMindChallengeType.directionReflection
            : MirrorMindChallengeType.memorySequence,
        sequence: _parseStringList(meta['sequence']),
        expectedNext: expectedNext,
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
    return value
        .map((item) => item.toString())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static List<String> _parseFlexibleStringList(dynamic value) {
    if (value == null) return <String>[];

    if (value is List) {
      return value
          .map((item) => item.toString())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    if (value.toString().isNotEmpty) {
      return [value.toString()];
    }

    return <String>[];
  }

  static Map<String, String> _parseStringMap(dynamic value) {
    if (value is! Map) return <String, String>{};

    return value.map(
          (key, mapValue) => MapEntry(
        key.toString(),
        mapValue.toString(),
      ),
    );
  }
}