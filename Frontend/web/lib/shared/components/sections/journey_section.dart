import 'package:flutter/material.dart';
import '../cards/journey_card.dart';
import '../layout/section_heading.dart';
import '../../../util/theme/app_colors.dart';
import '../../i18n/app_localizations.dart';

class JourneySection extends StatelessWidget {
  const JourneySection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              SectionHeading(
                title: l10n.journeyTitle,
                subtitle: l10n.journeySubtitle,
              ),
              const SizedBox(height: 60),
              width >= 768 ? _buildDesktop(l10n) : _buildMobile(l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktop(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(child: JourneyCard(icon: Icons.search, iconColor: AppColors.teal, title: l10n.journeyCard1Title, description: l10n.journeyCard1Desc)),
        const SizedBox(width: 24),
        Expanded(child: JourneyCard(icon: Icons.inventory_2_outlined, iconColor: AppColors.pink, title: l10n.journeyCard2Title, description: l10n.journeyCard2Desc)),
        const SizedBox(width: 24),
        Expanded(child: JourneyCard(icon: Icons.auto_awesome, iconColor: AppColors.yellow, title: l10n.journeyCard3Title, description: l10n.journeyCard3Desc)),
      ],
    );
  }

  Widget _buildMobile(AppLocalizations l10n) {
    return Column(
      children: [
        JourneyCard(icon: Icons.search, iconColor: AppColors.teal, title: l10n.journeyCard1Title, description: l10n.journeyCard1Desc),
        const SizedBox(height: 20),
        JourneyCard(icon: Icons.inventory_2_outlined, iconColor: AppColors.pink, title: l10n.journeyCard2Title, description: l10n.journeyCard2Desc),
        const SizedBox(height: 20),
        JourneyCard(icon: Icons.auto_awesome, iconColor: AppColors.yellow, title: l10n.journeyCard3Title, description: l10n.journeyCard3Desc),
      ],
    );
  }
}