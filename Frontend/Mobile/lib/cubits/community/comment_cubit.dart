import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/community/comment.dart';
import '../../models/community/create_comment.dart';
import '../../services/community/comment.dart';
import 'comment_state.dart';

class CommentCubit extends Cubit<CommentState> {
  final CommentService _commentService;

  List<Comment> _comments = [];

  CommentCubit(this._commentService) : super(CommentInitial());

  Future<void> getCommentsByPost(int postId) async {
    emit(CommentLoading());

    try {
      _comments = await _commentService.getCommentsByPost(postId);
      emit(CommentLoaded(_comments));
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
      if (_comments.isNotEmpty) emit(CommentLoaded(_comments));
      return false;
    }
  }

  Future<bool> deleteComment({
    required int commentId,
    required int postId,
  }) async {
    try {
      await _commentService.deleteComment(commentId);
      _comments = _comments.where((comment) => comment.id != commentId).toList();
      emit(CommentLoaded(_comments));
      return true;
    } catch (_) {
      emit(CommentLoaded(_comments));
      return false;
    }
  }
}
