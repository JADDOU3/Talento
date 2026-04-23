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

  const KitDetailsScreen({super.key, required this.kitId});

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

  const _KitDetailsView({required this.kitId});

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
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 48,
                          color: AppColors.hint,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed:
                              () => context.read<KitCubit>().getKitById(kitId),
                          child: const Text('إعادة المحاولة'),
                        ),
                      ],
                    ),
                  ),
                );
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
                            _buildHeroImage(kit.imageUrl),
                            const SizedBox(height: 14),
                            _buildLabelsRow(kit.type, kit.mindset),
                            const SizedBox(height: 14),
                            _buildTitleAndDescription(
                              kit.name,
                              kit.description,
                            ),
                            const SizedBox(height: 22),
                            _buildInsideSection(kit.kitItems),
                            const SizedBox(height: 28),
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
        icon: Icon(icon, size: 18, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildHeroImage(String imageUrl) {
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Image.network(
          imageUrl,
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
    );
  }

  Widget _buildLabelsRow(String type, String mindset) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        _buildLabelChip(type),
        _buildLabelChip(mindset),
      ],
    );
  }

  Widget _buildLabelChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w700,
        ),
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
              fontSize: 30,
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
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (items.isEmpty)
          Text(
            'لا توجد عناصر متاحة لهذه الحزمة.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
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
}