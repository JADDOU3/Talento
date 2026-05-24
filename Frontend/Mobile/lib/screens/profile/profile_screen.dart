import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/kit/kit_model.dart';
import '../../shared/layout/app_drawer.dart';
import '../../shared/layout/bottom_nav_bar.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/layout/top_bar.dart';

import '../../cubits/profile/profile_cubit.dart';
import '../../cubits/profile/profile_state.dart';
import '../../cubits/child_mode/child_mode_cubit.dart';
import '../../cubits/child_mode/child_mode_state.dart';

import 'widgets/available_kits_section.dart';
import 'widgets/children_section.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_progress_card.dart';
import 'widgets/settings_section.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit()..loadProfile(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    // Watch child mode state — UI updates automatically without navigation
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
                    return const Center(child: CircularProgressIndicator());
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

                    // In child mode: show selected child's name instead of parent
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
                        children: [
                          const SizedBox(height: 12),

                          // Profile header changes based on child mode
                          ProfileHeader(
                            name: displayName,
                            email: isChildMode ? '' : user.email,
                            avatarUrl: displayAvatar,
                          ),

                          const SizedBox(height: 24),

                          // Children section — only shown in parent mode
                          if (!isChildMode)
                            ChildrenSection(
                              children: children,
                              selectedChild: selectedChild,
                              onChildSelected: (child) {
                                context
                                    .read<ProfileCubit>()
                                    .selectChild(child);
                                Future.delayed(
                                  const Duration(milliseconds: 150),
                                      () => context
                                      .read<ChildModeCubit>()
                                      .checkChildMode(),
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
                                isChildMode ? 'حقائبي' : 'الحقائب',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          AvailableKitsSection(kits: kits),

                          const SizedBox(height: 24),

                          // Settings only in parent mode
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
