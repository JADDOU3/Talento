import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/community/like.dart';
import 'like_state.dart';

class LikeCubit extends Cubit<LikeState> {
  final LikeService _likeService;

  final Map<int, int> likeCounts = {};
  final Map<int, bool> likedPosts = {};

  LikeCubit(this._likeService) : super(LikeInitial());

  Future<void> getLikeCount(int postId) async {
    try {
      final count = await _likeService.getLikeCount(postId);

      likeCounts[postId] = count;
      likedPosts[postId] = likedPosts[postId] ?? false;

      emit(
        LikeUpdated(
          postId: postId,
          count: count,
          isLiked: likedPosts[postId] ?? false,
        ),
      );
    } catch (e) {
      emit(LikeError(e.toString()));
    }
  }

  Future<void> toggleLike(int postId) async {
    final selectedChildId = await _likeService.getSelectedChildId();

    if (selectedChildId == null) {
      emit(LikeError('لا يوجد طفل محدد، اختاري طفل أولاً'));
      return;
    }

    final oldCount = likeCounts[postId] ?? 0;
    final oldIsLiked = likedPosts[postId] ?? false;

    final newIsLiked = !oldIsLiked;
    final newCount = newIsLiked ? oldCount + 1 : oldCount - 1;

    likeCounts[postId] = newCount < 0 ? 0 : newCount;
    likedPosts[postId] = newIsLiked;

    emit(
      LikeUpdated(
        postId: postId,
        count: likeCounts[postId] ?? 0,
        isLiked: newIsLiked,
      ),
    );

    try {
      await _likeService.toggleLike(
        postId: postId,
        childId: selectedChildId,
      );
    } catch (e) {
      likeCounts[postId] = oldCount;
      likedPosts[postId] = oldIsLiked;

      emit(
        LikeUpdated(
          postId: postId,
          count: oldCount,
          isLiked: oldIsLiked,
        ),
      );

      emit(LikeError(e.toString()));
    }
  }
}