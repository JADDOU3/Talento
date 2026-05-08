import 'package:flutter/material.dart';
import '../../../shared/components/navbar/navbar.dart';
import '../../../shared/components/hero/hero_section.dart';
import '../../../shared/components/sections/journey_section.dart';
import '../../../shared/components/buttons/primary_button.dart';
import '../../../shared/components/sections/beyond_section.dart';
import '../../../shared/components/sections/explorations_section.dart';
import '../../../shared/components/footer/footer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      endDrawer: Drawer(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Close button
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(height: 16),

                // Nav links
                _DrawerLink(
                  title: "Home",
                  onTap: () {
                    Navigator.of(context).pop();
                    _scrollToTop();
                  },
                ),
                _DrawerLink(title: "About", onTap: () => Navigator.of(context).pop()),
                _DrawerLink(title: "Pricing", onTap: () => Navigator.of(context).pop()),
                _DrawerLink(title: "Blog", onTap: () => Navigator.of(context).pop()),

                const Spacer(),

                TextButton(
                  onPressed: () {},
                  child: const Text("Login"),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: const PrimaryButton(text: "Sign Up"),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            Navbar(scrollController: _scrollController),
            const SizedBox(height: 40),
            const HeroSection(),
            const JourneySection(),
            const BeyondSection(),
            const ExplorationsSection(),
            Footer(scrollController: _scrollController),
          ],
        ),
      ),
    );
  }
}

// ================= DRAWER LINK مع HOVER =================
class _DrawerLink extends StatefulWidget {
  final String title;
  final VoidCallback onTap;

  const _DrawerLink({required this.title, required this.onTap});

  @override
  State<_DrawerLink> createState() => _DrawerLinkState();
}

class _DrawerLinkState extends State<_DrawerLink> {
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
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          margin: const EdgeInsets.only(bottom: 4),
          decoration: BoxDecoration(
            color: _hovered
                ? const Color(0xFF18A97A).withOpacity(0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 180),
            style: TextStyle(
              fontSize: 18,
              fontWeight: _hovered ? FontWeight.w600 : FontWeight.w400,
              color: _hovered ? const Color(0xFF18A97A) : Colors.black87,
            ),
            child: Text(widget.title),
          ),
        ),
      ),
    );
  }
}