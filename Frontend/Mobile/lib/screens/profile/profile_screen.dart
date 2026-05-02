import 'package:flutter/material.dart';
import 'package:mobile/screens/profile/widgets/available_kits_section.dart';
import 'package:mobile/screens/profile/widgets/children_section.dart';
import 'package:mobile/screens/profile/widgets/profile_header.dart';
import 'package:mobile/screens/profile/widgets/profile_progress_card.dart';
import 'package:mobile/screens/profile/widgets/settings_section.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_background.dart';
import '../../shared/layout/top_bar.dart';
import '../../shared/layout/bottom_nav_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Column(
          children: [
            const TopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // Profile Header
                    const ProfileHeader(
                      name: 'سارة جونسون',
                      email: 'sarah.j@family.com',
                      avatarUrl: 'https://i.pravatar.cc/150?img=47',
                    ),
                    const SizedBox(height: 24),

                    // Children Section
                    const ChildrenSection(),
                    const SizedBox(height: 24),

                    // Progress Card
                    const ProfileProgressCard(
                      level: 'المستوى 3: مستكشف الطبيعة',
                      progress: 0.75,
                    ),
                    const SizedBox(height: 24),

                    // Available Kits
                    const AvailableKitsSection(),
                    const SizedBox(height: 24),

                    // Settings
                    const SettingsSection(),
                    const SizedBox(height: 12),

                    // Footer text
                    Center(
                      child: Text(
                        'تمكين الاكتشافات الصغيرة كل يوم ',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 12,
                          color: AppColors.hint,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Bottom Nav Bar
            const BottomNavBar(selectedIndex: 4),
          ],
        ),
      ),
    );
  }
}