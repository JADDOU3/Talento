class MindsetModel {
  final int id;
  final String name;

  const MindsetModel({
    required this.id,
    required this.name,
  });

  factory MindsetModel.fromJson(Map<String, dynamic> json) {
    return MindsetModel(
      id: _parseInt(json['id']),
      name: (json['name'] ?? '').toString(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
