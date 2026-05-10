class CreatePost {
  final String content;
  final int? kitId;
  final List<MediaDto>? media;

  CreatePost({
    required this.content,
    this.kitId,
    this.media,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'content': content,
    };

    if (kitId != null) {
      data['kitId'] = kitId;
    }

    if (media != null && media!.isNotEmpty) {
      data['media'] = media!.map((e) => e.toJson()).toList();
    }

    return data;
  }
}

class MediaDto {
  final String type;
  final String s3Key;

  MediaDto({
    required this.type,
    required this.s3Key,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      's3Key': s3Key,
    };
  }
}