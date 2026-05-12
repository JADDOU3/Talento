import 'package:flutter/material.dart';
import '../../../shared/i18n/app_localizations.dart';
import '../../../util/theme/app_colors.dart';

class BeyondSection extends StatelessWidget {
  const BeyondSection({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      color: const Color(0xFFF5F5F0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: width >= 768 ? 40 : 20,
              vertical: 60,
            ),
            child: width >= 768 ? _buildDesktop(context) : _buildMobile(context),
          ),
        ),
      ),
    );
  }

  Widget _buildDesktop(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _ImageGrid(mobile: false)),
        const SizedBox(width: 60),
        Expanded(child: _content(context)),
      ],
    );
  }

  Widget _buildMobile(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _content(context),
        const SizedBox(height: 40),
        const _ImageGrid(mobile: true),
      ],
    );
  }

  Widget _content(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.pink.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            l10n.beyondBadge,
            style: const TextStyle(
              color: AppColors.pink,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          l10n.beyondTitle,
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 30),
        _FeatureItem(
          icon: Icons.psychology_outlined,
          color: AppColors.teal,
          title: l10n.beyondFeature1Title,
          description: l10n.beyondFeature1Desc,
        ),
        const SizedBox(height: 20),
        _FeatureItem(
          icon: Icons.eco_outlined,
          color: Colors.blue,
          title: l10n.beyondFeature2Title,
          description: l10n.beyondFeature2Desc,
        ),
        const SizedBox(height: 20),
        _FeatureItem(
          icon: Icons.lightbulb_outline,
          color: AppColors.yellow,
          title: l10n.beyondFeature3Title,
          description: l10n.beyondFeature3Desc,
        ),
      ],
    );
  }
}

class _ImageGrid extends StatelessWidget {
  final bool mobile;
  const _ImageGrid({required this.mobile});

  @override
  Widget build(BuildContext context) {
    if (mobile) {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _img("assets/images/img1.jpg")),
              const SizedBox(width: 12),
              Expanded(child: _img("assets/images/img3.jpg")),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _img("assets/images/img2.jpg")),
              const SizedBox(width: 12),
              Expanded(child: _img("assets/images/img4.jpg")),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _img("assets/images/img1.jpg"),
              const SizedBox(height: 20),
              _img("assets/images/img2.jpg"),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            children: [
              _img("assets/images/img3.jpg"),
              const SizedBox(height: 20),
              _img("assets/images/img4.jpg"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _img(String path) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        path,
        fit: BoxFit.cover,
        width: double.infinity,
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: const TextStyle(color: Colors.grey, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}