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
    return RoadmapModel(
      kitId: _parseInt(json['kitId'] ?? json['id']),
      kitName: (
          json['kitName'] ??
              json['name'] ??
              ''
      ).toString(),
      kitImageUrl: (
          json['kitImageURL'] ??
              json['kitImageUrl'] ??
              json['imageUrl'] ??
              json['imageURL'] ??
              ''
      ).toString(),
      activities: _parseActivities(json['activities']),
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

    return <RoadmapActivityModel>[];
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? 0;
  }
}