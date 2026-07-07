
import 'create_creature_choice_model..dart';

enum CreateCreatureChallengeType {
  selection,
  voice,
  preview,
  unknown,
}

class CreateCreatureChallengeModel {
  final int challengeId;
  final CreateCreatureChallengeType type;
  final String step;
  final String part;
  final String prompt;
  final String question;
  final List<CreateCreatureChoiceModel> choices;
  final List<Map<String, dynamic>> lookup;

  const CreateCreatureChallengeModel({
    required this.challengeId,
    required this.type,
    required this.step,
    required this.part,
    required this.prompt,
    required this.question,
    required this.choices,
    this.lookup = const [],
  });

  factory CreateCreatureChallengeModel.fromMergedMeta(
      int challengeId,
      List<Map<String, dynamic>> metaList,
      List<CreateCreatureChoiceModel> choices,
      ) {
    final primary = metaList.first;

    final type = primary['type'] == 'voice'
        ? CreateCreatureChallengeType.voice
        : primary['type'] == 'selection'
        ? CreateCreatureChallengeType.selection
        : primary['type'] == 'preview'
        ? CreateCreatureChallengeType.preview
        : CreateCreatureChallengeType.unknown;


    final legacyLookup = metaList
        .expand((m) => _parseLookup(m['lookup']))
        .toList();


    final perImageLookup = metaList
        .where((m) =>
    m['gender'] != null &&
        m['hairColor'] != null &&
        m['_imageUrl'] != null &&
        (m['_imageUrl'] as String).isNotEmpty)
        .map((m) => <String, dynamic>{
      'gender': m['gender'],
      'hairColor': m['hairColor'],
      's3Key': m['_imageS3Key'],
      'url': m['_imageUrl'],
    })
        .toList();

    final combinedLookup =
    perImageLookup.isNotEmpty ? perImageLookup : legacyLookup;

    return CreateCreatureChallengeModel(
      challengeId: challengeId,
      type: type,
      step: (primary['step'] ?? '').toString(),
      part: (primary['part'] ?? '').toString(),
      prompt: (primary['prompt'] ?? '').toString(),
      question: (primary['question'] ?? '').toString(),
      choices: choices,
      lookup: combinedLookup,
    );
  }

  static List<Map<String, dynamic>> _parseLookup(dynamic value) {
    if (value is! List) return const [];

    return value
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList();
  }
}