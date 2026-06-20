import 'package:flutter/material.dart';
import '../buttons/primary_button.dart';
import '../../../util/theme/app_colors.dart';
import '../../../util/theme/app_text_styles.dart';
import '../../../shared/i18n/app_localizations.dart';

class HeroSection extends StatefulWidget {
  const HeroSection({super.key});

  @override
  State<HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<HeroSection> with TickerProviderStateMixin {
  // We keep controllers to maintain the "floating" feeling
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 768;

    return SizedBox(
      height: size.height,
      width: double.infinity,
      child: Stack(
        children: [
          // 1. Background Image
          Positioned.fill(
            child: Image.asset("assets/images/hero.png", fit: BoxFit.cover),
          ),

          // 2. Dark Overlay for Contrast
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),

          // 3. Content
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 60 : 20),
              child: isDesktop
                  ? Align(alignment: Alignment.centerLeft, child: SizedBox(width: 600, child: _buildContent(context, l10n, 64)))
                  : _buildContent(context, l10n, 42),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n, double titleSize) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildBadge(l10n.heroBadge),
      const SizedBox(height: 24),
      _buildTitle(l10n, titleSize),
      const SizedBox(height: 20),
      Text(l10n.heroDesc, style: const TextStyle(fontSize: 18, color: Colors.white70, height: 1.6)),
      const SizedBox(height: 32),
      Row(
        children: [
          PrimaryButton(text: l10n.heroExplore, onPressed: () => Navigator.pushNamed(context, '/catalog')),
          const SizedBox(width: 16),
          _SecondaryButton(text: l10n.heroLearn),
        ],
      ),
    ],
  );

  Widget _buildBadge(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.cartTeal.withOpacity(0.2),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.cartTeal.withOpacity(0.5), width: 1.5),
    ),
    child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
  );

  Widget _buildTitle(AppLocalizations l10n, double size) => RichText(
    text: TextSpan(
      style: TextStyle(fontSize: size, height: 1.1, fontWeight: FontWeight.bold, color: Colors.white),
      children: [
        TextSpan(text: "${l10n.heroTitle1}\n"),
        TextSpan(
          text: "${l10n.heroTitle2}\n",
          style: const TextStyle(color: AppColors.cartTeal),
        ),
        TextSpan(text: l10n.heroTitle3),
      ],
    ),
  );
}

// Ensure your _SecondaryButton uses Colors.white for text if needed for contrast
class _SecondaryButton extends StatefulWidget {
  final String text;
  const _SecondaryButton({required this.text});
  @override
  State<_SecondaryButton> createState() => _SecondaryButtonState();
}

class _SecondaryButtonState extends State<_SecondaryButton> {
  bool _isHovering = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => _isHovering = true),
    onExit: (_) => setState(() => _isHovering = false),
    child: AnimatedScale(
      scale: _isHovering ? 1.08 : 1.0,
      duration: const Duration(milliseconds: 300),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 16),
          side: const BorderSide(color: Colors.white, width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        onPressed: () {},
        child: Text(widget.text, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    ),
  );
}