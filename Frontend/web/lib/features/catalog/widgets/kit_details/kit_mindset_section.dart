import 'package:flutter/material.dart';
import '../../../../shared/i18n/app_localizations.dart';
import '../../../../util/theme/app_colors.dart';
import 'mindset_card.dart';

class KitMindsetSection extends StatelessWidget {
  const KitMindsetSection({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final threeCol = w >= 1000;

    final cards = [
      MindsetCard(
        icon: Icons.lightbulb_outline_rounded,
        title: l10n.mindsetCard1Title,
        body: l10n.mindsetCard1Body,
      ),
      MindsetCard(
        icon: Icons.eco_rounded,
        title: l10n.mindsetCard2Title,
        body: l10n.mindsetCard2Body,
        highlighted: true,
      ),
      MindsetCard(
        icon: Icons.biotech_rounded,
        title: l10n.mindsetCard3Title,
        body: l10n.mindsetCard3Body,
      ),
    ];

    return Column(
      children: [
        Text(
          l10n.nurturingTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.cartTeal,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 32),
        if (threeCol)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 18),
              Expanded(child: cards[1]),
              const SizedBox(width: 18),
              Expanded(child: cards[2]),
            ],
          )
        else ...[
          cards[0],
          const SizedBox(height: 16),
          cards[1],
          const SizedBox(height: 16),
          cards[2],
        ],
      ],
    );
  }
}
