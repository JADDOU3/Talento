import 'package:flutter/material.dart';
import '../cards/journey_card.dart';
import '../layout/section_heading.dart';
import '../../../util/theme/app_colors.dart';

class JourneySection extends StatelessWidget {
  const JourneySection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              // 🔥 Heading
              const SectionHeading(
                title: "How Your Journey Begins",
                subtitle:
                    "We simplify the science of learning into three organic steps for families.",
              ),

              const SizedBox(height: 60),

              // 🔥 Cards
              width >= 768 ? _buildDesktop() : _buildMobile(),
            ],
          ),
        ),
      ),
    );
  }

  // ================= DESKTOP =================
  Widget _buildDesktop() {
    return Row(
      children: const [
        Expanded(
          child: JourneyCard(
            icon: Icons.search,
            iconColor: AppColors.teal,
            title: "Select Your Theme",
            description:
                "Choose from Biology, Engineering, or Fine Arts curated for specific age milestones.",
          ),
        ),
        SizedBox(width: 24),
        Expanded(
          child: JourneyCard(
            icon: Icons.inventory_2_outlined,
            iconColor: AppColors.pink,
            title: "Delivered Monthly",
            description:
                "Eco-friendly kits arrive at your doorstep packed with everything needed for discovery.",
          ),
        ),
        SizedBox(width: 24),
        Expanded(
          child: JourneyCard(
            icon: Icons.auto_awesome,
            iconColor: AppColors.yellow,
            title: "Guided Exploration",
            description:
                "Interactive guides help parents and kids bond over experiments and storytelling.",
          ),
        ),
      ],
    );
  }

  // ================= MOBILE =================
  Widget _buildMobile() {
    return const Column(
      children: [
        JourneyCard(
          icon: Icons.search,
          iconColor: AppColors.teal,
          title: "Select Your Theme",
          description:
              "Choose from Biology, Engineering, or Fine Arts curated for specific age milestones.",
        ),
        SizedBox(height: 20),
        JourneyCard(
          icon: Icons.inventory_2_outlined,
          iconColor: AppColors.pink,
          title: "Delivered Monthly",
          description:
              "Eco-friendly kits arrive at your doorstep packed with everything needed for discovery.",
        ),
        SizedBox(height: 20),
        JourneyCard(
          icon: Icons.auto_awesome,
          iconColor: AppColors.yellow,
          title: "Guided Exploration",
          description:
              "Interactive guides help parents and kids bond over experiments and storytelling.",
        ),
      ],
    );
  }
}