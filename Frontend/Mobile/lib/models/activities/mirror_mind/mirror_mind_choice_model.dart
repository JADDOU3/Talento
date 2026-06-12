class MirrorMindChoiceModel {
  final String icon;
  final String shape;
  final List<String> icons;
  final bool isCorrect;

  const MirrorMindChoiceModel({
    required this.icon,
    required this.shape,
    required this.icons,
    required this.isCorrect,
  });

  String get primaryIcon {
    if (icon.isNotEmpty) return icon;
    if (shape.isNotEmpty) return shape;
    if (icons.isNotEmpty) return icons.first;
    return '';
  }

  List<String> get displayIcons {
    if (icons.isNotEmpty) return icons;
    if (icon.isNotEmpty) return [icon];
    if (shape.isNotEmpty) return [shape];
    return <String>[];
  }

  String get choiceKey => displayIcons.join('|');

  factory MirrorMindChoiceModel.fromJson(Map<String, dynamic> json) {
    final parsedIcons = _parseIcons(json);

    return MirrorMindChoiceModel(
      icon: (json['icon'] ?? '').toString(),
      shape: (json['shape'] ?? '').toString(),
      icons: parsedIcons,
      isCorrect: json['isCorrect'] == true,
    );
  }

  static List<String> _parseIcons(Map<String, dynamic> json) {
    final iconsValue = json['icons'];

    if (iconsValue is List) {
      return iconsValue
          .map((item) => item.toString())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    final sequenceValue = json['sequence'];

    if (sequenceValue is List) {
      return sequenceValue
          .map((item) => item.toString())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    final iconValue = json['icon'];

    if (iconValue != null && iconValue.toString().isNotEmpty) {
      return [iconValue.toString()];
    }

    final shapeValue = json['shape'];

    if (shapeValue != null && shapeValue.toString().isNotEmpty) {
      return [shapeValue.toString()];
    }

    return <String>[];
  }
}