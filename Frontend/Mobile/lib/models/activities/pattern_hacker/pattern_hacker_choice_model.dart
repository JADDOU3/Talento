class PatternHackerChoiceModel {
  final String icon;
  final bool isCorrect;

  const PatternHackerChoiceModel({
    required this.icon,
    required this.isCorrect,
  });

  factory PatternHackerChoiceModel.fromJson(Map<String, dynamic> json) {
    return PatternHackerChoiceModel(
      icon: (json['icon'] ?? '').toString(),
      isCorrect: json['isCorrect'] == true,
    );
  }
}
