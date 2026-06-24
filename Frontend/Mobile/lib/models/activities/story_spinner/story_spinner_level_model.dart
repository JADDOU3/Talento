import 'dart:convert';

enum StorySpinnerChallengeType {
  spin,
  voice,
  unknown,
}

class StorySpinnerLevelModel {
  final int id;
  final int levelNumber;
  final String name;
  final List<StorySpinnerChallengeModel> challenges;

  const StorySpinnerLevelModel({
    required this.id,
    required this.levelNumber,
    required this.name,
    required this.challenges,
  });

  List<StorySpinnerChallengeModel> get spinChallenges {
    final result = challenges
        .where((challenge) => challenge.type == StorySpinnerChallengeType.spin)
        .toList();

    result.sort((a, b) => _stepOrder(a.step).compareTo(_stepOrder(b.step)));
    return result;
  }

  StorySpinnerChallengeModel? get voiceChallenge {
    for (final challenge in challenges) {
      if (challenge.type == StorySpinnerChallengeType.voice) {
        return challenge;
      }
    }

    return null;
  }

  StorySpinnerChallengeModel? spinChallengeForStep(String step) {
    final normalizedStep = step.trim().toLowerCase();

    for (final challenge in spinChallenges) {
      if (challenge.step.trim().toLowerCase() == normalizedStep) {
        return challenge;
      }
    }

    return null;
  }

  factory StorySpinnerLevelModel.fromJson(Map<String, dynamic> json) {
    final images = _extractImages(json);
    final challenges = _buildChallengesFromImages(images);

    return StorySpinnerLevelModel(
      id: _parseInt(json['id']),
      levelNumber: _parseInt(json['levelNumber']),
      name: (json['name'] ?? json['title'] ?? '').toString(),
      challenges: challenges,
    );
  }

  static List<StorySpinnerLevelModel> listFromPageResponse(
      Map<String, dynamic> json,
      ) {
    final content = json['content'];

    if (content is! List) return <StorySpinnerLevelModel>[];

    return content
        .whereType<Map>()
        .map(
          (item) => StorySpinnerLevelModel.fromJson(
        Map<String, dynamic>.from(item),
      ),
    )
        .toList();
  }

  static List<Map<String, dynamic>> _extractImages(Map<String, dynamic> json) {
    final candidates = [
      json['images'],
      json['levelImages'],
      json['media'],
      json['items'],
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        final result = candidate
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

        if (result.isNotEmpty) return result;
      }
    }

    final directMeta = _parseMeta(json['meta']);
    if (directMeta.isNotEmpty) {
      return [
        {
          'meta': directMeta,
          'sortOrder': json['sortOrder'] ?? 0,
        },
      ];
    }

    return <Map<String, dynamic>>[];
  }

  static List<StorySpinnerChallengeModel> _buildChallengesFromImages(
      List<Map<String, dynamic>> images,
      ) {
    final sortedImages = [...images];

    sortedImages.sort((a, b) {
      final aOrder = _parseInt(a['sortOrder']);
      final bOrder = _parseInt(b['sortOrder']);
      return aOrder.compareTo(bOrder);
    });

    final groupedMeta = <int, Map<String, dynamic>>{};

    for (final image in sortedImages) {
      final meta = _parseMeta(image['meta']);

      if (meta.isEmpty) continue;

      final challengeId = _parseInt(meta['challengeId']);

      if (challengeId == 0) continue;

      groupedMeta.putIfAbsent(challengeId, () => <String, dynamic>{});
      groupedMeta[challengeId]!.addAll(meta);
    }

    final challengeIds = groupedMeta.keys.toList()..sort();

    return challengeIds
        .map(
          (challengeId) => StorySpinnerChallengeModel.fromMergedMeta(
        challengeId: challengeId,
        meta: groupedMeta[challengeId]!,
      ),
    )
        .where(
          (challenge) => challenge.type != StorySpinnerChallengeType.unknown,
    )
        .toList();
  }

  static int _stepOrder(String step) {
    switch (step.trim().toLowerCase()) {
      case 'character':
        return 0;
      case 'event':
        return 1;
      case 'place':
        return 2;
      default:
        return 99;
    }
  }

  static Map<String, dynamic> _parseMeta(dynamic value) {
    if (value == null) return <String, dynamic>{};

    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    if (value is String && value.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(value);

        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {
        return <String, dynamic>{};
      }
    }

    return <String, dynamic>{};
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}

class StorySpinnerChallengeModel {
  final int challengeId;
  final StorySpinnerChallengeType type;
  final String step;
  final String prompt;
  final String question;
  final List<StorySpinnerChoiceModel> choices;

  const StorySpinnerChallengeModel({
    required this.challengeId,
    required this.type,
    required this.step,
    required this.prompt,
    required this.question,
    required this.choices,
  });

  List<String> get icons {
    final result = choices
        .map((choice) => choice.icon)
        .where((icon) => icon.trim().isNotEmpty)
        .toSet()
        .toList();

    return result;
  }

  bool get isCharacter => step.trim().toLowerCase() == 'character';

  bool get isEvent => step.trim().toLowerCase() == 'event';

  bool get isPlace => step.trim().toLowerCase() == 'place';

  factory StorySpinnerChallengeModel.fromMergedMeta({
    required int challengeId,
    required Map<String, dynamic> meta,
  }) {
    final typeText = (meta['type'] ?? '').toString().trim().toLowerCase();
    final type = _parseChallengeType(typeText);

    return StorySpinnerChallengeModel(
      challengeId: challengeId,
      type: type,
      step: (meta['step'] ?? '').toString(),
      prompt: (meta['prompt'] ?? '').toString(),
      question: (meta['question'] ?? '').toString(),
      choices: _parseChoices(meta['choices']),
    );
  }

  static StorySpinnerChallengeType _parseChallengeType(String type) {
    switch (type) {
      case 'spin':
        return StorySpinnerChallengeType.spin;
      case 'voice':
        return StorySpinnerChallengeType.voice;
      default:
        return StorySpinnerChallengeType.unknown;
    }
  }

  static List<StorySpinnerChoiceModel> _parseChoices(dynamic value) {
    if (value is! List) return <StorySpinnerChoiceModel>[];

    return value
        .whereType<Map>()
        .map(
          (item) => StorySpinnerChoiceModel.fromJson(
        Map<String, dynamic>.from(item),
      ),
    )
        .where((choice) => choice.icon.trim().isNotEmpty)
        .toList();
  }
}

class StorySpinnerChoiceModel {
  final String icon;
  final bool isCorrect;

  const StorySpinnerChoiceModel({
    required this.icon,
    required this.isCorrect,
  });

  factory StorySpinnerChoiceModel.fromJson(Map<String, dynamic> json) {
    return StorySpinnerChoiceModel(
      icon: (json['icon'] ?? '').toString(),
      isCorrect: json['isCorrect'] == true,
    );
  }
}