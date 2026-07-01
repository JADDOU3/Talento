import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../cubits/community/community_filter_cubit.dart';
import '../../../cubits/community/community_filter_state.dart';
import '../../../models/kit/kit_model.dart';
import '../../../models/kit/mindset_model.dart';
import 'category_chip.dart';

class CommunityFilterSection extends StatelessWidget {
  final int? selectedMindsetId;
  final int? selectedKitId;
  final CommunityFilterType activeFilterType;
  final VoidCallback onDefaultMindsetSelected;
  final VoidCallback onAllKitsSelected;
  final ValueChanged<MindsetModel> onMindsetSelected;
  final ValueChanged<KitModel> onKitSelected;

  const CommunityFilterSection({
    super.key,
    required this.selectedMindsetId,
    required this.selectedKitId,
    required this.activeFilterType,
    required this.onDefaultMindsetSelected,
    required this.onAllKitsSelected,
    required this.onMindsetSelected,
    required this.onKitSelected,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CommunityFilterCubit, CommunityFilterState>(
      builder: (context, state) {
        if (state is CommunityFilterLoading ||
            state is CommunityFilterInitial) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(minHeight: 3),
          );
        }

        if (state is CommunityFilterError) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.86),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.65),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.red,
                  size: 19,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'تعذر تحميل الفلاتر',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      context.read<CommunityFilterCubit>().loadFilters(),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        if (state is CommunityFilterLoaded) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _HorizontalChipRow(
                children: [
                  CategoryChip(
                    label: 'مستوراتي',
                    isSelected: activeFilterType == CommunityFilterType.none,
                    onTap: onDefaultMindsetSelected,
                  ),
                  ...state.mindsets.map(
                    (mindset) => CategoryChip(
                      label: mindset.name,
                      isSelected: activeFilterType ==
                              CommunityFilterType.mindset &&
                          selectedMindsetId == mindset.id,
                      onTap: () => onMindsetSelected(mindset),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _HorizontalChipRow(
                children: [
                  CategoryChip(
                    label: 'الكل',
                    isSelected: activeFilterType == CommunityFilterType.kitAll,
                    onTap: onAllKitsSelected,
                  ),
                  ...state.kits.map(
                    (kit) => CategoryChip(
                      label: kit.name,
                      isSelected: activeFilterType == CommunityFilterType.kit &&
                          selectedKitId == kit.id,
                      onTap: () => onKitSelected(kit),
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _HorizontalChipRow extends StatelessWidget {
  final List<Widget> children;

  const _HorizontalChipRow({required this.children});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: children.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) => children[index],
      ),
    );
  }
}

enum CommunityFilterType {
  none,
  mindset,
  kitAll,
  kit,
}
