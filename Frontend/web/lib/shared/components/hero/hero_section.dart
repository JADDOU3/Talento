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
          Positioned.fill(
            child: Image.asset(
              "assets/images/hero.png",
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.3),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                // AlignmentDirectional auto-mirrors for RTL, no isRtl check needed
                gradient: LinearGradient(
                  begin: AlignmentDirectional.centerStart,
                  end: AlignmentDirectional.centerEnd,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.5),
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            // EdgeInsetsDirectional: 'start' is always the side with the 60px gap
            padding: EdgeInsetsDirectional.only(
              start: isDesktop ? 60 : 20,
              end: 0,
            ),
            alignment: AlignmentDirectional.centerStart,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: _buildContent(context, l10n, isDesktop ? 64 : 42),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n, double titleSize) => Column(
    mainAxisSize: MainAxisSize.min,
    // CrossAxisAlignment.start is direction-aware: it means "right" in RTL automatically.
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Align(
        alignment: AlignmentDirectional.centerStart,
        child: _buildBadge(l10n.heroBadge),
      ),
      const SizedBox(height: 24),
      _buildTitle(l10n, titleSize),
      const SizedBox(height: 20),
      Text(
        l10n.heroDesc,
        textAlign: TextAlign.start,
        style: const TextStyle(
          fontSize: 18,
          color: Colors.white,
          height: 1.6,
          shadows: [Shadow(offset: Offset(0, 2), blurRadius: 8, color: Colors.black45)],
        ),
      ),
      const SizedBox(height: 32),
      Row(
        // MainAxisAlignment.start is direction-aware too — no manual isRtl swap needed.
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          PrimaryButton(
            text: l10n.heroExplore,
            onPressed: () => Navigator.pushNamed(context, '/catalog'),
          ),
          const SizedBox(width: 16),
          _SecondaryButton(text: l10n.heroLearn),
        ],
      ),
    ],
  );

  Widget _buildBadge(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.cartTeal.withOpacity(0.25),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.cartTeal.withOpacity(0.7), width: 1.5),
    ),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
      textAlign: TextAlign.start,
    ),
  );

  Widget _buildTitle(AppLocalizations l10n, double size) => RichText(
    textAlign: TextAlign.start,
    text: TextSpan(
      style: TextStyle(fontSize: size, height: 1.2, fontWeight: FontWeight.bold, color: Colors.white),
      children: [
        TextSpan(text: "${l10n.heroTitle1}\n"),
        TextSpan(text: "${l10n.heroTitle2}\n", style: const TextStyle(color: AppColors.cartTeal)),
        TextSpan(text: l10n.heroTitle3),
      ],
    ),
  );
}

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
          backgroundColor: Colors.black.withOpacity(0.2),
        ),
        onPressed: () {},
        child: Text(widget.text, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    ),
  );
}