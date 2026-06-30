import 'roadmap_activity_model.dart';

class RoadmapModel {
  final int kitId;
  final String kitName;
  final String kitImageUrl;
  final List<RoadmapActivityModel> activities;

  const RoadmapModel({
    required this.kitId,
    required this.kitName,
    required this.kitImageUrl,
    required this.activities,
  });

  factory RoadmapModel.fromJson(Map<String, dynamic> json) {
    final nestedData = json['data'] ?? json['result'] ?? json['roadmap'];

    if (nestedData is Map<String, dynamic>) {
      return RoadmapModel.fromJson(nestedData);
    }

    if (nestedData is Map) {
      return RoadmapModel.fromJson(Map<String, dynamic>.from(nestedData));
    }

    return RoadmapModel(
      kitId: _parseInt(json['kitId'] ?? json['id']),
      kitName: (json['kitName'] ?? json['name'] ?? json['pathName'] ?? '').toString(),
      kitImageUrl: (json['kitImageURL'] ??
          json['kitImageUrl'] ??
          json['imageUrl'] ??
          json['imageURL'] ??
          '')
          .toString(),
      activities: _parseActivities(
        json['activities'] ?? json['nodes'] ?? json['items'] ?? json['content'] ?? json['data'],
      ),
    );
  }

  factory RoadmapModel.fromActivities({
    required int kitId,
    required List<dynamic> activities,
    String kitName = '',
    String kitImageUrl = '',
  }) {
    return RoadmapModel(
      kitId: kitId,
      kitName: kitName,
      kitImageUrl: kitImageUrl,
      activities: _parseActivities(activities),
    );
  }

  static List<RoadmapActivityModel> _parseActivities(dynamic value) {
    if (value is List) {
      return value
          .whereType<Map>()
          .map((item) => RoadmapActivityModel.fromJson(
        Map<String, dynamic>.from(item),
      ))
          .toList();
    }

    if (value is Map<String, dynamic>) {
      return _parseActivities(
        value['activities'] ?? value['nodes'] ?? value['items'] ?? value['content'],
      );
    }

    if (value is Map) {
      return _parseActivities(Map<String, dynamic>.from(value));
    }

    return <RoadmapActivityModel>[];
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }
}
