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
    final kitJson = _extractKitJson(json);
    final mindsetData = _parseMindset(kitJson['mindset']);

    final imageUrl = _parseFirstText([
      kitJson['imageURL'],
      kitJson['imageUrl'],
      kitJson['image'],
      kitJson['image_path'],
      kitJson['imageKey'],
      kitJson['coverImage'],
      kitJson['coverImageUrl'],
      kitJson['coverImageURL'],
      kitJson['thumbnail'],
      kitJson['thumbnailUrl'],
      kitJson['thumbnailURL'],
      kitJson['photo'],
      kitJson['url'],
    ]);

    return KitModel(
      id: _parseInt(kitJson['id']),
      name: (kitJson['name'] ?? '').toString(),
      description: (kitJson['description'] ?? '').toString(),
      imageUrl: imageUrl,
      imageUrls: _parseStringList(
        kitJson['imageURLs'] ??
            kitJson['imageUrls'] ??
            kitJson['imageKeys'] ??
            kitJson['images'] ??
            kitJson['gallery'] ??
            kitJson['photos'],
      ),
      type: (kitJson['type'] ?? '').toString(),
      mindset: mindsetData?.name ?? _parseMindsetText(kitJson['mindset']),
      mindsetData: mindsetData,
      rating: _parseDouble(kitJson['rating']),
      age: _parseInt(kitJson['age']),
      kitItems: _parseKitItems(
        kitJson['kitItems'] ?? kitJson['items'] ?? kitJson['kit_items'],
      ),
    );
  }

  static Map<String, dynamic> _extractKitJson(Map<String, dynamic> json) {
    final nestedKit = json['kit'];

    if (nestedKit is Map<String, dynamic>) {
      return nestedKit;
    }

    if (nestedKit is Map) {
      return Map<String, dynamic>.from(nestedKit);
    }

    return json;
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

    if (value is Map) {
      return MindsetModel.fromJson(Map<String, dynamic>.from(value));
    }

    return null;
  }

  static String _parseMindsetText(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;

    if (value is Map<String, dynamic>) {
      return (value['name'] ?? '').toString();
    }

    if (value is Map) {
      return (value['name'] ?? '').toString();
    }

    return value.toString();
  }

  static String _parseFirstText(List<dynamic> values) {
    for (final value in values) {
      if (value == null) continue;

      if (value is Map<String, dynamic>) {
        final nestedValue = _parseFirstText([
          value['url'],
          value['imageURL'],
          value['imageUrl'],
          value['imageKey'],
          value['key'],
          value['path'],
          value['src'],
        ]);

        if (nestedValue.isNotEmpty) {
          return nestedValue;
        }

        continue;
      }

      if (value is Map) {
        final nestedValue = _parseFirstText([
          value['url'],
          value['imageURL'],
          value['imageUrl'],
          value['imageKey'],
          value['key'],
          value['path'],
          value['src'],
        ]);

        if (nestedValue.isNotEmpty) {
          return nestedValue;
        }

        continue;
      }

      final text = value.toString().trim();

      if (text.isNotEmpty && text != 'null') {
        return text;
      }
    }

    return '';
  }

  static List<String> _parseStringList(dynamic value) {
    if (value is List) {
      return value
          .map((item) {
        if (item is Map<String, dynamic>) {
          return _parseFirstText([
            item['url'],
            item['imageURL'],
            item['imageUrl'],
            item['imageKey'],
            item['key'],
            item['path'],
            item['src'],
          ]);
        }

        if (item is Map) {
          return _parseFirstText([
            item['url'],
            item['imageURL'],
            item['imageUrl'],
            item['imageKey'],
            item['key'],
            item['path'],
            item['src'],
          ]);
        }

        return item?.toString() ?? '';
      })
          .where((item) => item.trim().isNotEmpty)
          .toList();
    }

    if (value is String && value.trim().isNotEmpty) {
      if (value.contains(',')) {
        return value
            .split(',')
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .toList();
      }

      return [value.trim()];
    }

    return <String>[];
  }

  static List<String> _parseKitItems(dynamic value) {
    if (value is List) {
      return value
          .map((item) {
        if (item is String) return item;

        if (item is Map<String, dynamic>) {
          return (item['name'] ??
              item['title'] ??
              item['itemName'] ??
              item['description'] ??
              item.toString())
              .toString();
        }

        if (item is Map) {
          return (item['name'] ??
              item['title'] ??
              item['itemName'] ??
              item['description'] ??
              item.toString())
              .toString();
        }

        return item.toString();
      })
          .where((item) => item.trim().isNotEmpty)
          .toList();
    }

    return <String>[];
  }
}