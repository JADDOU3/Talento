import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_background.dart';
import 'widgets/detail_stat_chip.dart';
import 'widgets/inside_item_tile.dart';
import 'widgets/skill_tag_card.dart';

class KitDetailsScreen extends StatelessWidget {
  const KitDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> skills = [
      {
        'title': 'العلوم والتقنية',
        'subtitle': 'تعلم العلوم',
        'icon': Icons.rocket_launch_rounded,
        'color': AppColors.pink,
      },
      {
        'title': 'الإبداع',
        'subtitle': 'تنمية الخيال',
        'icon': Icons.auto_awesome_rounded,
        'color': AppColors.primary,
      },
      {
        'title': 'الإدراك',
        'subtitle': 'مهارات حل المشكلات',
        'icon': Icons.psychology_alt_rounded,
        'color': AppColors.yellow,
      },
    ];

    final List<String> insideItems = [
      'علب بناء من أصل 10 مهمات',
      'ألعاب تنمو عندما نزرعها',
      'قطعة بناء فضائية',
      'دفتر تعليم مكون من 24 صفحة',
      'خريطة إشارات للملاحظات',
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: AppBackground(
          child: Column(
            children: [
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildHeroImage(),
                      const SizedBox(height: 14),
                      _buildStatsRow(),
                      const SizedBox(height: 14),
                      _buildTitleAndDescription(),
                      const SizedBox(height: 18),
                      _buildSkillsSection(skills),
                      const SizedBox(height: 22),
                      _buildInsideSection(insideItems),
                      const SizedBox(height: 28),
                      _buildBottomButton(),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          _circleIconButton(
            icon: Icons.bookmark_border_rounded,
            onTap: () {},
          ),
          Expanded(
            child: Center(
              child: Text(
                'تفاصيل الحزمة',
                style: AppTextStyles.headlineMedium.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          _circleIconButton(
            icon: Icons.arrow_forward_ios_rounded,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _circleIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        icon: Icon(
          icon,
          size: 18,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildHeroImage() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.network(
              'https://tse4.mm.bing.net/th/id/OIP.74KInUeX1czRkk9_MvVQOgHaE8?w=1000&h=667&rs=1&pid=ImgDetMain&o=7&rm=3',
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 220,
                  color: AppColors.inputFill,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.image_outlined,
                    color: AppColors.hint,
                    size: 42,
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.cardBackground.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '4.9',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.star_rounded,
                    color: AppColors.yellow,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '(124 تقييم)',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Align(
      alignment: Alignment.centerRight,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'الأعلى تقييماً',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 14),
          Text(
            '6-12',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'سنة',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 14),
          Text(
            'العمر',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleAndDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'حزمة دب مستكشف الفضاء',
            textAlign: TextAlign.right,
            style: AppTextStyles.headlineMedium.copyWith(
              fontSize: 34,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.25,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'استكشف الفضاء الرائع ابتداءً من تعلم أساسيات الرحلات إلى المجرات البعيدة. تتضمن هذه المجموعة تجارب عملية وأنشطة تعليمية مصممة لتنمية الفضول العلمي وبناء المهارات عبر محتوى ممتع يربط الخيال بالاكتشاف الحقيقي.',
            textAlign: TextAlign.right,
            style: AppTextStyles.bodyMedium.copyWith(
              height: 1.8,
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkillsSection(List<Map<String, dynamic>> skills) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        runAlignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 12,
        children: skills.map((skill) {
          return SizedBox(
            width: 140,
            child: SkillTagCard(
              title: skill['title'] as String,
              subtitle: skill['subtitle'] as String,
              icon: skill['icon'] as IconData,
              iconColor: skill['color'] as Color,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInsideSection(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'ماذا يوجد في الداخل؟',
            textAlign: TextAlign.right,
            style: AppTextStyles.headlineMedium.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 14),
        ...items.map(
              (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InsideItemTile(text: item),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(
          Icons.info_outline_rounded,
          size: 18,
          color: AppColors.white,
        ),
        label: Text(
          'مزيد من التفاصيل...',
          style: AppTextStyles.button.copyWith(
            color: AppColors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 58),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),
    );
  }
}