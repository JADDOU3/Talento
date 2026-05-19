import 'package:flutter/material.dart';
import '../../../../shared/i18n/app_localizations.dart';
import '../../../../util/theme/app_colors.dart';
import 'kit_content_item.dart';
import 'kit_details_constants.dart';
import 'quality_badge_image.dart';

class KitWhatsInsideSection extends StatelessWidget {
  const KitWhatsInsideSection({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final twoCol = w >= 960;

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
        KitContentItem(
          icon: Icons.search_rounded,
          title: l10n.kitContent1Title,
          description: l10n.kitContent1Desc,
        ),
        KitContentItem(
          icon: Icons.menu_book_outlined,
          title: l10n.kitContent2Title,
          description: l10n.kitContent2Desc,
        ),
        KitContentItem(
          icon: Icons.layers_outlined,
          title: l10n.kitContent3Title,
          description: l10n.kitContent3Desc,
        ),
        KitContentItem(
          icon: Icons.science_outlined,
          title: l10n.kitContent4Title,
          description: l10n.kitContent4Desc,
        ),
      ],
    );

    final image = QualityBadgeImage(
      imageAsset: KitDetailsConstants.whatsInsideImage,
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
