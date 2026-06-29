import 'mindset_model.dart';

class KitModel {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final List<String> imageUrls;
  final String type;

  /// Kept as a String for old screens/widgets that still read kit.mindset.
  /// New code should prefer mindsetData because the API can return mindset as an object or null.
  final String mindset;
  final MindsetModel? mindsetData;

  final List<String> kitItems;
  final double rating;
  final int age;

  const KitModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.imageUrls,
    required this.type,
    required this.mindset,
    required this.mindsetData,
    required this.kitItems,
    required this.rating,
    required this.age,
  });

  factory KitModel.fromJson(Map<String, dynamic> json) {
    final mindsetData = _parseMindset(json['mindset']);

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
      imageUrls: _parseStringList(json['imageURLs'] ?? json['imageUrls']),
      type: (json['type'] ?? '').toString(),
      mindset: mindsetData?.name ?? _parseMindsetText(json['mindset']),
      mindsetData: mindsetData,
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

  static MindsetModel? _parseMindset(dynamic value) {
    if (value is Map<String, dynamic>) {
      return MindsetModel.fromJson(value);
    }
    return null;
  }

  static String _parseMindsetText(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map<String, dynamic>) {
      return (value['name'] ?? '').toString();
    }
    return value.toString();
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item?.toString() ?? '')
          .where((item) => item.trim().isNotEmpty)
          .toList();
    }
    return <String>[];
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
