import 'package:flutter/material.dart';

import '../../../models/roadmap/roadmap_activity_model.dart';
import 'learning_card.dart';

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
    final currentLevel =
    activity.currentLevelNumber <= 0 ? 1 : activity.currentLevelNumber;

    final totalLevels = activity.totalLevels <= 0 ? 1 : activity.totalLevels;

    final progress = (currentLevel / totalLevels).clamp(0.0, 1.0).toDouble();

    return LearningCard(
      badge: 'النشاط الحالي',
      title: activity.activityName,
      levelText: 'المستوى $currentLevel / $totalLevels',
      progress: progress,
      buttonText: 'متابعة الآن',
      mascotAssetPath: 'assets/images/curriculum_path_mascot.png',
      onPressed: onOpenRoadmap,
    );
  }
}