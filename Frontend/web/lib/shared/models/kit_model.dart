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
  final String? funFact; // Added for kid-friendly fun facts
  final String? ageRange; // Added for age range display
  final List<String>? skills; // Added for skills developed

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
    this.funFact,
    this.ageRange,
    this.skills,
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
      funFact: json['funFact'] as String?,
      ageRange: json['ageRange'] as String?,
      skills: (json['skills'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
    );
  }

  /// Get fun display name with emoji based on kit type
  String get displayName {
    final emoji = _getTypeEmoji(type);
    return '$emoji $name';
  }

  /// Get age range display string
  String get displayAge {
    if (ageRange != null && ageRange!.isNotEmpty) {
      return ageRange!;
    }
    return age > 0 ? '${age - 2}-${age + 2} years' : '4-7 years';
  }

  /// Get rating display with stars
  String get ratingDisplay {
    if (rating <= 0) return '⭐⭐⭐⭐⭐';
    final fullStars = rating.round();
    return '⭐' * fullStars.clamp(0, 5);
  }

  /// Get type emoji
  String _getTypeEmoji(String type) {
    final typeMap = {
      'biology': '🧬',
      'engineering': '⚙️',
      'arts': '🎨',
      'astronomy': '🚀',
      'chemistry': '🧪',
      'robotics': '🤖',
      'science': '🔬',
      'math': '📐',
      'reading': '📚',
      'nature': '🌿',
      'space': '🌌',
      'music': '🎵',
      'history': '🏛️',
    };
    return typeMap[type.toLowerCase()] ?? '🌟';
  }

  /// Get skills as a formatted string
  String get skillsDisplay {
    if (skills == null || skills!.isEmpty) return '';
    return skills!.join(' • ');
  }

  /// Get a fun fact about the kit
  String get displayFunFact {
    if (funFact != null && funFact!.isNotEmpty) {
      return funFact!;
    }
    return '🌟 Discover amazing things with this kit!';
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
        return '🧬 Biology';
      case KitType.engineering:
        return '⚙️ Engineering';
      case KitType.arts:
        return '🎨 Arts';
      case KitType.astronomy:
        return '🚀 Astronomy';
      case KitType.chemistry:
        return '🧪 Chemistry';
      case KitType.robotics:
        return '🤖 Robotics';
    }
  }

  String get emoji {
    switch (this) {
      case KitType.biology:
        return '🧬';
      case KitType.engineering:
        return '⚙️';
      case KitType.arts:
        return '🎨';
      case KitType.astronomy:
        return '🚀';
      case KitType.chemistry:
        return '🧪';
      case KitType.robotics:
        return '🤖';
    }
  }
}

/// Helper extension for creating fun kit names
extension KitNameGenerator on KitModel {
  /// Generate a fun, kid-friendly name for the kit
  String get funName {
    final nameMap = {
      'biology': ['🧬 DNA Explorer', '🔬 Microscope Adventure', '🌱 Plant Scientist'],
      'engineering': ['⚙️ Builder Bot', '🔧 Engineer Junior', '🏗️ Construction Master'],
      'arts': ['🎨 Creative Canvas', '🖌️ Color Splash', '🌈 Rainbow Artist'],
      'astronomy': ['🚀 Space Explorer', '🌌 Galaxy Discoverer', '⭐ Star Gazer'],
      'chemistry': ['🧪 Lab Scientist', '⚗️ Chemical Wonder', '🔬 Science Explorer'],
      'robotics': ['🤖 Robot Builder', '⚡ Circuit Creator', '🔌 Tech Wizard'],
    };

    final suggestions = nameMap[type.toLowerCase()] ?? ['🌟 ${name}'];
    return suggestions[0];
  }

  /// Get a fun tagline for the kit
  String get funTagline {
    final taglines = [
      '🌟 Discover amazing things!',
      '🎯 Learn through play!',
      '🚀 Your adventure starts here!',
      '🌈 Explore, create, and grow!',
      '⭐ Every child is a genius!',
      '🎨 Unleash your creativity!',
      '🤖 Build the future today!',
      '🔬 Science is magic!',
    ];
    return taglines[id % taglines.length];
  }
}