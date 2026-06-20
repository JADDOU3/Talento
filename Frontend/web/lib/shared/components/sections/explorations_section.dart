import 'package:flutter/material.dart';
import '../../../shared/i18n/app_localizations.dart';

class ExplorationsSection extends StatelessWidget {
  const ExplorationsSection({super.key});

  static const double kRowHeight = 420.0;

  static const int _botanistKitId = 1;
  static const int _avianKitId = 2;
  static const int _prismKitId = 3;

  void _openKitDetails(BuildContext context, int kitId) {
    Navigator.pushNamed(context, '/kit-details', arguments: kitId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: width >= 768 ? 40 : 20, vertical: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(context, l10n, mobile: width < 768),
              const SizedBox(height: 32),
              width >= 768 ? _buildDesktop(context, l10n) : _buildMobile(context, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, AppLocalizations l10n, {required bool mobile}) {
    if (mobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text("🧭", style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(l10n.explorationsTitle, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
          ]),
          const SizedBox(height: 6),
          Text(l10n.explorationsSubtitle, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: _BounceButton(text: l10n.explorationsViewAll, onTap: () {})),
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Text("", style: TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Text(l10n.explorationsTitle, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
            ]),
            const SizedBox(height: 6),
            Text(l10n.explorationsSubtitle, style: const TextStyle(color: Colors.grey)),
          ],
        ),
        _BounceButton(text: l10n.explorationsViewAll, onTap: () {}),
      ],
    );
  }

  Widget _buildDesktop(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        SizedBox(
          height: kRowHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 2, child: _bigCard(context, l10n)),
              const SizedBox(width: 20),
              Expanded(child: _avianCard(context, l10n)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: kRowHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _prismCard(context, l10n)),
              const SizedBox(width: 20),
              Expanded(flex: 2, child: _featured(context, l10n)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobile(BuildContext context, AppLocalizations l10n) {
    return Column(
      children: [
        _BouncyTapCard(
          onTap: () => _openKitDetails(context, _botanistKitId),
          child: _mobileCardContent(
            context: context,
            kitId: _botanistKitId,
            imagePath: 'assets/images/img5.png',
            tag: 'AGES 6-9',
            tagColor: Colors.green,
            title: l10n.card1Title,
            description: l10n.card1Desc,
            hasButton: true,
            buttonText: l10n.card1Button,
          ),
        ),
        const SizedBox(height: 16),
        _BouncyTapCard(
          onTap: () => _openKitDetails(context, _avianKitId),
          child: _mobileCardContent(
            context: context,
            kitId: _avianKitId,
            imagePath: 'assets/images/img6.png',
            tag: 'AGES 4-6',
            tagColor: const Color(0xFFE91E8C),
            title: l10n.card2Title,
            description: l10n.card2Desc,
          ),
        ),
        const SizedBox(height: 16),
        _BouncyTapCard(
          onTap: () => _openKitDetails(context, _prismKitId),
          child: _mobileCardContent(
            context: context,
            kitId: _prismKitId,
            imagePath: 'assets/images/img7.png',
            tag: 'AGES 8-12',
            tagColor: Colors.blue,
            title: l10n.card3Title,
            description: l10n.card3Desc,
          ),
        ),
        const SizedBox(height: 16),
        _featuredMobile(context, l10n),
      ],
    );
  }

  Widget _mobileCardContent({
    required BuildContext context,
    required int kitId,
    required String imagePath,
    required String tag,
    required Color tagColor,
    required String title,
    required String description,
    bool hasButton = false,
    String? buttonText,
  }) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: Image.asset(imagePath, width: double.infinity, height: 200, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _WiggleTag(label: tag, color: tagColor),
                const SizedBox(height: 10),
                Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(description, style: const TextStyle(color: Colors.grey, fontSize: 14, height: 1.5)),
                if (hasButton && buttonText != null) ...[
                  const SizedBox(height: 16),
                  SizedBox(width: double.infinity, child: _OutlineBounceButton(text: buttonText, color: Colors.green, onTap: () => _openKitDetails(context, kitId))),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _featuredMobile(BuildContext context, AppLocalizations l10n) {
    return _BouncyTapCard(
      onTap: () => _openKitDetails(context, _botanistKitId),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          children: [
            Image.asset("assets/images/img8.png", width: double.infinity, height: 380, fit: BoxFit.cover),
            Container(width: double.infinity, height: 380, color: Colors.black.withOpacity(0.45)),
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 20),
                  _GlowBadge(label: l10n.featuredBadge),
                  const SizedBox(height: 16),
                  Text(l10n.featuredTitle, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, height: 1.2)),
                  const SizedBox(height: 12),
                  Text(l10n.featuredDesc, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: _OutlineBounceButton(
                      text: l10n.featuredButton,
                      color: const Color(0xFF2DC5A2),
                      filled: true,
                      onTap: () => _openKitDetails(context, _botanistKitId),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bigCard(BuildContext context, AppLocalizations l10n) {
    return _BouncyTapCard(
      onTap: () => _openKitDetails(context, _botanistKitId),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
        child: Row(
          children: [
            Expanded(child: ClipRRect(borderRadius: const BorderRadius.horizontal(left: Radius.circular(32)), child: Image.asset("assets/images/img5.png", fit: BoxFit.cover, height: double.infinity))),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _WiggleTag(label: "AGES 6-9", color: Colors.green),
                        const SizedBox(height: 14),
                        Text(l10n.card1Title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 12),
                        Text(l10n.card1Desc, style: const TextStyle(color: Colors.grey, fontSize: 15)),
                      ],
                    ),
                    _OutlineBounceButton(text: l10n.card1Button, color: Colors.green, onTap: () => _openKitDetails(context, _botanistKitId)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avianCard(BuildContext context, AppLocalizations l10n) {
    return _BouncyTapCard(
      onTap: () => _openKitDetails(context, _avianKitId),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Image.asset("assets/images/img6.png", width: double.infinity, fit: BoxFit.cover)),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _WiggleTag(label: "AGES 4-6", color: const Color(0xFFE91E8C)),
                  const SizedBox(height: 8),
                  Text(l10n.card2Title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(l10n.card2Desc, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _prismCard(BuildContext context, AppLocalizations l10n) {
    return _BouncyTapCard(
      onTap: () => _openKitDetails(context, _prismKitId),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Image.asset("assets/images/img7.png", width: double.infinity, fit: BoxFit.cover)),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _WiggleTag(label: "AGES 8-12", color: Colors.blue),
                  const SizedBox(height: 8),
                  Text(l10n.card3Title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Text(l10n.card3Desc, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featured(BuildContext context, AppLocalizations l10n) {
    return _BouncyTapCard(
      onTap: () => _openKitDetails(context, _botanistKitId),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset("assets/images/img8.png", fit: BoxFit.cover),
            Container(color: Colors.black.withOpacity(0.4)),
            Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _GlowBadge(label: l10n.featuredBadge),
                  const SizedBox(height: 20),
                  Text(l10n.featuredTitle, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, height: 1.2)),
                  const SizedBox(height: 14),
                  SizedBox(width: 300, child: Text(l10n.featuredDesc, style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5))),
                  const SizedBox(height: 30),
                  _OutlineBounceButton(text: l10n.featuredButton, color: const Color(0xFF2DC5A2), filled: true, onTap: () => _openKitDetails(context, _botanistKitId)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🎈 Card that lifts and bounces when tapped or hovered — feels alive.
class _BouncyTapCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  const _BouncyTapCard({required this.child, required this.onTap});

  @override
  State<_BouncyTapCard> createState() => _BouncyTapCardState();
}

class _BouncyTapCardState extends State<_BouncyTapCard> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scale = _pressed ? 0.96 : (_hovered ? 1.03 : 1.0);
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: scale,
          curve: Curves.elasticOut,
          duration: const Duration(milliseconds: 300),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_hovered ? 0.12 : 0.06),
                  blurRadius: _hovered ? 24 : 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// 🏷️ Tag that gives a tiny wiggle on hover
class _WiggleTag extends StatefulWidget {
  final String label;
  final Color color;
  const _WiggleTag({required this.label, required this.color});

  @override
  State<_WiggleTag> createState() => _WiggleTagState();
}

class _WiggleTagState extends State<_WiggleTag> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedRotation(
        turns: _hovered ? 0.02 : 0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: widget.color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
          child: Text(widget.label, style: TextStyle(color: widget.color, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.5)),
        ),
      ),
    );
  }
}

/// ✨ Glowing badge for "Featured" banners
class _GlowBadge extends StatelessWidget {
  final String label;
  const _GlowBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.white.withOpacity(0.3), blurRadius: 12)],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Text("⭐", style: TextStyle(fontSize: 11)),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}

/// 🔘 Solid bounce button (View All, etc.)
class _BounceButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;
  const _BounceButton({required this.text, required this.onTap});

  @override
  State<_BounceButton> createState() => _BounceButtonState();
}

class _BounceButtonState extends State<_BounceButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        curve: Curves.elasticOut,
        duration: const Duration(milliseconds: 250),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFF4D4D),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(color: const Color(0xFFFF4D4D).withOpacity(0.4), blurRadius: 14, offset: const Offset(0, 6))],
          ),
          child: Text(widget.text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ),
      ),
    );
  }
}

/// 🔘 Outline bounce button used inside cards
class _OutlineBounceButton extends StatefulWidget {
  final String text;
  final Color color;
  final bool filled;
  final VoidCallback onTap;
  const _OutlineBounceButton({required this.text, required this.color, required this.onTap, this.filled = false});

  @override
  State<_OutlineBounceButton> createState() => _OutlineBounceButtonState();
}

class _OutlineBounceButtonState extends State<_OutlineBounceButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        curve: Curves.elasticOut,
        duration: const Duration(milliseconds: 250),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            color: widget.filled ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            border: widget.filled ? null : Border.all(color: widget.color, width: 1.5),
          ),
          child: Text(
            widget.text,
            textAlign: TextAlign.center,
            style: TextStyle(color: widget.color, fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ),
      ),
    );
  }
}