import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

import '../../../core/theme/app_text_styles.dart';


class QuickActions extends StatelessWidget {
    const QuickActions({super.key});
    @override
    Widget build(BuildContext context) {
    final actions = [
    {'label': 'دروس', 'icon': Icons.school_rounded, 'color': AppColors.primary},
    {'label': 'مجلة', 'icon': Icons.edit_note_rounded, 'color': AppColors.pink},
    {'label': 'قصص', 'icon': Icons.auto_stories_rounded, 'color': AppColors.yellow},
    {'label': 'أنشطة', 'icon': Icons.sports_esports_rounded, 'color': AppColors.secondary},
    ];

    return Row(
    mainAxisAlignment: MainAxisAlignment.spaceAround,
    children: actions.map((action) {
    final color = action['color'] as Color;
    return Column(
    children: [
    Container(
    width: 60,
    height: 60,
    decoration: BoxDecoration(
    color: color.withValues(alpha: 0.12),
    shape: BoxShape.circle,
    ),
    child: Icon(
    action['icon'] as IconData,
    color: color,
    size: 28,
    ),
    ),
    const SizedBox(height: 6),
    Text(
    action['label'] as String,
    style: AppTextStyles.bodyMedium.copyWith(
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w600,
           ),
          ),
         ],
        );
       }).toList(),
      );
     }
    }