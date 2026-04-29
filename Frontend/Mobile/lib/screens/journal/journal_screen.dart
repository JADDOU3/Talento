import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/layout/bottom_nav_bar.dart';

class JournalScreen extends StatelessWidget {
  const JournalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 18),
                      _buildPerformanceCard(),
                      const SizedBox(height: 18),
                      _buildWeeklyInsights(),
                      const SizedBox(height: 18),
                      _buildAchievementCard(),
                      const SizedBox(height: 18),
                      _buildAhaCard(),
                      const SizedBox(height: 14),
                      _buildStatsSection(),
                    ],
                  ),
                ),
              ),
              const BottomNavBar(selectedIndex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اليوميات',
            style: AppTextStyles.headlineLarge.copyWith(
              fontSize: 30,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.18),
                  blurRadius: 14,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppColors.white,
                  size: 22,
                ),
                const SizedBox(width: 6),
                Text(
                  'الأسبوع الحالي',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard() {
    final items = [
      _SkillProgress('البنّاء', 0.78, AppColors.primary),
      _SkillProgress('العالم', 0.64, AppColors.pink),
      _SkillProgress('المستكشف', 0.82, AppColors.secondary),
      _SkillProgress('المخترع', 0.55, AppColors.yellow),
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(
        color: const Color(0xFFFFF3F6),
        borderColor: AppColors.pink.withOpacity(0.08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('بطاقة أداء المهارات'),
          const SizedBox(height: 4),
          Text(
            'بناء على أدائك الأسبوعي',
            style: AppTextStyles.bodyMedium.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 18),
          ...items.map(_skillRow),
        ],
      ),
    );
  }

  Widget _skillRow(_SkillProgress item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                item.name,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Text(
                '${(item.value * 100).round()}%',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: item.color,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: item.value,
              minHeight: 7,
              backgroundColor: AppColors.white,
              valueColor: AlwaysStoppedAnimation<Color>(item.color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyInsights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('استكشافاتك الأسبوعية'),
        const SizedBox(height: 10),
        Container(
          height: 145,
          padding: const EdgeInsets.all(16),
          decoration: _cardDecoration(
            color: const Color(0xFFEFFFFB),
            borderColor: AppColors.primary.withOpacity(0.08),
          ),
          child: Align(
            alignment: Alignment.topRight,
            child: Text(
              'سيتم عرض استكشافاتك الأسبوعية هنا قريباً',
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 12,
                color: AppColors.hint,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.22),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Icon(
              Icons.track_changes_rounded,
              color: AppColors.white.withOpacity(0.9),
              size: 28,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '84%',
            style: AppTextStyles.headlineLarge.copyWith(
              color: AppColors.white,
              fontSize: 38,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'معدل الإنجاز العام',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'تحسن عن الأسبوع الماضي +12%',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.white.withOpacity(0.86),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAhaCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(
        color: AppColors.cardBackground,
        borderColor: AppColors.border,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconBubble(Icons.auto_awesome_rounded, AppColors.pink),
              const SizedBox(width: 10),
              _sectionTitle('لحظات "Aha!"'),
            ],
          ),
          const SizedBox(height: 14),
          _insightLine(
            icon: Icons.psychology_alt_rounded,
            color: AppColors.primary,
            title: 'اكتشفت نمط الطفل الهندسي',
            description:
            'لاحظنا اهتماماً واضحاً بالتجارب التي تعتمد على التركيب والبناء وحل المشكلات.',
          ),
          const SizedBox(height: 12),
          _insightLine(
            icon: Icons.lightbulb_outline_rounded,
            color: AppColors.pink,
            title: 'قفزة إبداعية جديدة',
            description:
            'بدأ الطفل يقترح حلولاً خاصة به بدل اتباع الخطوات فقط.',
          ),
        ],
      ),
    );
  }

  Widget _insightLine({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _smallDot(icon, color),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                description,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 11.5,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Column(
      children: [
        _statCard(
          icon: Icons.lightbulb_outline_rounded,
          iconColor: AppColors.primary,
          background: const Color(0xFFEFFFFB),
          title: 'المعدل اليومي',
          description: 'متوسط التفاعل اليومي: 10 - 15 دقيقة.',
        ),
        const SizedBox(height: 12),
        _statCard(
          icon: Icons.travel_explore_rounded,
          iconColor: AppColors.pink,
          background: const Color(0xFFFFF3F6),
          title: 'نسبة الاستكشاف',
          description: 'اهتمام واضح بالتجارب الجديدة والأنشطة المتنوعة.',
        ),
        const SizedBox(height: 12),
        _statCard(
          icon: Icons.trending_up_rounded,
          iconColor: AppColors.secondary,
          background: const Color(0xFFEFFFFB),
          title: 'معدل الاستقلالية',
          description: 'قدرة أفضل على تنفيذ الخطوات بدون مساعدة مباشرة.',
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required Color iconColor,
    required Color background,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: _cardDecoration(
        color: background,
        borderColor: iconColor.withOpacity(0.08),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _iconBubble(icon, iconColor),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: iconColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 12,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: AppTextStyles.bodyLarge.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w900,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _iconBubble(IconData icon, Color color) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.13),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(icon, color: color, size: 23),
    );
  }

  Widget _smallDot(IconData icon, Color color) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 15),
    );
  }

  BoxDecoration _cardDecoration({
    required Color color,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: borderColor ?? Colors.transparent,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.black.withOpacity(0.035),
          blurRadius: 16,
          offset: const Offset(0, 7),
        ),
      ],
    );
  }
}

class _SkillProgress {
  final String name;
  final double value;
  final Color color;

  const _SkillProgress(this.name, this.value, this.color);
}