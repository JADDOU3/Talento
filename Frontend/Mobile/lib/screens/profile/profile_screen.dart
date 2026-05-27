import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../cubits/child_mode/child_mode_cubit.dart';
import '../../cubits/child_mode/child_mode_state.dart';
import '../../cubits/profile/profile_cubit.dart';
import '../../cubits/profile/profile_state.dart';
import '../../models/kit/kit_model.dart';
import '../../shared/layout/app_background.dart';
import '../../shared/layout/app_drawer.dart';
import '../../shared/layout/bottom_nav_bar.dart';
import '../../shared/layout/top_bar.dart';
import 'widgets/available_kits_section.dart';
import 'widgets/children_section.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_progress_card.dart';
import 'widgets/settings_section.dart';

class ProfileScreen extends StatelessWidget {
  final bool openAddChildDialog;

  const ProfileScreen({
    super.key,
    this.openAddChildDialog = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit()..loadProfile(),
      child: _ProfileView(
        openAddChildDialog: openAddChildDialog,
      ),
    );
  }
}

class _ProfileView extends StatelessWidget {
  final bool openAddChildDialog;

  const _ProfileView({
    required this.openAddChildDialog,
  });

  @override
  Widget build(BuildContext context) {
    final childModeState = context.watch<ChildModeCubit>().state;
    final isChildMode =
        childModeState is ChildModeStatus && childModeState.isChildMode;

    return Scaffold(
      drawer: const AppDrawer(),
      body: AppBackground(
        child: Column(
          children: [
            const TopBar(),
            Expanded(
              child: BlocConsumer<ProfileCubit, ProfileState>(
                listener: (context, state) {
                  if (state is ProfileError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(state.message)),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is ProfileLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  if (state is ProfileError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppColors.error,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'حدث خطأ',
                            style: AppTextStyles.bodyLarge,
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {
                              context.read<ProfileCubit>().loadProfile();
                            },
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is ProfileLoaded || state is ProfileKitsLoading) {
                    final user = state is ProfileLoaded
                        ? state.user
                        : (state as ProfileKitsLoading).user;

                    final children = state is ProfileLoaded
                        ? state.children
                        : (state as ProfileKitsLoading).children;

                    final selectedChild = state is ProfileLoaded
                        ? state.selectedChild
                        : (state as ProfileKitsLoading).selectedChild;

                    final List<KitModel> kits = state is ProfileLoaded
                        ? state.kits
                        : <KitModel>[];

                    final isKitsLoading = state is ProfileKitsLoading;

                    final displayName = isChildMode && selectedChild != null
                        ? selectedChild.name
                        : user.name;

                    final displayAvatar = isChildMode && selectedChild != null
                        ? (selectedChild.avatarUrl ??
                        'https://api.dicebear.com/7.x/adventurer/png?seed=${selectedChild.name}')
                        : (user.avatarUrl ?? '');

                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          ProfileHeader(
                            name: displayName,
                            email: isChildMode ? '' : user.email,
                            avatarUrl: displayAvatar,
                          ),
                          const SizedBox(height: 24),

                          if (!isChildMode)
                            ChildrenSection(
                              children: children,
                              selectedChild: selectedChild,
                              openAddChildDialog: openAddChildDialog,
                              onChildSelected: (child) {
                                context
                                    .read<ProfileCubit>()
                                    .selectChild(child);

                                Future.delayed(
                                  const Duration(milliseconds: 150),
                                      () {
                                    if (context.mounted) {
                                      context
                                          .read<ChildModeCubit>()
                                          .checkChildMode();
                                    }
                                  },
                                );
                              },
                            ),

                          if (!isChildMode) const SizedBox(height: 24),

                          const ProfileProgressCard(
                            level: 'المستوى 3',
                            progress: 0.7,
                          ),
                          const SizedBox(height: 24),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'الحقائب النشطة',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          if (isKitsLoading)
                            const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.primary,
                              ),
                            )
                          else if (kits.isEmpty)
                            Center(
                              child: Text(
                                'لا توجد حقائب لهذا الطفل',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            )
                          else
                            AvailableKitsSection(kits: kits),

                          const SizedBox(height: 24),

                          if (!isChildMode) const SettingsSection(),

                          const SizedBox(height: 24),
                        ],
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
            const BottomNavBar(selectedIndex: -1),
          ],
        ),
      ),
    );
  }
}