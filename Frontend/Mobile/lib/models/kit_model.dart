class KitModel {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final String type;
  final String mindset;
  final List<String> kitItems;

  const KitModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.type,
    required this.mindset,
    required this.kitItems,
  });

  factory KitModel.fromJson(Map<String, dynamic> json) {
    return KitModel(
      id: _parseInt(json['id']),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      imageUrl: (json['imageURL'] ?? json['imageUrl'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      mindset: (json['mindset'] ?? '').toString(),
      kitItems: _parseKitItems(json['kitItems']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }

  static List<String> _parseKitItems(dynamic value) {
    if (value is List) {
      return value.map((item) {
        if (item is String) return item;
        if (item is Map<String, dynamic>) {
          return (item['name'] ?? item['title'] ?? item['itemName'] ?? item.toString()).toString();
        }
        return item.toString();
      }).toList();
    }
    return <String>[];
  }
}