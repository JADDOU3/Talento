import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/screens/profile/widgets/available_kits_section.dart';
import 'package:mobile/screens/profile/widgets/children_section.dart';
import 'package:mobile/screens/profile/widgets/profile_header.dart';
import 'package:mobile/screens/profile/widgets/profile_progress_card.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/layout/top_bar.dart';
import '../../shared/layout/bottom_nav_bar.dart';
import '../../cubits/profile/profile_cubit.dart';
import '../../cubits/profile/profile_state.dart';
import 'package:mobile/screens/profile/widgets/settings_section.dart';

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
    return Scaffold(
      body: AppBackground(
        child: Column(
          children: [
            const TopBar(),
            Expanded(
              child: BlocConsumer<ProfileCubit, ProfileState>(
                listener: (context, state) {
                  if (state is ProfileError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is ProfileLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  }

                  if (state is ProfileError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                          const SizedBox(height: 12),
                          Text('حدث خطأ', style: AppTextStyles.bodyLarge),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () => context.read<ProfileCubit>().loadProfile(),
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
                    final kits = state is ProfileLoaded ? state.kits : [];
                    final isKitsLoading = state is ProfileKitsLoading;

                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          ProfileHeader(
                            name: user.name,
                            email: user.email,
                            avatarUrl: user.avatarUrl ??
                                'https://api.dicebear.com/7.x/adventurer/png?seed=${user.name}',
                          ),
                          const SizedBox(height: 24),
                          ChildrenSection(
                            children: children,
                            selectedChild: selectedChild,
                          ),
                          const SizedBox(height: 24),
                          const ProfileProgressCard(
                            level: 'المستوى 3: مستكشف الطبيعة',
                            progress: 0.75,
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
                              child: CircularProgressIndicator(color: AppColors.primary),
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
                            AvailableKitsSection(kits: kits as dynamic),
                          const SizedBox(height: 24),
                          const SettingsSection(),
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              'تمكين الاكتشافات الصغيرة كل يوم ♥',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 12,
                                color: AppColors.hint,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
            const BottomNavBar(selectedIndex: 4),
          ],
        ),
      ),
    );
  }
}