class ChildModel {
  final int id;
  final String name;
  final String? avatarUrl;
  final String? dateOfBirth;
  final String? gender;

  const ChildModel({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.dateOfBirth,
    this.gender,
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      id: _parseInt(json['id']),
      name: (json['name'] ?? '').toString(),
      avatarUrl: json['avatarUrl']?.toString() ?? json['avatar']?.toString(),
      dateOfBirth: json['dateOfBirth']?.toString(),
      gender: json['gender']?.toString(),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}