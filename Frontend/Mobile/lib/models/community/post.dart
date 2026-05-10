class Post {
  final int id;
  final String content;
  final String createdAt;
  final Child? child;
  final List<Media> media;
  final int commentsCount;

  Post({
    required this.id,
    required this.content,
    required this.createdAt,
    this.child,
    required this.media,
    required this.commentsCount,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      content: json['content'] ?? '',
      createdAt:
      json['createdAt'] ??
          json['created_at'] ??
          '',
      child: json['child'] != null
          ? Child.fromJson(json['child'])
          : null,
      media: json['media'] != null
          ? (json['media'] as List)
          .map((e) => Media.fromJson(e))
          .toList()
          : [],
      commentsCount:
      json['commentsCount'] ??
          json['commentCount'] ??
          (json['comments'] is List
              ? (json['comments'] as List).length
              : 0),
    );
  }
}

class Child {
  final int id;
  final String name;

  Child({
    required this.id,
    required this.name,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'],
      name: json['name'] ?? '',
    );
  }
}

class Media {
  final int id;
  final String type;
  final String url;
  final String? s3Key;

  Media({
    required this.id,
    required this.type,
    required this.url,
    this.s3Key,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id'],
      type: json['type'] ?? '',
      url: json['url'] ?? '',
      s3Key: json['s3Key'],
    );
  }
}