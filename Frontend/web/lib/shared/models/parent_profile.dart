class ParentProfile {
  final int id;
  final String name;
  final String email;

  ParentProfile({
    required this.id,
    required this.name,
    required this.email,
  });

  factory ParentProfile.fromJson(Map<String, dynamic> json) {
    return ParentProfile(
      id: json["id"],
      name: json["name"] ?? "",
      email: json["email"] ?? "",
    );
  }
}