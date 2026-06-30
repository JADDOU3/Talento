import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/roadmap/roadmap_activity_model.dart';
import 'learning_card.dart';
import 'section_title.dart';

class CurriculumPathSection extends StatelessWidget {
  final RoadmapActivityModel activity;
  final VoidCallback onOpenRoadmap;

  const CurriculumPathSection({
    super.key,
    required this.activity,
    required this.onOpenRoadmap,
  });

  @override
  Widget build(BuildContext context) {
    final currentLevel = activity.currentLevelNumber <= 0
        ? 1
        : activity.currentLevelNumber;
    final totalLevels = activity.totalLevels <= 0 ? 1 : activity.totalLevels;
    final progress =
        (activity.completedLevels / totalLevels).clamp(0.0, 1.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionTitle(title: 'Curriculum Path'),
        const SizedBox(height: 12),
        LearningCard(
          badge: 'CURRENTLY LEARNING',
          title: activity.activityName,
          levelText: 'Lv $currentLevel / $totalLevels',
          progress: progress,
          buttonText: 'Resume Now',
          onPressed: onOpenRoadmap,
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: onOpenRoadmap,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          icon: const Icon(
            Icons.route_rounded,
            size: 18,
          ),
          label: Text(
            'Navigate to Roadmap',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}
