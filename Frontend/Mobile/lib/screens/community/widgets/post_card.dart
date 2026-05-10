import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../cubits/community/like_cubit.dart';
import '../../../cubits/community/like_state.dart';
import '../../../models/community/post.dart';
import '../post_details_screen.dart';

class PostCard extends StatefulWidget {
  final Post post;

  const PostCard({
    super.key,
    required this.post,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<LikeCubit>().getLikeCount(widget.post.id);
    });
  }

  void _openPostDetails() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostDetailsScreen(postId: widget.post.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl =
    widget.post.media.isNotEmpty ? widget.post.media.first.url : null;

    final childName = widget.post.child?.name ?? 'طفل تالينتو';

    return InkWell(
      onTap: _openPostDetails,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.65)),
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
                Icon(
                  Icons.more_horiz_rounded,
                  color: AppColors.textSecondary,
                  size: 22,
                ),
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

                return Row(
                  children: [
                    InkWell(
                      onTap: () {
                        context.read<LikeCubit>().toggleLike(widget.post.id);
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: Icon(
                        isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color:
                        isLiked ? AppColors.pink : AppColors.textSecondary,
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

                    InkWell(
                      onTap: _openPostDetails,
                      borderRadius: BorderRadius.circular(30),
                      child: Icon(
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

                    const SizedBox(width: 18),

                    Icon(
                      Icons.share_outlined,
                      color: AppColors.textSecondary,
                      size: 21,
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 10),

            RichText(
              textAlign: TextAlign.right,
              text: TextSpan(
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 12.3,
                  height: 1.55,
                ),
                children: [
                  TextSpan(
                    text: '$childName  ',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  TextSpan(text: widget.post.content),
                ],
              ),
            ),
          ],
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