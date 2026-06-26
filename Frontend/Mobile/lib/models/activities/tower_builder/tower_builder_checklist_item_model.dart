class TowerBuilderChecklistItemModel {
  final String id;
  final String text;

  const TowerBuilderChecklistItemModel({
    required this.id,
    required this.text,
  });

  factory TowerBuilderChecklistItemModel.fromJson(Map<String, dynamic> json) {
    return TowerBuilderChecklistItemModel(
      id: (json['id'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
    );
  }
}