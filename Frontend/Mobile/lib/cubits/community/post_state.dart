import '../../models/community/post.dart';

abstract class PostState {}

class PostInitial extends PostState {}

class PostLoading extends PostState {}

class PostLoaded extends PostState {
  final List<Post> posts;

  PostLoaded(this.posts);
}

class PostDetailsLoaded extends PostState {
  final Post post;

  PostDetailsLoaded(this.post);
}

class PostError extends PostState {
  final String message;

  PostError(this.message);
}