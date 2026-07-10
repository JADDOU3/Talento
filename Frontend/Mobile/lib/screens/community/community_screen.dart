import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../cubits/child_mode/child_mode_cubit.dart';
import '../../cubits/child_mode/child_mode_state.dart';
import '../../cubits/community/comment_cubit.dart';
import '../../cubits/community/community_filter_cubit.dart';
import '../../cubits/community/like_cubit.dart';
import '../../cubits/community/media_cubit.dart';
import '../../cubits/community/post_cubit.dart';
import '../../cubits/community/post_state.dart';
import '../../models/kit/kit_model.dart';
import '../../models/kit/mindset_model.dart';
import '../../services/community/comment.dart';
import '../../services/community/like.dart';
import '../../services/community/media.dart';
import '../../services/community/post.dart';
import '../../services/kit/kit_service.dart';
import '../../services/profile/profile_service.dart';
import '../../shared/layout/app_background.dart';
import '../../shared/layout/app_drawer.dart';
import '../../shared/layout/bottom_nav_bar.dart';
import '../../shared/layout/top_bar.dart';
import '../home/home_screen.dart';
import 'create_post_sheet.dart';
import 'widgets/action_icon_button.dart';
import 'widgets/community_filter_section.dart';
import 'widgets/community_message_state.dart';
import 'widgets/feature_card.dart';
import 'widgets/post_card.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => PostCubit(PostService())..getAllPosts()),
        BlocProvider(create: (_) => LikeCubit(LikeService())),
        BlocProvider(create: (_) => CommentCubit(CommentService())),
        BlocProvider(create: (_) => MediaCubit(MediaService())),
        BlocProvider(
          create: (_) => CommunityFilterCubit(KitService())..loadFilters(),
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
  CommunityFilterType _activeFilterType = CommunityFilterType.kitAll;
  int? _selectedMindsetId;
  int? _selectedKitId;
  Set<int> _ownerChildIds = const {};

  @override
  void initState() {
    super.initState();
    _loadOwnerChildIds();
  }

  Future<void> _loadOwnerChildIds() async {
    try {
      final children = await ProfileService().getChildren();
      final ids = children.map((child) => child.id).where((id) => id != 0).toSet();

      if (!mounted) return;
      setState(() => _ownerChildIds = ids);
    } catch (_) {
      final selectedChildId = await LikeService().getSelectedChildId();
      if (!mounted || selectedChildId == null) return;
      setState(() => _ownerChildIds = {selectedChildId});
    }
  }

  void _showMyPosts() {
    setState(() {
      _activeFilterType = CommunityFilterType.myPosts;
      _selectedMindsetId = null;
      _selectedKitId = null;
    });

    context.read<PostCubit>().getMyPosts();
  }

  void _showDefaultFeedFromKitRow() {
    setState(() {
      _activeFilterType = CommunityFilterType.kitAll;
      _selectedMindsetId = null;
      _selectedKitId = null;
    });

    context.read<PostCubit>().getAllPosts();
  }

  void _filterByMindset(MindsetModel mindset) {
    setState(() {
      _activeFilterType = CommunityFilterType.mindset;
      _selectedMindsetId = mindset.id;
      _selectedKitId = null;
    });

    context.read<PostCubit>().getPostsByMindset(mindset.id);
  }

  void _filterByKit(KitModel kit) {
    setState(() {
      _activeFilterType = CommunityFilterType.kit;
      _selectedKitId = kit.id;
      _selectedMindsetId = null;
    });

    context.read<PostCubit>().getPostsByKit(kit.id);
  }

  void _openCreatePostSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.black.withValues(alpha: 0.55),
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<PostCubit>()),
          BlocProvider.value(value: context.read<MediaCubit>()),
        ],
        child: const CreatePostSheet(),
      ),
    );
  }

  void _goToHome() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionDuration: const Duration(milliseconds: 180),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final childModeState = context.watch<ChildModeCubit>().state;
    final isChildMode =
        childModeState is ChildModeStatus && childModeState.isChildMode;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        drawer: const AppDrawer(),
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
                      FeatureCard(
                        onJoinMission: _goToHome,
                      ),
                      Transform.translate(
                        offset: const Offset(0, -30),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const _SearchBar(),
                              const SizedBox(height: 10),
                              CommunityFilterSection(
                                selectedMindsetId: _selectedMindsetId,
                                selectedKitId: _selectedKitId,
                                activeFilterType: _activeFilterType,
                                onMyPostsSelected: _showMyPosts,
                                onAllKitsSelected: _showDefaultFeedFromKitRow,
                                onMindsetSelected: _filterByMindset,
                                onKitSelected: _filterByKit,
                              ),
                              const SizedBox(height: 24),
                              if (!isChildMode)
                                Center(
                                  child: ActionIconButton(
                                    text: 'شارك قصتك',
                                    onTap: _openCreatePostSheet,
                                  ),
                                ),
                              if (!isChildMode) const SizedBox(height: 28),
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
                                    return CommunityMessageState(
                                      icon: Icons.error_outline_rounded,
                                      message: state.message,
                                      actionLabel: 'إعادة المحاولة',
                                      onAction: () =>
                                          context.read<PostCubit>().getAllPosts(),
                                    );
                                  }

                                  if (state is PostLoaded) {
                                    if (state.posts.isEmpty) {
                                      return const CommunityMessageState(
                                        icon: Icons.forum_outlined,
                                        message:
                                        'لا توجد منشورات لهذا الفلتر حالياً',
                                      );
                                    }

                                    return Column(
                                      children: state.posts.map((post) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                            bottom: 18,
                                          ),
                                          child: PostCard(
                                            key: ValueKey(post.id),
                                            post: post,
                                            isChildMode: isChildMode,
                                            ownerChildIds: _ownerChildIds,
                                          ),
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
              const BottomNavBar(selectedIndex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.55)),
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
          prefixIcon: const Icon(
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