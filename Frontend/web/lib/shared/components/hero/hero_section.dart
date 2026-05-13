import 'package:flutter/material.dart';
import '../buttons/primary_button.dart';
import '../../../util/theme/app_text_styles.dart';
import '../../i18n/app_localizations.dart';

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      child: width >= 768 ? _buildDesktop(context, l10n) : _buildMobile(context, l10n),
    );
  }

  Widget _buildDesktop(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 60),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l10n.heroBadge,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.heading.copyWith(
                      fontSize: 72,
                      height: 1.05,
                      color: Colors.black,
                    ),
                    children: [
                      TextSpan(text: "${l10n.heroTitle1}\n"),
                      TextSpan(
                        text: "${l10n.heroTitle2}\n",
                        style: const TextStyle(color: Color(0xFFFF6B6B)),
                      ),
                      TextSpan(text: l10n.heroTitle3),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.heroDesc,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    height: 1.65,
                  ),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    _PrimaryButtonSized(text: l10n.heroExplore),
                    const SizedBox(width: 16),
                    _SecondaryButton(text: l10n.heroLearn),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            flex: 5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Image.asset(
                "assets/images/hero.png",
                width: double.infinity,
                height: 480,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobile(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              l10n.heroBadge,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                height: 1.1,
                color: Colors.black,
              ),
              children: [
                TextSpan(text: "${l10n.heroTitle1}\n"),
                TextSpan(
                  text: "${l10n.heroTitle2}\n",
                  style: const TextStyle(color: Color(0xFFFF6B6B)),
                ),
                TextSpan(text: l10n.heroTitle3),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            l10n.heroDesc,
            style: const TextStyle(fontSize: 15, color: Colors.grey, height: 1.6),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _PrimaryButtonSized(text: l10n.heroExplore),
              const SizedBox(width: 12),
              _SecondaryButton(text: l10n.heroLearn),
            ],
          ),
          const SizedBox(height: 32),
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              "assets/images/hero.png",
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryButtonSized extends StatelessWidget {
  final String text;
  const _PrimaryButtonSized({required this.text});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF18A97A),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        elevation: 0,
      ),
      onPressed: () => Navigator.pushNamed(context, '/catalog'),
      child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String text;
  const _SecondaryButton({required this.text});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
        side: const BorderSide(color: Colors.orange),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
      onPressed: () {},
      child: Text(text, style: const TextStyle(color: Colors.orange, fontSize: 16)),
    );
  }
}