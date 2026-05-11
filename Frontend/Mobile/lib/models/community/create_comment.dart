class CreateComment {
  final int postId;
  final String content;
  final int? childId;
  final int? parentId;

  CreateComment({
    required this.postId,
    required this.content,
    this.childId,
    this.parentId,
  });

  Map<String, dynamic> toJson() {
    return {
      'postId': postId,
      'content': content,
      'childId': childId,
      'parentId': parentId,
    };
  }
}