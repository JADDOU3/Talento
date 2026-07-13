// lib/shared/components/footer/footer.dart
import 'package:flutter/material.dart';
import 'dart:html' as html;  // Use dart:html directly
import '../../../util/theme/app_colors.dart';
import '../../../shared/i18n/app_localizations.dart';

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

  void _showFeedbackForm(BuildContext context) {
    final TextEditingController _feedbackController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.feedback_outlined, color: AppColors.cartTeal),
            const SizedBox(width: 10),
            const Text(
              'Send us your feedback',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.cartForestGreen,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'We value your feedback! Let us know how we can improve.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _feedbackController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Write your feedback here...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.cartTeal, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.cartTeal,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              if (_feedbackController.text.isNotEmpty) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Thank you for your feedback! 🙏'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 3),
                  ),
                );
                _feedbackController.clear();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please write your feedback before submitting.'),
                    backgroundColor: Colors.orange,
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: const Text('Submit Feedback'),
          ),
        ],
      ),
    );
  }

  void _openUrl(String url) {
    // Use dart:html to open in new tab
    html.window.open(url, '_blank');
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
      child: width >= 768 ? _buildDesktop(l10n, context) : _buildMobile(l10n, context),
    );
  }

  Widget _buildDesktop(AppLocalizations l10n, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left side: Logo + Social Media
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Talento",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.footerCopyright,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              const SizedBox(height: 24),
              // Social Media Icons
              Row(
                children: [
                  _SocialIcon(
                    icon: Icons.facebook,
                    color: const Color(0xFF1877F2),
                    onTap: () => _openUrl('https://www.facebook.com/share/19DzHcJnQd/?mibextid=wwXIfr'),
                  ),
                  const SizedBox(width: 12),
                  _SocialIcon(
                    icon: Icons.camera_alt,
                    color: const Color(0xFFE4405F),
                    onTap: () => _openUrl('https://instagram.com/talento/'),
                  ),
                  const SizedBox(width: 12),
                  _SocialIcon(
                    icon: Icons.work,
                    color: const Color(0xFF0A66C2),
                    onTap: () => _openUrl('https://www.linkedin.com/company/talento-ps/'),
                  ),
                  const SizedBox(width: 12),
                  _SocialIcon(
                    icon: Icons.play_circle_filled,
                    color: const Color(0xFFFF0000),
                    onTap: () => _openUrl('https://youtube.com/talento'),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Right side: Contact Info + Links
        Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Contact Info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ContactItem(
                    icon: Icons.phone_outlined,
                    text: '+972 597 979 698',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _ContactItem(
                    icon: Icons.email_outlined,
                    text: 'info@talento.com',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _ContactItem(
                    icon: Icons.feedback_outlined,
                    text: 'Contact Us',
                    onTap: () => _showFeedbackForm(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobile(AppLocalizations l10n, BuildContext context) {
    return Column(
      children: [
        // Logo
        const Text(
          "Talento",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.footerCopyright,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        // Social Media
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialIcon(
              icon: Icons.facebook,
              color: const Color(0xFF1877F2),
              onTap: () => _openUrl('https://www.facebook.com/share/19DzHcJnQd/?mibextid=wwXIfr'),
            ),
            const SizedBox(width: 16),
            _SocialIcon(
              icon: Icons.camera_alt,
              color: const Color(0xFFE4405F),
              onTap: () => _openUrl('https://instagram.com/talento/'),
            ),
            const SizedBox(width: 16),
            _SocialIcon(
              icon: Icons.work,
              color: const Color(0xFF0A66C2),
              onTap: () => _openUrl('https://www.linkedin.com/company/talento-ps/'),
            ),
            const SizedBox(width: 16),
            _SocialIcon(
              icon: Icons.play_circle_filled,
              color: const Color(0xFFFF0000),
              onTap: () => _openUrl('https://youtube.com/talento'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Divider(color: Colors.white24),
        const SizedBox(height: 16),
        // Contact Info
        Column(
          children: [
            _ContactItem(
              icon: Icons.phone_outlined,
              text: '+1 (555) 123-4567',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _ContactItem(
              icon: Icons.email_outlined,
              text: 'info@talento.com',
              onTap: () {},
            ),
            const SizedBox(height: 8),
            _ContactItem(
              icon: Icons.feedback_outlined,
              text: 'Contact Us',
              onTap: () => _showFeedbackForm(context),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ─── Social Media Icon ────────────────────────────────────────────────────────
class _SocialIcon extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _SocialIcon({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_SocialIcon> createState() => _SocialIconState();
}

class _SocialIconState extends State<_SocialIcon> {
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
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _hovered ? widget.color : Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: _hovered ? widget.color : Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Icon(
            widget.icon,
            color: _hovered ? Colors.white : Colors.white70,
            size: 22,
          ),
        ),
      ),
    );
  }
}

// ─── Contact Item ────────────────────────────────────────────────────────────
class _ContactItem extends StatefulWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _ContactItem({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  State<_ContactItem> createState() => _ContactItemState();
}

class _ContactItemState extends State<_ContactItem> {
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: _hovered ? Colors.white.withOpacity(0.1) : Colors.transparent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                color: _hovered ? Colors.white : Colors.white70,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                widget.text,
                style: TextStyle(
                  color: _hovered ? Colors.white : Colors.white70,
                  fontSize: 13,
                  fontWeight: _hovered ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}