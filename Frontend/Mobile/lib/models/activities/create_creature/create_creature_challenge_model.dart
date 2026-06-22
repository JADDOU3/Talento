import 'create_creature_choice_model.dart';

enum CreateCreatureChallengeType {
  selection,
  voice,
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

  const CreateCreatureChallengeModel({
    required this.challengeId,
    required this.type,
    required this.step,
    required this.part,
    required this.prompt,
    required this.question,
    required this.choices,
  });

  factory CreateCreatureChallengeModel.fromMergedMeta(
      int challengeId,
      Map<String, dynamic> meta,
      List<CreateCreatureChoiceModel> choices,
      ) {
    final type = meta['type'] == 'voice'
        ? CreateCreatureChallengeType.voice
        : meta['type'] == 'selection'
        ? CreateCreatureChallengeType.selection
        : CreateCreatureChallengeType.unknown;

    return CreateCreatureChallengeModel(
      challengeId: challengeId,
      type: type,
      step: (meta['step'] ?? '').toString(),
      part: (meta['part'] ?? '').toString(),
      prompt: (meta['prompt'] ?? '').toString(),
      question: (meta['question'] ?? '').toString(),
      choices: choices,
    );
  }
}