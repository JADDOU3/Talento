enum GlobalVoiceOverType {
  success,
  fail,
}

extension GlobalVoiceOverTypeApiValue on GlobalVoiceOverType {
  String get apiValue {
    switch (this) {
      case GlobalVoiceOverType.success:
        return 'SUCCESS';
      case GlobalVoiceOverType.fail:
        return 'FAIL';
    }
  }
}

class VoiceOverModel {
  final String url;
  final String? scope;
  final int? levelId;

  const VoiceOverModel({
    required this.url,
    this.scope,
    this.levelId,
  });

  factory VoiceOverModel.fromJson(Map<String, dynamic> json) {
    final url = json['url']?.toString().trim() ?? '';

    if (url.isEmpty) {
      throw const FormatException('Voice-over URL is missing.');
    }

    return VoiceOverModel(
      url: url,
      scope: json['scope']?.toString(),
      levelId: _toNullableInt(json['levelId'] ?? json['level_id']),
    );
  }

  static int? _toNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
