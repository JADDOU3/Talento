import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../cubits/child_mode/child_mode_cubit.dart';
import '../../../cubits/coins/coins_cubit.dart';
import '../../../services/auth/auth_service.dart';
import '../../auth/login_screen.dart';
import '../account_info_page.dart';
import '../general_settings_page.dart';

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key});

  Future<void> _logout(BuildContext context) async {
    context.read<ChildModeCubit>().reset();
    context.read<CoinsCubit>().reset();

    await AuthService().logout();

    if (!context.mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _SettingsTile(
            title: 'معلومات الحساب',
            subtitle: 'بياناتك ومعلومات التواصل',
            icon: Icons.person_outline_rounded,
            color: AppColors.primary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AccountInfoPage(),
                ),
              );
            },
          ),
          const _SettingsDivider(),
          _SettingsTile(
            title: 'الإعدادات العامة',
            subtitle: 'تفضيلات التطبيق والإشعارات',
            icon: Icons.tune_rounded,
            color: AppColors.secondary,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const GeneralSettingsPage(),
                ),
              );
            },
          ),
          const _SettingsDivider(),
          _SettingsTile(
            title: 'تسجيل الخروج',
            subtitle: 'الخروج من الحساب الحالي',
            icon: Icons.logout_rounded,
            color: AppColors.red,
            isLogout: true,
            onTap: () => _logout(context),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isLogout;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: isLogout ? AppColors.red : AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 15,
              color: isLogout
                  ? AppColors.red.withValues(alpha: 0.70)
                  : AppColors.textSecondary.withValues(alpha: 0.60),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  const _SettingsDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 16,
      endIndent: 70,
      color: AppColors.border.withValues(alpha: 0.85),
    );
  }
}
