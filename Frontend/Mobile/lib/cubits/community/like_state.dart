abstract class LikeState {}

class LikeInitial extends LikeState {}

class LikeUpdated extends LikeState {
  final int postId;
  final int count;
  final bool isLiked;

  LikeUpdated({
    required this.postId,
    required this.count,
    required this.isLiked,
  });
}

class LikeError extends LikeState {
  final String message;

  LikeError(this.message);
}