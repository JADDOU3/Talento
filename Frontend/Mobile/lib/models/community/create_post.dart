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
    return {
      'content': content,
      'kitId': kitId,
      'media': media?.map((e) => e.toJson()).toList(),
    };
  }
}

class MediaDto {
  final String type;
  final String url;

  MediaDto({
    required this.type,
    required this.url,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'url': url,
    };
  }
}