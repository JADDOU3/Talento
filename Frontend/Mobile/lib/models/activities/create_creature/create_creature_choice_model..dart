class CreateCreatureChoiceModel {
  final String icon;
  final bool isCorrect;

  const CreateCreatureChoiceModel({
    required this.icon,
    required this.isCorrect,
  });

  factory CreateCreatureChoiceModel.fromJson(Map<String, dynamic> json) {
    return CreateCreatureChoiceModel(
      icon: (json['icon'] ?? '').toString(),
      isCorrect: json['isCorrect'] == true,
    );
  }
}