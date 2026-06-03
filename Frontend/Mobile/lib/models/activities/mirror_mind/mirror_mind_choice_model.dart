class MirrorMindChoiceModel {
  final String icon;
  final bool isCorrect;

  const MirrorMindChoiceModel({
    required this.icon,
    required this.isCorrect,
  });

  factory MirrorMindChoiceModel.fromJson(Map<String, dynamic> json) {
    return MirrorMindChoiceModel(
      icon: (json['icon'] ?? '').toString(),
      isCorrect: json['isCorrect'] == true,
    );
  }
}