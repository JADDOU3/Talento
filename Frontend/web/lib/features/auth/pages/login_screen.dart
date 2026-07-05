import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../util/theme/app_colors.dart';
import '../../../shared/i18n/app_localizations.dart';
import '../../../shared/components/custom_text_field.dart';
import '../../../shared/services/auth_service.dart';
import '../../../shared/providers/language_provider.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    // Subtle animation - reduced from 15 to 5
    _floatAnimation = Tween<double>(begin: 0, end: 5).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final result = await AuthService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    final l10n = AppLocalizations.of(context)!;

    if (result['success'] == true) {
      Navigator.pushReplacementNamed(context, '/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 8),
              Text(result['message'] ?? 'Login failed'),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final langProvider = Provider.of<LanguageProvider>(context);
    final isArabic = langProvider.locale.languageCode == 'ar';

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 900;

          if (isDesktop) {
            return _desktopLayout(l10n, langProvider, isArabic);
          } else {
            return _mobileLayout(l10n, langProvider, isArabic);
          }
        },
      ),
    );
  }

  Widget _desktopLayout(AppLocalizations l10n, LanguageProvider langProvider, bool isArabic) {
    return Row(
      children: [
        // LEFT SIDE - Hero Section
        Expanded(
          flex: 5,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.cartTeal,
                  AppColors.cartTeal.withValues(alpha: 0.8),
                  const Color(0xFF3FA796),
                ],
              ),
            ),
            padding: const EdgeInsets.all(48),
            child: Stack(
              children: [
                // Subtle floating decorations (removed emojis, using simple shapes)
                _FloatingDecoration(Icons.star, const Offset(0.1, 0.2), _floatAnimation),
                _FloatingDecoration(Icons.circle, const Offset(0.85, 0.3), _floatAnimation, delay: 0.5),
                _FloatingDecoration(Icons.star_half, const Offset(0.15, 0.8), _floatAnimation, delay: 0.3),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.stars, color: Colors.white, size: 40),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            l10n.nurturingTomorrow,
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Transform.translate(
                          offset: Offset(15 * (1 - value), 0),
                          child: Opacity(
                            opacity: value,
                            child: child,
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.welcomeBackTitle,
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.learningGarden,
                            style: GoogleFonts.nunito(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 32,
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 1000),
                      builder: (context, value, child) {
                        return Opacity(
                          opacity: value,
                          child: child,
                        );
                      },
                      child: Text(
                        l10n.welcomeBackDesc,
                        style: GoogleFonts.nunito(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 18,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Stats
                    Row(
                      children: [
                        _buildStatItem('50K+', 'Families', Icons.family_restroom),
                        const SizedBox(width: 32),
                        _buildStatItem('4.9', 'Rating', Icons.star),
                        const SizedBox(width: 32),
                        _buildStatItem('24', 'Kits', Icons.school),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              ],
            ),
          ),
        ),

        // RIGHT SIDE - Login Form
        Expanded(
          flex: 4,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
            child: Center(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Language Toggle
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.cartTeal.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.cartTeal.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: TextButton.icon(
                            onPressed: () => langProvider.toggleLanguage(),
                            icon: Icon(
                              isArabic ? Icons.translate : Icons.translate,
                              size: 16,
                              color: AppColors.cartTeal,
                            ),
                            label: Text(
                              l10n.language,
                              style: const TextStyle(
                                color: AppColors.cartTeal,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        l10n.welcomeBack,
                        style: GoogleFonts.nunito(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.cartTeal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.loginSubtitle,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Email Field
                      CustomTextField(
                        label: l10n.emailAddress,
                        hint: 'name@example.com',
                        controller: _emailController,
                        validator: (v) => v!.isEmpty ? l10n.emailRequired : null,
                      ),
                      const SizedBox(height: 20),

                      // Password Field with show/hide button
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            label: l10n.password,
                            hint: '••••••••',
                            controller: _passwordController,
                            isPassword: _obscurePassword,
                            validator: (v) => v!.isEmpty ? l10n.passwordRequired : null,
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              child: Text(
                                _obscurePassword ? 'Show' : 'Hide',
                                style: TextStyle(
                                  color: AppColors.cartTeal,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Forgot Password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            l10n.forgotPassword,
                            style: TextStyle(
                              color: AppColors.cartTeal,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Login Button
                      _isLoading
                          ? Center(
                        child: Column(
                          children: [
                            const CircularProgressIndicator(
                              color: AppColors.cartTeal,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Logging in...',
                              style: TextStyle(
                                color: AppColors.cartTeal,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                          : TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0.97, end: 1.0),
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: child,
                          );
                        },
                        child: SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.cartTeal,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _login,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.arrow_forward_rounded, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.loginButton,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[300])),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              l10n.orContinueWith,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey[300])),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Social Login Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black87,
                                side: BorderSide(color: Colors.grey[300]!),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.g_mobiledata, size: 24, color: Colors.red),
                              label: Text(l10n.google),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black87,
                                side: BorderSide(color: Colors.grey[300]!),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.apple, size: 24, color: Colors.black),
                              label: Text(l10n.apple),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Sign Up Link
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SignupScreen()),
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.nunito(fontSize: 14),
                              children: [
                                TextSpan(
                                  text: l10n.dontHaveAccount,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                TextSpan(
                                  text: ' ${l10n.signUp}',
                                  style: const TextStyle(
                                    color: AppColors.cartTeal,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _mobileLayout(AppLocalizations l10n, LanguageProvider langProvider, bool isArabic) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.cartTeal,
            AppColors.cartTeal.withValues(alpha: 0.7),
            Colors.white,
            Colors.white,
          ],
          stops: const [0.0, 0.3, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.stars, color: Colors.white, size: 32),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextButton.icon(
                      onPressed: () => langProvider.toggleLanguage(),
                      icon: Icon(
                        isArabic ? Icons.translate : Icons.translate,
                        size: 16,
                        color: Colors.white,
                      ),
                      label: Text(
                        l10n.language,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Welcome Message
              Text(
                l10n.welcomeBack,
                style: GoogleFonts.nunito(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.loginSubtitle,
                style: GoogleFonts.nunito(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Form Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        label: l10n.emailAddress,
                        hint: 'name@example.com',
                        controller: _emailController,
                        validator: (v) => v!.isEmpty ? l10n.emailRequired : null,
                      ),
                      const SizedBox(height: 16),

                      // Password Field with show/hide button
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            label: l10n.password,
                            hint: '••••••••',
                            controller: _passwordController,
                            isPassword: _obscurePassword,
                            validator: (v) => v!.isEmpty ? l10n.passwordRequired : null,
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              child: Text(
                                _obscurePassword ? 'Show' : 'Hide',
                                style: TextStyle(
                                  color: AppColors.cartTeal,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            l10n.forgotPassword,
                            style: TextStyle(
                              color: AppColors.cartTeal,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _isLoading
                          ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.cartTeal,
                        ),
                      )
                          : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.cartTeal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _login,
                          child: Text(
                            l10n.loginButton,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey[300])),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              l10n.orContinueWith,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey[300])),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black87,
                                side: BorderSide(color: Colors.grey[300]!),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.g_mobiledata, size: 20, color: Colors.red),
                              label: Text(l10n.google),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black87,
                                side: BorderSide(color: Colors.grey[300]!),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.apple, size: 20, color: Colors.black),
                              label: Text(l10n.apple),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SignupScreen()),
                          ),
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.nunito(fontSize: 13),
                              children: [
                                TextSpan(
                                  text: l10n.dontHaveAccount,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                TextSpan(
                                  text: ' ${l10n.signUp}',
                                  style: const TextStyle(
                                    color: AppColors.cartTeal,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        Row(
          children: [
            Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 14),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.nunito(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FloatingDecoration extends StatelessWidget {
  final IconData icon;
  final Offset position;
  final Animation<double> floatAnimation;
  final double delay;

  const _FloatingDecoration(
      this.icon,
      this.position,
      this.floatAnimation, {
        this.delay = 0,
      });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx * MediaQuery.of(context).size.width,
      top: position.dy * MediaQuery.of(context).size.height,
      child: AnimatedBuilder(
        animation: floatAnimation,
        builder: (context, child) {
          final delayedValue = (floatAnimation.value + delay) % 1.0;
          final offset = 5 * delayedValue;
          return Transform.translate(
            offset: Offset(0, -offset),
            child: Opacity(
              opacity: 0.5 + 0.5 * (1 - delayedValue.abs()),
              child: child,
            ),
          );
        },
        child: Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.15),
          size: 32,
        ),
      ),
    );
  }
}