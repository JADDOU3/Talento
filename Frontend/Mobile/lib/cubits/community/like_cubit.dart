import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/community/like.dart';
import 'like_state.dart';

class LikeCubit extends Cubit<LikeState> {
  final LikeService _likeService;

  final Map<int, int> likeCounts = {};
  final Map<int, bool> likedPosts = {};

  LikeCubit(this._likeService) : super(LikeInitial());

  Future<void> loadPostLikeData(int postId) async {
    try {
      final results = await Future.wait<dynamic>([
        _likeService.getLikeCount(postId),
        _likeService.isPostLiked(postId),
      ]);

      final count = results[0] as int;
      final isLiked = results[1] as bool;

      likeCounts[postId] = count;
      likedPosts[postId] = isLiked;

      emit(
        LikeUpdated(
          postId: postId,
          count: count,
          isLiked: isLiked,
        ),
      );
    } catch (e) {
      emit(LikeError(e.toString()));
    }
  }
  Future<void> getLikeCount(int postId) async {
    try {
      final count = await _likeService.getLikeCount(postId);

      likeCounts[postId] = count;
      likedPosts.putIfAbsent(postId, () => false);

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

    final optimisticIsLiked = !oldIsLiked;
    final optimisticCount = optimisticIsLiked ? oldCount + 1 : oldCount - 1;

    likeCounts[postId] = optimisticCount < 0 ? 0 : optimisticCount;
    likedPosts[postId] = optimisticIsLiked;

    emit(
      LikeUpdated(
        postId: postId,
        count: likeCounts[postId] ?? 0,
        isLiked: optimisticIsLiked,
      ),
    );

    try {
      final result = await _likeService.toggleLike(
        postId: postId,
        childId: selectedChildId,
      );

      final normalizedResult = result.toLowerCase().trim();

      final confirmedIsLiked = normalizedResult.contains('liked') &&
          !normalizedResult.contains('unliked');

      final confirmedCount = confirmedIsLiked ? oldCount + 1 : oldCount - 1;

      likeCounts[postId] = confirmedCount < 0 ? 0 : confirmedCount;
      likedPosts[postId] = confirmedIsLiked;

      emit(
        LikeUpdated(
          postId: postId,
          count: likeCounts[postId] ?? 0,
          isLiked: confirmedIsLiked,
        ),
      );
    } catch (e) {
      print('LIKE TOGGLE FAILED IN CUBIT: $e');

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
