import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/community/create_comment.dart';
import '../../services/community/comment.dart';
import 'comment_state.dart';

class CommentCubit extends Cubit<CommentState> {
  final CommentService _commentService;

  CommentCubit(this._commentService) : super(CommentInitial());

  Future<void> getCommentsByPost(int postId) async {
    emit(CommentLoading());

    try {
      final comments = await _commentService.getCommentsByPost(postId);
      emit(CommentLoaded(comments));
    } catch (e) {
      emit(CommentError(e.toString()));
    }
  }

  Future<bool> createComment(CreateComment dto) async {
    try {
      await _commentService.createComment(dto);
      await getCommentsByPost(dto.postId);
      return true;
    } catch (e) {
      emit(CommentError(e.toString()));
      return false;
    }
  }

  Future<bool> deleteComment({
    required int commentId,
    required int postId,
  }) async {
    try {
      await _commentService.deleteComment(commentId);
      await getCommentsByPost(postId);
      return true;
    } catch (e) {
      emit(CommentError(e.toString()));
      return false;
    }
  }
}