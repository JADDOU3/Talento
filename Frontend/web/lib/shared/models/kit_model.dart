// lib/shared/models/kit_model.dart

class KitModel {
  final int id;
  final String name;
  final String description;
  final String imageURL;
  final String type;
  final int? mindsetId;
  final String? mindsetName;
  final List<String> kitItems;
  final bool isNew;
  final double price;

  const KitModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageURL,
    required this.type,
    this.mindsetId,
    this.mindsetName,
    this.kitItems = const [],
    this.isNew = false,
    this.price = 0.0,
  });

  factory KitModel.fromJson(Map<String, dynamic> json) {
    return KitModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageURL: json['imageURL'] as String? ?? '',
      type: json['type'] as String? ?? '',
      mindsetId: json['mindsetId'] as int?,
      mindsetName: json['mindsetName'] as String?,
      kitItems: (json['kitItems'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      isNew: json['isNew'] as bool? ?? false,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'imageURL': imageURL,
        'type': type,
        'mindsetId': mindsetId,
        'mindsetName': mindsetName,
        'kitItems': kitItems,
        'isNew': isNew,
        'price': price,
      };
}

class MindsetModel {
  final int id;
  final String name;

  const MindsetModel({required this.id, required this.name});

  factory MindsetModel.fromJson(Map<String, dynamic> json) => MindsetModel(
        id: json['id'] as int? ?? 0,
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
      case KitType.biology:     return 'BIOLOGY';
      case KitType.engineering: return 'ENGINEERING';
      case KitType.arts:        return 'ARTS';
      case KitType.astronomy:   return 'ASTRONOMY';
      case KitType.chemistry:   return 'CHEMISTRY';
      case KitType.robotics:    return 'ROBOTICS';
    }
  }

  String get displayName {
    switch (this) {
      case KitType.biology:     return 'Biology';
      case KitType.engineering: return 'Engineering';
      case KitType.arts:        return 'Arts';
      case KitType.astronomy:   return 'Astronomy';
      case KitType.chemistry:   return 'Chemistry';
      case KitType.robotics:    return 'Robotics';
    }
  }
}