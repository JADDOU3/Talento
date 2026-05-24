// lib/shared/models/kit_model.dart

class KitModel {
  final int id;
  final String name;
  final String description;
  final String imageURL;
  final String type;
  final List<String> kitItems;
  final bool isNew;
  final double price;
  final double rating;
  final int age;
  final KitMindsetModel? mindset;

  const KitModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageURL,
    required this.type,
    this.kitItems = const [],
    this.isNew = false,
    this.price = 0.0,
    this.rating = 0,
    this.age = 0,
    this.mindset,
  });

  factory KitModel.fromJson(Map<String, dynamic> json) {
    KitMindsetModel? mindset;
    final mindsetRaw = json['mindset'];
    if (mindsetRaw is Map<String, dynamic>) {
      mindset = KitMindsetModel.fromJson(mindsetRaw);
    }

    return KitModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageURL: json['imageURL'] as String? ?? '',
      type: json['type'] as String? ?? '',
      kitItems: (json['kitItems'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isNew: json['isNew'] as bool? ?? false,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      age: (json['age'] as num?)?.toInt() ?? 0,
      mindset: mindset,
    );
  }

  /// Legacy catalog list responses may expose flat mindset fields.
  int? get mindsetId => mindset?.id;
  String? get mindsetName => mindset?.name;
}

class KitMindsetModel {
  final int id;
  final String name;
  final String description;
  final List<CriteriaModel> criteria;

  const KitMindsetModel({
    required this.id,
    required this.name,
    this.description = '',
    this.criteria = const [],
  });

  factory KitMindsetModel.fromJson(Map<String, dynamic> json) {
    final criteriaRaw = json['criteria'];
    return KitMindsetModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      criteria: criteriaRaw is List
          ? criteriaRaw
              .whereType<Map<String, dynamic>>()
              .map(CriteriaModel.fromJson)
              .toList()
          : [],
    );
  }
}

class CriteriaModel {
  final int id;
  final String name;
  final double? weight;

  const CriteriaModel({
    required this.id,
    required this.name,
    this.weight,
  });

  factory CriteriaModel.fromJson(Map<String, dynamic> json) {
    return CriteriaModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      weight: (json['weight'] as num?)?.toDouble(),
    );
  }
}

/// Catalog list pagination mindset chip.
class MindsetModel {
  final int id;
  final String name;

  const MindsetModel({required this.id, required this.name});

  factory MindsetModel.fromJson(Map<String, dynamic> json) => MindsetModel(
        id: (json['id'] as num?)?.toInt() ?? 0,
        name: json['name'] as String? ?? '',
      );
}

enum KitType {
  biology,
  engineering,
  arts,
  astronomy,
  chemistry,
  robotics,
}

extension KitTypeExtension on KitType {
  String get apiValue {
    switch (this) {
      case KitType.biology:
        return 'BIOLOGY';
      case KitType.engineering:
        return 'ENGINEERING';
      case KitType.arts:
        return 'ARTS';
      case KitType.astronomy:
        return 'ASTRONOMY';
      case KitType.chemistry:
        return 'CHEMISTRY';
      case KitType.robotics:
        return 'ROBOTICS';
    }
  }

  String get displayName {
    switch (this) {
      case KitType.biology:
        return 'Biology';
      case KitType.engineering:
        return 'Engineering';
      case KitType.arts:
        return 'Arts';
      case KitType.astronomy:
        return 'Astronomy';
      case KitType.chemistry:
        return 'Chemistry';
      case KitType.robotics:
        return 'Robotics';
    }
  }
}
