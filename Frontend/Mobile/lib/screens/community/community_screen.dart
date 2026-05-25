import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../cubits/community/post_cubit.dart';
import '../../cubits/community/post_state.dart';
import '../../cubits/community/like_cubit.dart';
import '../../cubits/community/comment_cubit.dart';
import '../../cubits/community/media_cubit.dart';
import '../../services/community/post.dart';
import '../../services/community/like.dart';
import '../../services/community/comment.dart';
import '../../services/community/media.dart';
import '../../shared/layout/top_bar.dart';
import '../../shared/layout/app_background.dart';
import 'widgets/action_icon_button.dart';
import 'widgets/category_chip.dart';
import 'widgets/custom_bottom_nav.dart';
import 'widgets/feature_card.dart';
import 'widgets/post_card.dart';
import 'create_post_sheet.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => PostCubit(PostService())..getAllPosts(),
        ),
        BlocProvider(
          create: (_) => LikeCubit(LikeService()),
        ),
        BlocProvider(
          create: (_) => CommentCubit(CommentService()),
        ),
        BlocProvider(
          create: (_) => MediaCubit(MediaService()),
        ),
      ],
      child: const _CommunityView(),
    );
  }
}

class _CommunityView extends StatefulWidget {
  const _CommunityView();

  @override
  State<_CommunityView> createState() => _CommunityViewState();
}

class _CommunityViewState extends State<_CommunityView> {
  int selectedChip = 0;

  final List<String> categories = const [
    'الكل',
    'منشوراتي',
    'Mindset 1',
    'Kit 1',
  ];

  void _onCategoryTap(int index) {
    setState(() => selectedChip = index);

    final postCubit = context.read<PostCubit>();

    if (index == 0) {
      postCubit.getAllPosts();
    } else if (index == 1) {
      postCubit.getMyPosts();
    } else if (index == 2) {
      postCubit.getPostsByMindset(1);
    } else if (index == 3) {
      postCubit.getPostsByKit(1);
    }
  }

  void _openCreatePostSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<PostCubit>()),
          BlocProvider.value(value: context.read<MediaCubit>()),
        ],
        child: const CreatePostSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: AppBackground(
          child: Column(
            children: [
              const TopBar(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const FeatureCard(),
                      Transform.translate(
                        offset: const Offset(0, -28),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _SearchBar(),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 38,
                                child: ListView.separated(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: categories.length,
                                  separatorBuilder: (_, __) =>
                                  const SizedBox(width: 8),
                                  itemBuilder: (context, index) {
                                    return CategoryChip(
                                      label: categories[index],
                                      isSelected: selectedChip == index,
                                      onTap: () => _onCategoryTap(index),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),
                              Center(
                                child: ActionIconButton(
                                  text: 'شارك قصتك',
                                  onTap: _openCreatePostSheet,
                                ),
                              ),
                              const SizedBox(height: 28),
                              Text(
                                'القصص الحديثة',
                                textAlign: TextAlign.right,
                                style: AppTextStyles.headlineMedium.copyWith(
                                  color: AppColors.textPrimary,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 14),
                              BlocBuilder<PostCubit, PostState>(
                                builder: (context, state) {
                                  if (state is PostLoading) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(30),
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }

                                  if (state is PostError) {
                                    return Center(
                                      child: Text(
                                        state.message,
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  }

                                  if (state is PostLoaded) {
                                    if (state.posts.isEmpty) {
                                      return const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(30),
                                          child: Text('لا توجد منشورات حالياً'),
                                        ),
                                      );
                                    }

                                    return Column(
                                      children: state.posts.map((post) {
                                        return Padding(
                                          padding:
                                          const EdgeInsets.only(bottom: 18),
                                          child: PostCard(post: post),
                                        );
                                      }).toList(),
                                    );
                                  }

                                  return const SizedBox.shrink();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const CustomBottomNav(selectedIndex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.55),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: TextField(
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          hintText: 'ابحث في القصص، المشاريع، أو الأشخاص...',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.hint,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.hint,
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 15,
          ),
        ),
      ),
    );
  }
}