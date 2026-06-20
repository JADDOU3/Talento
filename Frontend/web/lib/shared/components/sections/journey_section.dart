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

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              const SectionHeading(
                title: "The Talento Path",
                subtitle: "A science-backed journey for ages 4-7",
              ),
              const SizedBox(height: 60),
              width >= 768 ? _buildDesktop() : _buildMobile(),
            ],
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

  Widget _buildDesktop() {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        // Connector Line placed behind cards
        Positioned(
          top: 25,
          left: 150,
          right: 150,
          child: Container(height: 2, color: AppColors.cartTeal.withOpacity(0.3)),
        ),
        Row(
          children: [
            Expanded(child: JourneyCard(iconWidget: _buildNumberCircle("1"), themeColor: AppColors.cartTeal, title: "Discover Mindset", description: "AI-powered analysis of natural curiosities and cognitive patterns through interactive play.")),
            const SizedBox(width: 24),
            Expanded(child: JourneyCard(iconWidget: _buildNumberCircle("2"), themeColor: AppColors.cartTeal, title: "Explore Hobbies", description: "Customized exploration kits delivered monthly, tailored specifically to their detected mindset.")),
            const SizedBox(width: 24),
            Expanded(child: JourneyCard(iconWidget: _buildNumberCircle("3"), themeColor: AppColors.cartTeal, title: "Develop Talent", description: "Structured challenges and guidance focused on turning potential into lifelong mastery.")),
          ],
        ),
      ],
    );
  }

  Widget _buildMobile() {
    return Column(
      children: [
        JourneyCard(iconWidget: _buildNumberCircle("1"), themeColor: AppColors.cartTeal, title: "Discover Mindset", description: "AI-powered analysis of natural curiosities."),
        const SizedBox(height: 40),
        JourneyCard(iconWidget: _buildNumberCircle("2"), themeColor: AppColors.cartTeal, title: "Explore Hobbies", description: "Customized exploration kits delivered monthly."),
        const SizedBox(height: 40),
        JourneyCard(iconWidget: _buildNumberCircle("3"), themeColor: AppColors.cartTeal, title: "Develop Talent", description: "Structured challenges and lifelong mastery."),
      ],
    );
  }
}