import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/kit/kit_model.dart';

class AvailableKitsSection extends StatelessWidget {
  final List<KitModel> kits;
  final VoidCallback? onAddKitTap;

  const AvailableKitsSection({
    super.key,
    this.kits = const [],
    this.onAddKitTap,
  });

  @override
  Widget build(BuildContext context) {
    final itemCount = kits.length + (onAddKitTap == null ? 0 : 1);

    if (itemCount == 0) {
      return _EmptyKitsCard(onAddKitTap: onAddKitTap);
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.92,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (onAddKitTap != null && index == kits.length) {
          return _AddKitCard(onTap: onAddKitTap!);
        }

        final kit = kits[index];
        final colors = [
          AppColors.primary,
          AppColors.secondary,
          AppColors.pink,
          AppColors.yellow,
        ];
        final color = colors[index % colors.length];

        return _KitCard(
          name: kit.name,
          imageUrl: kit.imageUrl,
          color: color,
        );
      },
    );
  }
}

class _KitCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final Color color;

  const _KitCard({
    required this.name,
    required this.imageUrl,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            color.withValues(alpha: 0.14),
            AppColors.white.withValues(alpha: 0.94),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: color.withValues(alpha: 0.24),
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(18),
              ),
              clipBehavior: Clip.antiAlias,
              child: imageUrl.trim().isNotEmpty
                  ? Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.inventory_2_rounded,
                  color: color,
                  size: 48,
                ),
              )
                  : Icon(
                Icons.inventory_2_rounded,
                color: color,
                size: 48,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontSize: 14,
              height: 1.2,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddKitCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AddKitCard({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.24),
              width: 1.3,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: AppColors.primary,
                  size: 30,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'إضافة حقيبة',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyKitsCard extends StatelessWidget {
  final VoidCallback? onAddKitTap;

  const _EmptyKitsCard({
    this.onAddKitTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.inventory_2_outlined,
            color: AppColors.primary,
            size: 38,
          ),
          const SizedBox(height: 10),
          Text(
            'لا توجد حقائب نشطة بعد',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          if (onAddKitTap != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onAddKitTap,
              icon: const Icon(Icons.add_rounded),
              label: const Text('إضافة حقيبة'),
            ),
          ],
        ],
      ),
    );
  }
}
