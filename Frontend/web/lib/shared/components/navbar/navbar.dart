import 'package:flutter/material.dart';
import '../buttons/primary_button.dart';
import 'package:provider/provider.dart';
import '../../../shared/i18n/app_localizations.dart';
import '../../../shared/providers/language_provider.dart';
import '../../../features/auth/pages/login_screen.dart';
import '../../../features/auth/pages/signup_screen.dart';

class Navbar extends StatelessWidget {
  final bool isLoggedIn;
  final ScrollController scrollController;

  const Navbar({
    super.key,
    this.isLoggedIn = false,
    required this.scrollController,
  });

  void _scrollToTop() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  Widget _logo({double height = 44}) {
    return Image.asset(
      "assets/images/logo.png",
      height: height,
      fit: BoxFit.contain,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Colors.white,
      child: width >= 1024
          ? _buildDesktop(context, l10n)
          : width >= 768
              ? _buildTablet(context, l10n)
              : _buildMobile(context, l10n),
    );
  }

  Widget _buildDesktop(BuildContext context, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _logo(height: 48),
        Row(
          children: [
            _NavItem(title: l10n.navHome, onTap: _scrollToTop),
            _NavItem(title: l10n.navAbout, onTap: _scrollToTop),
            _NavItem(title: l10n.navPricing, onTap: _scrollToTop),
            _NavItem(title: l10n.navBlog, onTap: _scrollToTop),
          ],
        ),
        Row(
          children: [
            if (!isLoggedIn) ...[
              TextButton(
                onPressed: () => Provider.of<LanguageProvider>(
                  context,
                  listen: false,
                ).toggleLanguage(),
                child: Text(l10n.language),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
                },
                child: Text(l10n.navLogin),
              ),
              const SizedBox(width: 10),
              PrimaryButton(
                text: l10n.navSignUp,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SignupScreen(),
                    ),
                  );
                },
              ),
            ] else ...[
              const Icon(Icons.shopping_cart_outlined),
              const SizedBox(width: 10),
              const CircleAvatar(radius: 14),
            ]
          ],
        ),
      ],
    );
  }

  Widget _buildTablet(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        _logo(height: 44),
        const SizedBox(width: 20),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _NavItem(title: l10n.navHome, onTap: _scrollToTop),
              _NavItem(title: l10n.navAbout, onTap: _scrollToTop),
              _NavItem(title: l10n.navPricing, onTap: _scrollToTop),
              _NavItem(title: l10n.navBlog, onTap: _scrollToTop),
            ],
          ),
        ),
        Row(
          children: [
            if (!isLoggedIn) ...[
              TextButton(
                onPressed: () => Provider.of<LanguageProvider>(
                  context,
                  listen: false,
                ).toggleLanguage(),
                child: Text(l10n.language),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginScreen(),
                    ),
                  );
                },
                child: Text(l10n.navLogin),
              ),
              const SizedBox(width: 8),
              PrimaryButton(
                text: l10n.navSignUp,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const SignupScreen(),
                    ),
                  );
                },
              ),
            ] else ...[
              const Icon(Icons.shopping_cart_outlined),
              const SizedBox(width: 8),
              const CircleAvatar(radius: 14),
            ]
          ],
        ),
      ],
    );
  }

  Widget _buildMobile(BuildContext context, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _logo(height: 40),
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openEndDrawer(),
          ),
        ),
      ],
    );
  }
}

class _NavItem extends StatefulWidget {
  final String title;
  final VoidCallback onTap;

  const _NavItem({
    required this.title,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 180),
            style: TextStyle(
              fontSize: 16,
              color: _hovered
                  ? const Color(0xFF18A97A)
                  : Colors.black87,
              fontWeight: _hovered
                  ? FontWeight.w600
                  : FontWeight.w400,
            ),
            child: Text(widget.title),
          ),
        ),
      ),
    );
  }
}