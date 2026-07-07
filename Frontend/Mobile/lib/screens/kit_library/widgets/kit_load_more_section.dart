import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class KitLoadMoreSection extends StatelessWidget {
  final bool hasMore;
  final bool isLoadingMore;
  final String? loadMoreError;
  final VoidCallback onLoadMore;

  const KitLoadMoreSection({
    super.key,
    required this.hasMore,
    required this.isLoadingMore,
    required this.loadMoreError,
    required this.onLoadMore,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasMore && loadMoreError == null) {
      return const SizedBox.shrink();
    }

    if (isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2.4),
          ),
        ),
      );
    }

    if (loadMoreError != null) {
      return Column(
        children: [
          Text(
            loadMoreError!,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.error,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          _LoadMoreButton(onTap: onLoadMore),
        ],
      );
    }

    return _LoadMoreButton(onTap: onLoadMore);
  }
}

class _LoadMoreButton extends StatelessWidget {
  final VoidCallback onTap;

  const _LoadMoreButton({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.11),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.18),
              ),
            ),
            child: Center(
              child: Text(
                'تحميل المزيد',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
