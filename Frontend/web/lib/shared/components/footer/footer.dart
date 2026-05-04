import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  final ScrollController scrollController;

  const Footer({super.key, required this.scrollController});

  void _scrollToTop() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 40),
      decoration: const BoxDecoration(
        color: Color(0xFF1E2A3A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: width >= 768 ? 60 : 24,
        vertical: 48,
      ),
      child: width >= 768 ? _buildDesktop() : _buildMobile(),
    );
  }

  // ================= DESKTOP =================
  Widget _buildDesktop() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "© 2026 TALENTO KIDS. ROOTED IN CURIOSITY.",
                style: TextStyle(
                  color: Color(0xFF8A9BB0),
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _IconBtn(icon: Icons.share_outlined, onTap: _scrollToTop),
                  const SizedBox(width: 10),
                  _IconBtn(icon: Icons.favorite_border, onTap: _scrollToTop),
                  const SizedBox(width: 10),
                  _IconBtn(icon: Icons.mail_outline, onTap: _scrollToTop),
                ],
              ),
            ],
          ),
        ),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _linkColumn(["SUSTAINABILITY", "SHIPPING", "RETURNS"]),
            const SizedBox(width: 60),
            _linkColumn(
              ["PRIVACY POLICY", "CONTACT US", "ACCESSIBILITY"],
              underlineLast: true,
            ),
          ],
        ),
      ],
    );
  }

  // ================= MOBILE =================
  Widget _buildMobile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _linkColumn(["SUSTAINABILITY", "SHIPPING", "RETURNS"]),
            const SizedBox(width: 40),
            _linkColumn(
              ["PRIVACY POLICY", "CONTACT US", "ACCESSIBILITY"],
              underlineLast: true,
            ),
          ],
        ),

        const SizedBox(height: 32),

        const Text(
          "© 2026 TALENTO KIDS. ROOTED IN CURIOSITY.",
          style: TextStyle(
            color: Color(0xFF8A9BB0),
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: 16),

        Row(
          children: [
            _IconBtn(icon: Icons.share_outlined, onTap: _scrollToTop),
            const SizedBox(width: 10),
            _IconBtn(icon: Icons.favorite_border, onTap: _scrollToTop),
            const SizedBox(width: 10),
            _IconBtn(icon: Icons.mail_outline, onTap: _scrollToTop),
          ],
        ),
      ],
    );
  }

  // ================= LINK COLUMN =================
  Widget _linkColumn(List<String> links, {bool underlineLast = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: links.asMap().entries.map((entry) {
        final isLast = entry.key == links.length - 1;
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _FooterLink(
            title: entry.value,
            underline: underlineLast && isLast,
            onTap: _scrollToTop,
          ),
        );
      }).toList(),
    );
  }
}

// ================= ICON BUTTON مع HOVER =================
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
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _hovered ? const Color(0xFF18A97A) : const Color(0xFF2A3A4E),
            borderRadius: BorderRadius.circular(50),
          ),
          child: Icon(
            widget.icon,
            color: _hovered ? Colors.white : const Color(0xFF8A9BB0),
            size: 16,
          ),
        ),
      ),
    );
  }
}

// ================= FOOTER LINK مع HOVER =================
class _FooterLink extends StatefulWidget {
  final String title;
  final bool underline;
  final VoidCallback onTap;

  const _FooterLink({
    required this.title,
    required this.onTap,
    this.underline = false,
  });

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
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 180),
          style: TextStyle(
            color: _hovered ? Colors.white : const Color(0xFF8A9BB0),
            fontSize: 12,
            letterSpacing: 0.8,
            decoration: widget.underline
                ? TextDecoration.underline
                : TextDecoration.none,
            decorationColor:
                _hovered ? Colors.white : const Color(0xFF8A9BB0),
          ),
          child: Text(widget.title),
        ),
      ),
    );
  }
}