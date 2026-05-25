import 'package:flutter/material.dart';
import '../../../../shared/i18n/app_localizations.dart';
import '../../../../shared/models/kit_model.dart';
import '../../../../util/theme/app_colors.dart';
import 'mindset_card.dart';

class KitMindsetSection extends StatelessWidget {
  const KitMindsetSection({
    super.key,
    required this.l10n,
    required this.criteria,
    this.placeholderBody,
  });

  final AppLocalizations l10n;
  final List<CriteriaModel> criteria;
  final String? placeholderBody;

  static const _icons = [
    Icons.lightbulb_outline_rounded,
    Icons.eco_rounded,
    Icons.biotech_rounded,
    Icons.psychology_outlined,
    Icons.school_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    if (criteria.isEmpty) return const SizedBox.shrink();

    final w = MediaQuery.sizeOf(context).width;
    final threeCol = w >= 1000;
    final body = placeholderBody ?? l10n.mindsetCriteriaPlaceholder;

    final cards = List.generate(criteria.length, (i) {
      final highlight = criteria.length >= 3
          ? i == 1
          : i == criteria.length ~/ 2;
      return MindsetCard(
        icon: _icons[i % _icons.length],
        title: criteria[i].name,
        body: body,
        highlighted: highlight,
      );
    });

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
        if (threeCol && cards.length >= 3)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(width: 18),
                Expanded(child: cards[i]),
              ],
            ],
          )
        else ...[
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            cards[i],
          ],
        ],
      ],
    );
  }
}
