import 'package:flutter/material.dart';
import '../buttons/primary_button.dart';

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

  // ================= LOGO =================
  Widget _logo({double height = 44}) {
    return Image.asset(
      "assets/images/logo.png",
      height: height,
      fit: BoxFit.contain,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Colors.white,
      child: width >= 1024
          ? _buildDesktop()
          : width >= 768
              ? _buildTablet()
              : _buildMobile(context),
    );
  }

  // ================= DESKTOP =================
  Widget _buildDesktop() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _logo(height: 48),

        Row(
          children: [
            _NavItem(title: "Home", onTap: _scrollToTop),
            _NavItem(title: "About", onTap: _scrollToTop),
            _NavItem(title: "Pricing", onTap: _scrollToTop),
            _NavItem(title: "Blog", onTap: _scrollToTop),
          ],
        ),

        Row(
          children: [
            if (!isLoggedIn) ...[
              TextButton(
                onPressed: () {},
                child: const Text("Login"),
              ),
              const SizedBox(width: 10),
              const PrimaryButton(text: "Sign Up"),
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

  // ================= TABLET =================
  Widget _buildTablet() {
    return Row(
      children: [
        _logo(height: 44),

        const SizedBox(width: 20),

        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _NavItem(title: "Home", onTap: _scrollToTop),
              _NavItem(title: "About", onTap: _scrollToTop),
              _NavItem(title: "Pricing", onTap: _scrollToTop),
              _NavItem(title: "Blog", onTap: _scrollToTop),
            ],
          ),
        ),

        Row(
          children: [
            if (!isLoggedIn) ...[
              TextButton(
                onPressed: () {},
                child: const Text("Login"),
              ),
              const SizedBox(width: 8),
              const PrimaryButton(text: "Sign Up"),
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

  // ================= MOBILE =================
  Widget _buildMobile(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _logo(height: 40),

        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openEndDrawer();
            },
          ),
        ),
      ],
    );
  }
}

// ================= NAV ITEM مع HOVER =================
class _NavItem extends StatefulWidget {
  final String title;
  final VoidCallback onTap;

  const _NavItem({required this.title, required this.onTap});

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
              color: _hovered ? const Color(0xFF18A97A) : Colors.black87,
              fontWeight: _hovered ? FontWeight.w600 : FontWeight.w400,
            ),
            child: Text(widget.title),
          ),
        ),
      ),
    );
  }
}