import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../cubits/kit/kit_cubit.dart';
import '../../cubits/kit/kit_state.dart';
import '../../services/kit_service.dart';
import '../../shared/widgets/app_background.dart';
import 'widgets/inside_item_tile.dart';

class KitDetailsScreen extends StatelessWidget {
  final int kitId;

  const KitDetailsScreen({
    super.key,
    required this.kitId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => KitCubit(KitService())..getKitById(kitId),
      child: _KitDetailsView(kitId: kitId),
    );
  }
}

class _KitDetailsView extends StatelessWidget {
  final int kitId;

  const _KitDetailsView({
    required this.kitId,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: AppBackground(
          child: BlocBuilder<KitCubit, KitState>(
            builder: (context, state) {
              if (state is KitLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is KitError) {
                return _buildErrorState(context, state.message);
              }

              if (state is KitDetailsLoaded) {
                final kit = state.kit;

                return Column(
                  children: [
                    _buildHeader(context),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildHeroImage(
                              imageUrl: kit.imageUrl,
                              rating: kit.rating,
                            ),
                            const SizedBox(height: 16),

                            // ✅ الاسم والوصف طلعوا فوق
                            _buildTitleAndDescription(
                              kit.name,
                              kit.description,
                            ),

                            const SizedBox(height: 16),

                            // ✅ المربعات صارت تحتهم
                            _buildStatsRow(
                              age: kit.age,
                              rating: kit.rating,
                              mindset: kit.mindset,
                            ),

                            const SizedBox(height: 26),

                            _buildInsideSection(kit.kitItems),

                            const SizedBox(height: 30),

                            _buildBottomButton(),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Row(
        children: [
          _circleIconButton(
            icon: Icons.arrow_forward_ios_rounded,
            onTap: () => Navigator.pop(context),
          ),
          Expanded(
            child: Center(
              child: Text(
                'تفاصيل الحزمة',
                style: AppTextStyles.headlineMedium.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 38),
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
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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

  Widget _buildHeroImage({
    required String imageUrl,
    required double rating,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: imageUrl.isEmpty
                ? _imagePlaceholder()
                : Image.network(
              imageUrl,
              width: double.infinity,
              height: 240,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _imagePlaceholder(),
            ),
          ),
          Positioned(
            top: 14,
            left: 14,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.cardBackground.withValues(alpha: 0.95),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star_rounded,
                    color: AppColors.yellow,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    rating.toStringAsFixed(1),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
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

  Widget _imagePlaceholder() {
    return Container(
      width: double.infinity,
      height: 240,
      color: AppColors.inputFill,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        color: AppColors.hint,
        size: 46,
      ),
    );
  }

  Widget _buildStatsRow({
    required int age,
    required double rating,
    required String mindset,
  }) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            icon: Icons.child_care_rounded,
            title: 'العمر',
            value: age > 0 ? '$age سنوات' : 'غير محدد',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statCard(
            icon: Icons.flag_rounded,
            title: 'المهمات',
            value: ' مهمات',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _statCard(
            icon: Icons.auto_awesome_rounded,
            title: 'النمط',
            value: _mindsetArabic(mindset),
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.red,
            size: 21,
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleAndDescription(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            title,
            textAlign: TextAlign.right,
            style: AppTextStyles.headlineMedium.copyWith(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              height: 1.25,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            description,
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
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (items.isEmpty)
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'لا توجد عناصر متاحة لهذه الحزمة.',
              textAlign: TextAlign.right,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          )
        else
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
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
        ),
        child: Text(
          'مزيد من التفاصيل',
          style: AppTextStyles.button.copyWith(
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 52,
              color: AppColors.hint,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.read<KitCubit>().getKitById(kitId),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  String _mindsetArabic(String mindset) {
    switch (mindset.toUpperCase()) {
      case 'BUILDER':
        return 'البنّاء';
      case 'SCIENTIST':
        return 'العالِم';
      case 'EXPLORER':
        return 'المستكشف';
      case 'INVENTOR':
        return 'المخترع';
      default:
        return mindset.isEmpty ? 'غير محدد' : mindset;
    }
  }
}