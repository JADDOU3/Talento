class Comment {
  final int id;
  final String content;
  final String createdAt;
  final CommentChild? child;

  Comment({
    required this.id,
    required this.content,
    required this.createdAt,
    this.child,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      content: json['content'] ?? '',
      createdAt: json['createdAt'] ?? '',
      child: json['child'] != null
          ? CommentChild.fromJson(json['child'])
          : null,
    );
  }
}

class CommentChild {
  final int id;
  final String name;

  CommentChild({
    required this.id,
    required this.name,
  });

  factory CommentChild.fromJson(Map<String, dynamic> json) {
    return CommentChild(
      id: json['id'],
      name: json['name'] ?? '',
    );
  }
}