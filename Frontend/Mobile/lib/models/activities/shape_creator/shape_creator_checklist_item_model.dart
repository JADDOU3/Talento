class ShapeCreatorChecklistItemModel {
  final String id;
  final String text;

  const ShapeCreatorChecklistItemModel({
    required this.id,
    required this.text,
  });

  factory ShapeCreatorChecklistItemModel.fromJson(Map<String, dynamic> json) {
    return ShapeCreatorChecklistItemModel(
      id: (json['id'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
    );
  }
}