class KitModel {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final String type;
  final String mindset;
  final List<String> kitItems;
  final double rating;
  final int age;

  const KitModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.type,
    required this.mindset,
    required this.kitItems,
    required this.rating,
    required this.age,
  });

  factory KitModel.fromJson(Map<String, dynamic> json) {
    return KitModel(
      id: _parseInt(json['id']),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      imageUrl: (json['imageURL'] ??
          json['imageUrl'] ??
          json['image'] ??
          json['image_path'] ??
          '')
          .toString(),
      type: (json['type'] ?? '').toString(),
      mindset: (json['mindset'] ?? '').toString(),
      rating: _parseDouble(json['rating']),
      age: _parseInt(json['age']),
      kitItems: _parseKitItems(
        json['kitItems'] ?? json['items'] ?? json['kit_items'],
      ),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  static List<String> _parseKitItems(dynamic value) {
    if (value is List) {
      return value.map((item) {
        if (item is String) return item;
        if (item is Map<String, dynamic>) {
          return (item['name'] ??
              item['title'] ??
              item['itemName'] ??
              item['description'] ??
              item.toString())
              .toString();
        }
        return item.toString();
      }).toList();
    }
    return <String>[];
  }
}