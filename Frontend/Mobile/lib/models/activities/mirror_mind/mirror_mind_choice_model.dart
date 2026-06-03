class MirrorMindChoiceModel {
  final String icon;
  final List<String> icons;
  final bool isCorrect;

  const MirrorMindChoiceModel({
    required this.icon,
    required this.icons,
    required this.isCorrect,
  });

  List<String> get displayIcons {
    if (icons.isNotEmpty) return icons;
    if (icon.isNotEmpty) return [icon];
    return <String>[];
  }

  String get choiceKey => displayIcons.join('|');

  factory MirrorMindChoiceModel.fromJson(Map<String, dynamic> json) {
    final parsedIcons = _parseIcons(json);

    return MirrorMindChoiceModel(
      icon: (json['icon'] ?? '').toString(),
      icons: parsedIcons,
      isCorrect: json['isCorrect'] == true,
    );
  }

  static List<String> _parseIcons(Map<String, dynamic> json) {
    final iconsValue = json['icons'];

    if (iconsValue is List) {
      return iconsValue.map((item) => item.toString()).toList();
    }

    final sequenceValue = json['sequence'];

    if (sequenceValue is List) {
      return sequenceValue.map((item) => item.toString()).toList();
    }

    final iconValue = json['icon'];

    if (iconValue != null && iconValue.toString().isNotEmpty) {
      return [iconValue.toString()];
    }

    return <String>[];
  }
}