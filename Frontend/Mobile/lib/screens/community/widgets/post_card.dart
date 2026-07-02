import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../cubits/community/comment_cubit.dart';
import '../../../cubits/community/like_cubit.dart';
import '../../../cubits/community/like_state.dart';
import '../../../cubits/community/post_cubit.dart';
import '../../../models/community/post.dart';
import '../../../services/community/post.dart';
import '../post_details_screen.dart';
import 'owner_delete_menu.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final bool isChildMode;
  final Set<int> ownerChildIds;

  const PostCard({
    super.key,
    required this.post,
    this.isChildMode = false,
    this.ownerChildIds = const {},
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isDeleting = false;

  bool get _isOwner {
    final childId = widget.post.child?.id;
    return !widget.isChildMode &&
        childId != null &&
        widget.ownerChildIds.contains(childId);
  }

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;
      context.read<LikeCubit>().loadPostLikeData(widget.post.id);
    });
  }

  @override
  void didUpdateWidget(covariant PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.post.id != widget.post.id) {
      Future.microtask(() {
        if (!mounted) return;
        context.read<LikeCubit>().loadPostLikeData(widget.post.id);
      });
    }
  }

  Future<void> _openPostDetails() async {
    final parentPostCubit = context.read<PostCubit>();
    final commentCubit = context.read<CommentCubit>();

    final deleted = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => PostCubit(PostService())),
            BlocProvider.value(value: commentCubit),
          ],
          child: PostDetailsScreen(
            postId: widget.post.id,
            ownerChildIds: widget.ownerChildIds,
          ),
        ),
      ),
    );

    if (deleted == true) {
      parentPostCubit.removePostLocally(widget.post.id);
    }
  }

  Future<void> _confirmDeletePost() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('حذف المنشور'),
          content: const Text('هل أنتِ متأكدة من حذف هذا المنشور؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('حذف'),
            ),
          ],
        ),
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isDeleting = true);

    final success = await context.read<PostCubit>().deletePost(widget.post.id);

    if (!mounted) return;

    setState(() => _isDeleting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'تم حذف المنشور بنجاح' : 'تعذر حذف المنشور، حاولي مرة أخرى',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl =
    widget.post.media.isNotEmpty ? widget.post.media.first.url : null;
    final childName = widget.post.child?.name ?? 'طفل تالينتو';

    return InkWell(
      onTap: _isDeleting ? null : _openPostDetails,
      borderRadius: BorderRadius.circular(24),
      child: Opacity(
        opacity: _isDeleting ? 0.55 : 1,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.border.withValues(alpha: 0.65),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.045),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.inputFill,
                    child: Icon(
                      Icons.person_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          childName,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(widget.post.createdAt),
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 10.5,
                            color: AppColors.hint,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isOwner)
                    OwnerDeleteMenu(
                      deleteLabel: 'حذف المنشور',
                      onDelete: _confirmDeletePost,
                    )
                  else
                    const SizedBox(width: 22),
                ],
              ),
              if (imageUrl != null && imageUrl.isNotEmpty) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: AspectRatio(
                    aspectRatio: 1.18,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.inputFill,
                        child: const Icon(Icons.image_not_supported_outlined),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              BlocBuilder<LikeCubit, LikeState>(
                builder: (context, state) {
                  final likeCubit = context.read<LikeCubit>();
                  final count = likeCubit.likeCounts[widget.post.id] ?? 0;
                  final isLiked = likeCubit.likedPosts[widget.post.id] ?? false;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          if (!widget.isChildMode) ...[
                            InkWell(
                              onTap: _isDeleting
                                  ? null
                                  : () => context
                                  .read<LikeCubit>()
                                  .toggleLike(widget.post.id),
                              borderRadius: BorderRadius.circular(30),
                              child: Icon(
                                isLiked
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: isLiked
                                    ? AppColors.pink
                                    : AppColors.textSecondary,
                                size: 23,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              count.toString(),
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 18),
                          ],
                          InkWell(
                            onTap: _isDeleting ? null : _openPostDetails,
                            borderRadius: BorderRadius.circular(30),
                            child: const Icon(
                              Icons.mode_comment_outlined,
                              color: AppColors.textSecondary,
                              size: 21,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            widget.post.commentsCount.toString(),
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          childName,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontSize: 12.8,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          widget.post.content,
                          textAlign: TextAlign.right,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 12.3,
                            height: 1.55,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String value) {
    if (value.isEmpty) return '';

    try {
      final date = DateTime.parse(value);
      return '${date.year}/${date.month}/${date.day}';
    } catch (_) {
      return value;
    }
  }
}