import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';


class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'title': 'معلومات الحساب',
        'icon': Icons.person_outline_rounded,
        'color': AppColors.primary,
        'isLogout': false,
      },
      {
        'title': 'الإعدادات العامة',
        'icon': Icons.settings_outlined,
        'color': AppColors.textSecondary,
        'isLogout': false,
      },
      {
        'title': 'تسجيل الخروج',
        'icon': Icons.logout_rounded,
        'color': AppColors.red,
        'isLogout': true,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الإعدادات',
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isLogout = item['isLogout'] as bool;
              final color = item['color'] as Color;
              final isLast = i == items.length - 1;

              return Column(
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              item['icon'] as IconData,
                              color: color,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item['title'] as String,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: isLogout
                                    ? AppColors.red
                                    : AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: isLogout
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: isLogout
                                ? AppColors.red
                                : AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isLast)
                    const Divider(
                      height: 1,
                      indent: 66,
                      color: AppColors.border,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}