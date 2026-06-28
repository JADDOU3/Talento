import 'package:flutter/material.dart';
import '../cards/journey_card.dart';
import '../layout/section_heading.dart';
import '../../../util/theme/app_colors.dart';
import '../../../shared/i18n/app_localizations.dart';
class JourneySection extends StatelessWidget {
  const JourneySection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;
    final isRtl = Localizations.localeOf(context).languageCode == 'ar';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
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
      ),
    );
  }

  // Helper to build the numbered circles
  Widget _buildNumberCircle(String number) => Container(
    width: 50,
    height: 50,
    decoration: BoxDecoration(
      color: AppColors.cartTeal.withOpacity(0.1),
      shape: BoxShape.circle,
    ),
    child: Center(
      child: Text(number,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.cartTeal)
      ),
    ),
  );

  Widget _buildDesktop(AppLocalizations l10n) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Connector line placed behind cards. left/right stay symmetric so
        // it mirrors correctly under RTL without extra logic.
        Positioned(
          top: 25,
          left: 150,
          right: 150,
          child: Container(height: 2, color: AppColors.cartTeal.withOpacity(0.3)),
        ),
        Row(
          children: [
            Expanded(
              child: JourneyCard(
                iconWidget: _buildNumberCircle("1"),
                themeColor: AppColors.cartTeal,
                title: l10n.journeyStep1Title,
                description: l10n.journeyStep1Desc,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: JourneyCard(
                iconWidget: _buildNumberCircle("2"),
                themeColor: AppColors.cartTeal,
                title: l10n.journeyStep2Title,
                description: l10n.journeyStep2Desc,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: JourneyCard(
                iconWidget: _buildNumberCircle("3"),
                themeColor: AppColors.cartTeal,
                title: l10n.journeyStep3Title,
                description: l10n.journeyStep3Desc,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobile(AppLocalizations l10n) {
    return Column(
      children: [
        JourneyCard(
          iconWidget: _buildNumberCircle("1"),
          themeColor: AppColors.cartTeal,
          title: l10n.journeyStep1Title,
          description: l10n.journeyStep1DescShort,
        ),
        const SizedBox(height: 40),
        JourneyCard(
          iconWidget: _buildNumberCircle("2"),
          themeColor: AppColors.cartTeal,
          title: l10n.journeyStep2Title,
          description: l10n.journeyStep2DescShort,
        ),
        const SizedBox(height: 40),
        JourneyCard(
          iconWidget: _buildNumberCircle("3"),
          themeColor: AppColors.cartTeal,
          title: l10n.journeyStep3Title,
          description: l10n.journeyStep3DescShort,
        ),
      ],
    );
  }
}