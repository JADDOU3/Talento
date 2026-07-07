class TowerBuilderChecklistItemModel {
  final String id;
  final String text;
  final bool requiredForCompletion;

  const TowerBuilderChecklistItemModel({
    required this.id,
    required this.text,
    this.requiredForCompletion = true,
  });

  factory TowerBuilderChecklistItemModel.fromJson(Map<String, dynamic> json) {
    return TowerBuilderChecklistItemModel(
      id: (json['id'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
      requiredForCompletion: json['requiredForCompletion'] != false,
    );
  }
}