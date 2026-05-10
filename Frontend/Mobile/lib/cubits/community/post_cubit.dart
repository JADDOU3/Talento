import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/community/create_post.dart';
import '../../services/community/post.dart';
import 'post_state.dart';

class PostCubit extends Cubit<PostState> {
  final PostService _postService;

  PostCubit(this._postService) : super(PostInitial());

  Future<void> getAllPosts() async {
    emit(PostLoading());

    try {
      final posts = await _postService.getAllPosts();
      emit(PostLoaded(posts));
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  Future<void> getPostsByMindset(int mindsetId) async {
    emit(PostLoading());

    try {
      final posts = await _postService.getPostsByMindset(mindsetId);
      emit(PostLoaded(posts));
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  Future<void> getPostsByKit(int kitId) async {
    emit(PostLoading());

    try {
      final posts = await _postService.getPostsByKit(kitId);
      emit(PostLoaded(posts));
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  Future<void> getMyPosts() async {
    emit(PostLoading());

    try {
      final posts = await _postService.getMyPosts();
      emit(PostLoaded(posts));
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  Future<void> getPostById(int id) async {
    emit(PostLoading());

    try {
      final post = await _postService.getPostById(id);
      emit(PostDetailsLoaded(post));
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  Future<void> createPost(CreatePost dto) async {
    emit(PostLoading());

    try {
      await _postService.createPost(dto);
      await getAllPosts();
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }

  Future<void> deletePost(int id) async {
    emit(PostLoading());

    try {
      await _postService.deletePost(id);
      await getAllPosts();
    } catch (e) {
      emit(PostError(e.toString()));
    }
  }
}