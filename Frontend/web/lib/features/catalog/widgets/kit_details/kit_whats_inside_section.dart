import 'package:flutter/material.dart';
import '../../../../shared/i18n/app_localizations.dart';
import '../../../../util/theme/app_colors.dart';
import 'kit_content_item.dart';
import 'quality_badge_image.dart';

class KitWhatsInsideSection extends StatelessWidget {
  const KitWhatsInsideSection({
    super.key,
    required this.l10n,
    required this.items,
    required this.imageUrl,
    this.fallbackImageAsset,
    this.itemDescriptionPlaceholder,
  });

  final AppLocalizations l10n;
  final List<String> items;
  final String imageUrl;
  final String? fallbackImageAsset;
  final String? itemDescriptionPlaceholder;

  static const _icons = [
    Icons.search_rounded,
    Icons.menu_book_outlined,
    Icons.layers_outlined,
    Icons.science_outlined,
    Icons.build_outlined,
    Icons.inventory_2_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    final w = MediaQuery.sizeOf(context).width;
    final twoCol = w >= 960;
    final desc = itemDescriptionPlaceholder ?? l10n.kitContentItemPlaceholder;

    final list = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.whatsInsideTitle,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.cartTeal,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 28),
        for (var i = 0; i < items.length; i++)
          KitContentItem(
            icon: _icons[i % _icons.length],
            title: items[i],
            description: desc,
          ),
      ],
    );

    final image = QualityBadgeImage(
      imageUrl: imageUrl,
      imageAsset: fallbackImageAsset,
      badgeTitle: l10n.partnerQuality,
      badgeSubtitle: l10n.partnerQualitySubtitle,
    );

    if (twoCol) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 48, child: list),
          const SizedBox(width: 36),
          Expanded(flex: 52, child: image),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        list,
        const SizedBox(height: 28),
        image,
      ],
    );
  }
}
