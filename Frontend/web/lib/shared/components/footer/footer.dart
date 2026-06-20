import 'package:flutter/material.dart';
import '../../../util/theme/app_colors.dart';
import '../../../shared/i18n/app_localizations.dart';

class Footer extends StatelessWidget {
  final ScrollController scrollController;
  const Footer({super.key, required this.scrollController});

  void _scrollToTop() {
    scrollController.animateTo(0, duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 40),
      decoration: const BoxDecoration(
        color: AppColors.cartTeal,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      padding: EdgeInsets.symmetric(horizontal: width >= 768 ? 60 : 24, vertical: 48),
      child: width >= 768 ? _buildDesktop(l10n) : _buildMobile(l10n),
    );
  }

  Widget _buildDesktop(AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Talento", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(l10n.footerCopyright, style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 20),
              Row(children: [
                _IconBtn(icon: Icons.share_outlined, onTap: _scrollToTop),
                const SizedBox(width: 12),
                _IconBtn(icon: Icons.favorite_border, onTap: _scrollToTop),
                const SizedBox(width: 12),
                _IconBtn(icon: Icons.mail_outline, onTap: _scrollToTop),
              ]),
            ],
          ),
        ),
        Row(
          children: [
            _linkColumn([l10n.footerSustainability, l10n.footerShipping, l10n.footerReturns]),
            const SizedBox(width: 60),
            _linkColumn([l10n.footerPrivacy, l10n.footerContact, l10n.footerAccessibility]),
          ],
        ),
      ],
    );
  }

  Widget _buildMobile(AppLocalizations l10n) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _linkColumn([l10n.footerSustainability, l10n.footerShipping, l10n.footerReturns])),
            Expanded(child: _linkColumn([l10n.footerPrivacy, l10n.footerContact, l10n.footerAccessibility])),
          ],
        ),
        const SizedBox(height: 32),
        const Divider(color: Colors.white24),
        const SizedBox(height: 16),
        Text(l10n.footerCopyright, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _IconBtn(icon: Icons.share_outlined, onTap: _scrollToTop),
            const SizedBox(width: 16),
            _IconBtn(icon: Icons.favorite_border, onTap: _scrollToTop),
            const SizedBox(width: 16),
            _IconBtn(icon: Icons.mail_outline, onTap: _scrollToTop),
          ],
        ),
      ],
    );
  }

  Widget _linkColumn(List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: links.map((link) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _FooterLink(title: link, onTap: _scrollToTop),
      )).toList(),
    );
  }
}

class _IconBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  State<_IconBtn> createState() => _IconBtnState();
}

class _IconBtnState extends State<_IconBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _hovered ? Colors.white : Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(widget.icon, color: _hovered ? AppColors.cartTeal : Colors.white, size: 20),
        ),
      ),
    );
  }
}

class _FooterLink extends StatefulWidget {
  final String title;
  final VoidCallback onTap;
  const _FooterLink({required this.title, required this.onTap});
  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          widget.title,
          style: TextStyle(
            color: _hovered ? Colors.white : Colors.white70,
            fontSize: 14,
            fontWeight: _hovered ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}