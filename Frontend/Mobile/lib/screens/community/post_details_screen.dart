import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../cubits/child_mode/child_mode_cubit.dart';
import '../../cubits/child_mode/child_mode_state.dart';
import '../../cubits/community/comment_cubit.dart';
import '../../cubits/community/comment_state.dart';
import '../../cubits/community/post_cubit.dart';
import '../../cubits/community/post_state.dart';
import '../../models/community/comment.dart';
import '../../models/community/create_comment.dart';
import '../../models/community/post.dart';
import '../../services/community/like.dart';
import '../../services/profile/profile_service.dart';
import '../../shared/layout/app_background.dart';
import 'widgets/community_message_state.dart';
import 'widgets/owner_delete_menu.dart';

class PostDetailsScreen extends StatefulWidget {
  final int postId;
  final Set<int> ownerChildIds;

  const PostDetailsScreen({
    super.key,
    required this.postId,
    this.ownerChildIds = const {},
  });

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  final TextEditingController _commentController = TextEditingController();
  final LikeService _likeService = LikeService();

  Set<int> _ownerChildIds = const {};
  int? _selectedChildId;
  bool _isDeletingPost = false;
  bool _isSendingComment = false;

  @override
  void initState() {
    super.initState();
    _ownerChildIds = widget.ownerChildIds;
    Future.microtask(() {
      context.read<PostCubit>().getPostById(widget.postId);
      context.read<CommentCubit>().getCommentsByPost(widget.postId);
      _loadIdentityData();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadIdentityData() async {
    final selectedChildId = await _likeService.getSelectedChildId();

    Set<int> ids = _ownerChildIds;
    if (ids.isEmpty) {
      try {
        final children = await ProfileService().getChildren();
        ids = children.map((child) => child.id).where((id) => id != 0).toSet();
      } catch (_) {
        if (selectedChildId != null) ids = {selectedChildId};
      }
    }

    if (!mounted) return;
    setState(() {
      _selectedChildId = selectedChildId;
      _ownerChildIds = ids;
    });
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty || _isSendingComment) return;

    final childId = _selectedChildId ?? await _likeService.getSelectedChildId();

    if (!mounted) return;

    if (childId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد طفل محدد، اختاري طفل أولاً')),
      );
      return;
    }

    setState(() => _isSendingComment = true);

    final success = await context.read<CommentCubit>().createComment(
      CreateComment(
        postId: widget.postId,
        content: text,
        childId: childId,
        parentId: null,
      ),
    );

    if (!mounted) return;
    setState(() => _isSendingComment = false);

    if (success) {
      _commentController.clear();
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

    setState(() => _isDeletingPost = true);
    final success = await context.read<PostCubit>().deletePost(widget.postId);

    if (!mounted) return;
    setState(() => _isDeletingPost = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف المنشور بنجاح')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر حذف المنشور، حاولي مرة أخرى')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final childModeState = context.watch<ChildModeCubit>().state;
    final isChildMode =
        childModeState is ChildModeStatus && childModeState.isChildMode;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: MultiBlocListener(
        listeners: [
          BlocListener<CommentCubit, CommentState>(
            listener: (context, state) {
              if (state is CommentError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
          ),
        ],
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            title: Text(
              'تفاصيل المنشور',
              style: AppTextStyles.headlineMedium.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          body: AppBackground(
            child: Column(
              children: [
                Expanded(
                  child: BlocBuilder<PostCubit, PostState>(
                    builder: (context, state) {
                      if (state is PostLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is PostError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: CommunityMessageState(
                              icon: Icons.error_outline_rounded,
                              message: state.message,
                              actionLabel: 'إعادة المحاولة',
                              onAction: () => context
                                  .read<PostCubit>()
                                  .getPostById(widget.postId),
                            ),
                          ),
                        );
                      }

                      if (state is PostDetailsLoaded) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _PostDetailsCard(
                                post: state.post,
                                isChildMode: isChildMode,
                                ownerChildIds: _ownerChildIds,
                                isDeleting: _isDeletingPost,
                                onDelete: _confirmDeletePost,
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'التعليقات',
                                textAlign: TextAlign.right,
                                style: AppTextStyles.headlineMedium.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _CommentsList(
                                postId: widget.postId,
                                isChildMode: isChildMode,
                                ownerChildIds: _ownerChildIds,
                              ),
                            ],
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),

                if (!isChildMode)
                  _CommentInput(
                    controller: _commentController,
                    onSend: _sendComment,
                    isSending: _isSendingComment,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PostDetailsCard extends StatelessWidget {
  final Post post;
  final bool isChildMode;
  final Set<int> ownerChildIds;
  final bool isDeleting;
  final VoidCallback onDelete;

  const _PostDetailsCard({
    required this.post,
    required this.isChildMode,
    required this.ownerChildIds,
    required this.isDeleting,
    required this.onDelete,
  });

  bool get _isOwner {
    final childId = post.child?.id;
    return !isChildMode && childId != null && ownerChildIds.contains(childId);
  }

  @override
  Widget build(BuildContext context) {
    final childName = post.child?.name ?? 'طفل تالينتو';
    final imageUrl = post.media.isNotEmpty ? post.media.first.url : null;

    return Opacity(
      opacity: isDeleting ? 0.55 : 1,
      child: Container(
        padding: const EdgeInsets.all(14),
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
                  radius: 20,
                  backgroundColor: AppColors.inputFill,
                  child: Icon(Icons.person_rounded, color: AppColors.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    childName,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                if (_isOwner)
                  OwnerDeleteMenu(
                    deleteLabel: 'حذف المنشور',
                    onDelete: onDelete,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            if (imageUrl != null && imageUrl.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 180,
                    color: AppColors.inputFill,
                    child: const Icon(Icons.image_not_supported_outlined),
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],
            Text(
              post.content,
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontSize: 13,
                height: 1.6,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommentsList extends StatelessWidget {
  final int postId;
  final bool isChildMode;
  final Set<int> ownerChildIds;

  const _CommentsList({
    required this.postId,
    required this.isChildMode,
    required this.ownerChildIds,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommentCubit, CommentState>(
      builder: (context, state) {
        if (state is CommentLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is CommentError) {
          return CommunityMessageState(
            icon: Icons.error_outline_rounded,
            message: state.message,
          );
        }

        if (state is CommentLoaded) {
          if (state.comments.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(18),
              child: Center(child: Text('لا توجد تعليقات بعد')),
            );
          }

          return Column(
            children: state.comments.map((comment) {
              return _CommentItem(
                key: ValueKey(comment.id),
                comment: comment,
                postId: postId,
                isChildMode: isChildMode,
                ownerChildIds: ownerChildIds,
              );
            }).toList(),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _CommentItem extends StatefulWidget {
  final Comment comment;
  final int postId;
  final bool isChildMode;
  final Set<int> ownerChildIds;

  const _CommentItem({
    super.key,
    required this.comment,
    required this.postId,
    required this.isChildMode,
    required this.ownerChildIds,
  });

  @override
  State<_CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<_CommentItem> {
  bool _isDeleting = false;

  bool get _isOwner {
    final childId = widget.comment.child?.id;
    return !widget.isChildMode &&
        childId != null &&
        widget.ownerChildIds.contains(childId);
  }

  Future<void> _deleteComment() async {
    setState(() => _isDeleting = true);

    final success = await context.read<CommentCubit>().deleteComment(
      commentId: widget.comment.id,
      postId: widget.postId,
    );

    if (!mounted) return;
    setState(() => _isDeleting = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'تم حذف التعليق' : 'تعذر حذف التعليق، حاولي مرة أخرى',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _isDeleting ? 0.55 : 1,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.inputFill,
              child: Icon(
                Icons.person_rounded,
                size: 17,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((widget.comment.child?.name ?? '').trim().isNotEmpty) ...[
                    Text(
                      widget.comment.child!.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 11.8,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                  ],
                  Text(
                    widget.comment.content,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 12.5,
                      height: 1.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            if (_isOwner)
              OwnerDeleteMenu(
                deleteLabel: 'حذف التعليق',
                onDelete: _deleteComment,
              ),
          ],
        ),
      ),
    );
  }
}

class _CommentInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isSending;

  const _CommentInput({
    required this.controller,
    required this.onSend,
    required this.isSending,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border(
            top: BorderSide(color: AppColors.border.withValues(alpha: 0.7)),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: isSending ? null : onSend,
              icon: isSending
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.send_rounded, color: AppColors.primary),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                decoration: InputDecoration(
                  hintText: 'اكتب تعليق...',
                  filled: true,
                  fillColor: AppColors.inputFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
