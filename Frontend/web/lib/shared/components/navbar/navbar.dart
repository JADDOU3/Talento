import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../buttons/primary_button.dart';
import 'package:provider/provider.dart';
import '../../../cubits/cart/cart_cubit.dart';
import '../../../cubits/cart/cart_state.dart';
import '../../../shared/i18n/app_localizations.dart';
import '../../../shared/providers/language_provider.dart';
import '../../../features/auth/pages/login_screen.dart';
import '../../../features/auth/pages/signup_screen.dart';
import '../../../util/theme/app_colors.dart';

class Navbar extends StatefulWidget {
  final bool isLoggedIn;
  final bool showLanguageToggle;
  final bool showCartIcon;
  final ScrollController? scrollController; // Made optional for better reusability

  const Navbar({
    super.key,
    this.isLoggedIn = false,
    this.showLanguageToggle = true,
    this.showCartIcon = true,
    this.scrollController,
  });

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    // Only listen if a controller is provided
    widget.scrollController?.addListener(_onScroll);
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (widget.scrollController == null) return;
    bool scrolled = widget.scrollController!.offset > 50;
    if (scrolled != _isScrolled) {
      setState(() => _isScrolled = scrolled);
    }
  }

  void _scrollToTop() {
    widget.scrollController?.animateTo(0, duration: const Duration(milliseconds: 600), curve: Curves.easeInOut);
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.of(context).size.width;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: AppColors.cartTeal.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: width >= 1024 ? _buildDesktop(context, l10n) : _buildMobile(context, l10n),
    );
  }

  Widget _buildDesktop(BuildContext context, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _BouncyLogo(onTap: () => _goHome(context), height: 48),
        Row(
          children: [
            _NavItem(title: l10n.navHome, emoji: "🏠", onTap: () => _goHome(context)),
            // If scrollController is null, just go to home or ignore
            _NavItem(title: l10n.navAbout, emoji: "🌈", onTap: widget.scrollController != null ? _scrollToTop : () => Navigator.pushNamed(context, '/about')),
            _NavItem(title: l10n.navPricing, emoji: "💰", onTap: widget.scrollController != null ? _scrollToTop : () => Navigator.pushNamed(context, '/pricing')),
            _NavItem(title: l10n.navBlog, emoji: "📖", onTap: widget.scrollController != null ? _scrollToTop : () => Navigator.pushNamed(context, '/blog')),
          ],
        ),
        Row(
          children: [
            if (widget.showLanguageToggle)
              TextButton(
                onPressed: () => Provider.of<LanguageProvider>(context, listen: false).toggleLanguage(),
                child: Text("🌐 ${l10n.language}", style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            if (widget.showCartIcon) const _CartIconButton(minSize: 45),
            if (!widget.isLoggedIn) ...[
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                child: Text(l10n.navLogin, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              PrimaryButton(
                text: " ${l10n.navSignUp}",
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
              ),
            ] else ...[
              const _ProfileAvatarButton(minSize: 45),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildMobile(BuildContext context, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _BouncyLogo(onTap: () => _goHome(context), height: 40),
        Row(
          children: [
            if (widget.showCartIcon) const _CartIconButton(minSize: 45),
            Builder(
              builder: (context) => _WiggleMenuButton(
                onTap: () => Scaffold.of(context).openEndDrawer(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// All your existing helper widgets (_BouncyLogo, _NavItem, etc.) remain below exactly as they were...
// (No changes needed to those classes as they are already self-contained)
// 🐣 Logo that gives a happy little wobble when tapped
class _BouncyLogo extends StatefulWidget {
  final VoidCallback onTap;
  final double height;
  const _BouncyLogo({required this.onTap, required this.height});

  @override
  State<_BouncyLogo> createState() => _BouncyLogoState();
}

class _BouncyLogoState extends State<_BouncyLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.forward(from: 0);
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = 0.15 * (1 - _controller.value) * (_controller.value < 0.5 ? 1 : -1) * (1 - _controller.value);
          final scale = 1.0 + (0.15 * (1 - _controller.value).clamp(0, 1)) * (_controller.isAnimating ? 1 : 0);
          return Transform.rotate(
            angle: _controller.isAnimating ? angle : 0,
            child: Transform.scale(scale: _controller.isAnimating ? 1 + 0.1 * (1 - _controller.value) : 1, child: child),
          );
        },
        child: Image.asset("assets/images/logo2.png", height: widget.height, fit: BoxFit.contain),
      ),
    );
  }
}

// 🎈 Bouncy nav item with emoji + elastic pop
class _NavItem extends StatefulWidget {
  final String title;
  final String emoji;
  final VoidCallback onTap;
  const _NavItem({required this.title, required this.emoji, required this.onTap});

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
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _hovered ? 1.15 : 1.0,
          curve: Curves.elasticOut,
          duration: const Duration(milliseconds: 400),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                AnimatedOpacity(
                  opacity: _hovered ? 1 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: Text(widget.emoji, style: const TextStyle(fontSize: 14)),
                ),
                if (_hovered) const SizedBox(width: 4),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _hovered ? AppColors.cartTeal : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// 🛒 Cart icon that jiggles whenever the count changes
class _CartIconButton extends StatefulWidget {
  final double minSize;
  const _CartIconButton({required this.minSize});

  @override
  State<_CartIconButton> createState() => _CartIconButtonState();
}

class _CartIconButtonState extends State<_CartIconButton> with SingleTickerProviderStateMixin {
  late AnimationController _jiggleController;
  int _lastCount = 0;

  @override
  void initState() {
    super.initState();
    _jiggleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _jiggleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final count = state is CartLoaded ? state.cart.unitCount : 0;
        if (count != _lastCount) {
          _lastCount = count;
          _jiggleController.forward(from: 0);
        }
        return IconButton(
          constraints: BoxConstraints(minWidth: widget.minSize, minHeight: widget.minSize),
          onPressed: () => Navigator.of(context).pushNamed('/cart'),
          icon: AnimatedBuilder(
            animation: _jiggleController,
            builder: (context, child) {
              final wiggle = _jiggleController.isAnimating
                  ? 0.25 * (1 - _jiggleController.value) * (((_jiggleController.value * 10).floor() % 2 == 0) ? 1 : -1)
                  : 0.0;
              return Transform.rotate(angle: wiggle, child: child);
            },
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart_outlined, color: AppColors.cartTeal, size: 28),
                if (count > 0)
                  Positioned(
                    top: -6,
                    right: -6,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.5, end: 1.0),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.elasticOut,
                      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: const BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                        child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ☰ Menu button that wiggles on hover, more inviting on mobile
class _WiggleMenuButton extends StatefulWidget {
  final VoidCallback onTap;
  const _WiggleMenuButton({required this.onTap});

  @override
  State<_WiggleMenuButton> createState() => _WiggleMenuButtonState();
}

class _WiggleMenuButtonState extends State<_WiggleMenuButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.8 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.cartTeal.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.menu_rounded, size: 28, color: AppColors.cartTeal),
        ),
      ),
    );
  }
}

class _ProfileAvatarButton extends StatelessWidget {
  final double minSize;
  const _ProfileAvatarButton({required this.minSize});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      constraints: BoxConstraints(minWidth: minSize, minHeight: minSize),
      onPressed: () => Navigator.of(context).pushNamed('/profile'),
      icon: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.yellow, width: 2),
        ),
        child: const CircleAvatar(backgroundColor: AppColors.cartTeal, child: Icon(Icons.person, color: Colors.white)),
      ),
    );
  }
}