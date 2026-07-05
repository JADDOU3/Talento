import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
//lib/features/catalog/cubits/kit/kit_cubit.dart
import '../buttons/primary_button.dart';
import '../../../cubits/cart/cart_cubit.dart';
import '../../../cubits/cart/cart_state.dart';
// ⚠️ ADJUST THIS IMPORT to wherever you put auth_state.dart.
import '../../services/auth_state.dart';
import '../../../shared/i18n/app_localizations.dart';
import '../../../shared/providers/language_provider.dart';
import '../../../features/auth/pages/login_screen.dart';
import '../../../features/aut'
    'h/pages/signup_screen.dart';
import '../../../util/theme/app_colors.dart';

/// Talento's single, canonical navbar.
///
/// `isLoggedIn` and `cartCount` are now OPTIONAL. Leave them out and this
/// widget reads live state itself (from [AuthState] and [CartCubit]) —
/// that's the fix for the old hardcoded `isLoggedIn: true/false` littered
/// across pages. They're kept as nullable overrides only for cases like
/// storybook/testing where you want to force a specific look.
class Navbar extends StatefulWidget {
  /// Optional override. Leave null to read the real value from [AuthState].
  final bool? isLoggedIn;

  /// Optional override. Leave null to read the real value from [CartCubit].
  final int? cartCount;

  /// Optional scroll controller — when provided, the navbar shrinks
  /// slightly once the user scrolls past ~50px.
  final ScrollController? scrollController;

  final bool showCartIcon;

  /// Breakpoint (logical px) below which nav links collapse into a menu.
  final double mobileBreakpoint;

  const Navbar({
    super.key,
    this.isLoggedIn,
    this.cartCount,
    this.scrollController,
    this.showCartIcon = true,
    this.mobileBreakpoint = 900,
  });

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController?.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(covariant Navbar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollController != widget.scrollController) {
      oldWidget.scrollController?.removeListener(_onScroll);
      widget.scrollController?.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    widget.scrollController?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final controller = widget.scrollController;
    if (controller == null || !controller.hasClients) return;
    final scrolled = controller.offset > 50;
    if (scrolled != _isScrolled) {
      setState(() => _isScrolled = scrolled);
    }
  }

  // ---------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------
  void _goHome(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  void _go(BuildContext context, String route) {
    Navigator.of(context).pushNamed(route);
  }

  // ---------------------------------------------------------------------
  // Language toggle — isolated behind one method so it's easy to swap out
  // once localization is finalized.
  // ---------------------------------------------------------------------
  void _toggleLanguage(BuildContext context) {
    Provider.of<LanguageProvider>(context, listen: false).toggleLanguage();
  }

  String _languageLabel(AppLocalizations l10n) => "🌐 ${l10n.language}";

  @override
  Widget build(BuildContext context) {
    // Rebuilds automatically whenever AuthState changes (login/logout),
    // with no Provider wiring needed for this one value.
    return ListenableBuilder(
      listenable: AuthState.instance,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context)!;
        final width = MediaQuery.sizeOf(context).width;
        final isLoggedIn = widget.isLoggedIn ?? AuthState.instance.isLoggedIn;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: _isScrolled ? 8 : 12),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: _isScrolled ? 6 : 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: AppColors.cartTeal.withOpacity(0.18),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: width >= widget.mobileBreakpoint
              ? _buildDesktop(context, l10n, isLoggedIn)
              : _buildMobile(context, l10n, isLoggedIn),
        );
      },
    );
  }

  // ================= DESKTOP =================
  Widget _buildDesktop(BuildContext context, AppLocalizations l10n, bool isLoggedIn) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _BouncyLogo(onTap: () => _goHome(context), height: 44),
        Row(
          children: [
            _NavItem(title: l10n.navHome, emoji: "🏠", onTap: () => _goHome(context)),
            _NavItem(title: "Kits", emoji: "🎒", onTap: () => _go(context, '/kits')),
            _NavItem(title: l10n.navBlog, emoji: "📖", onTap: () => _go(context, '/blog')),
          ],
        ),
        Row(
          children: [
            TextButton(
              onPressed: () => _toggleLanguage(context),
              child: Text(_languageLabel(l10n), style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 10),
            if (isLoggedIn) ...[
              if (widget.showCartIcon) _CartIconButton(minSize: 45, countOverride: widget.cartCount),
              const SizedBox(width: 4),
              const _ProfileAvatarButton(minSize: 45),
            ] else ...[
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                child: Text(l10n.navLogin, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              PrimaryButton(
                text: " ${l10n.navSignUp}",
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // ================= MOBILE =================
  Widget _buildMobile(BuildContext context, AppLocalizations l10n, bool isLoggedIn) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _BouncyLogo(onTap: () => _goHome(context), height: 38),
        Row(
          children: [
            if (isLoggedIn && widget.showCartIcon)
              _CartIconButton(minSize: 42, countOverride: widget.cartCount),
            const SizedBox(width: 4),
            _MobileMenu(
              l10n: l10n,
              isLoggedIn: isLoggedIn,
              onHome: () => _goHome(context),
              onKits: () => _go(context, '/kits'),
              onBlog: () => _go(context, '/blog'),
              onLanguage: () => _toggleLanguage(context),
              onProfile: () => _go(context, '/profile'),
              onLogin: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
              onSignUp: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
              languageLabel: _languageLabel(l10n),
            ),
          ],
        ),
      ],
    );
  }
}

// ============================================================
// Mobile hamburger menu — self-contained PopupMenuButton so this
// navbar doesn't require every Scaffold to wire up an endDrawer.
// ============================================================
class _MobileMenu extends StatefulWidget {
  final AppLocalizations l10n;
  final bool isLoggedIn;
  final VoidCallback onHome;
  final VoidCallback onKits;
  final VoidCallback onBlog;
  final VoidCallback onLanguage;
  final VoidCallback onProfile;
  final VoidCallback onLogin;
  final VoidCallback onSignUp;
  final String languageLabel;

  const _MobileMenu({
    required this.l10n,
    required this.isLoggedIn,
    required this.onHome,
    required this.onKits,
    required this.onBlog,
    required this.onLanguage,
    required this.onProfile,
    required this.onLogin,
    required this.onSignUp,
    required this.languageLabel,
  });

  @override
  State<_MobileMenu> createState() => _MobileMenuState();
}

class _MobileMenuState extends State<_MobileMenu> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.85 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: PopupMenuButton<VoidCallback>(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.cartTeal.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.menu_rounded, size: 26, color: AppColors.cartTeal),
          ),
          onSelected: (callback) => callback(),
          itemBuilder: (_) => [
            PopupMenuItem(value: widget.onHome, child: Text(widget.l10n.navHome)),
            PopupMenuItem(value: widget.onKits, child: const Text("Kits")),
            PopupMenuItem(value: widget.onBlog, child: Text(widget.l10n.navBlog)),
            const PopupMenuDivider(),
            PopupMenuItem(value: widget.onLanguage, child: Text(widget.languageLabel)),
            if (widget.isLoggedIn)
              PopupMenuItem(value: widget.onProfile, child: const Text("Profile"))
            else ...[
              PopupMenuItem(value: widget.onLogin, child: Text(widget.l10n.navLogin)),
              PopupMenuItem(
                value: widget.onSignUp,
                child: Text(widget.l10n.navSignUp, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Style helpers (bouncy logo, elastic nav item hover, jiggly cart
// badge, avatar chip).
// ============================================================

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
          return Transform.rotate(
            angle: _controller.isAnimating ? angle : 0,
            child: Transform.scale(
              scale: _controller.isAnimating ? 1 + 0.1 * (1 - _controller.value) : 1,
              child: child,
            ),
          );
        },
        child: Image.asset("assets/images/logo2.png", height: widget.height, fit: BoxFit.contain),
      ),
    );
  }
}

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

class _CartIconButton extends StatefulWidget {
  final double minSize;
  /// If non-null, shown instead of the live CartCubit count (legacy override).
  final int? countOverride;
  const _CartIconButton({required this.minSize, this.countOverride});

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

  Widget _icon(int count) {
    if (count != _lastCount) {
      _lastCount = count;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _jiggleController.forward(from: 0);
      });
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
            const Icon(Icons.shopping_cart_outlined, color: AppColors.cartTeal, size: 26),
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
                    child: Text(
                      '$count',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.countOverride != null) {
      return _icon(widget.countOverride!);
    }
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final count = state is CartLoaded ? state.cart.unitCount : 0;
        return _icon(count);
      },
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
        child: const CircleAvatar(
          backgroundColor: AppColors.cartTeal,
          child: Icon(Icons.person, color: Colors.white),
        ),
      ),
    );
  }
}