import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../util/theme/app_colors.dart';
import '../../../shared/i18n/app_localizations.dart';
import '../../../shared/components/custom_text_field.dart';
import '../../../shared/services/auth_service.dart';
import '../../../shared/providers/language_provider.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedGender = 'Male';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);
    // More subtle animation - reduced from 15 to 5
    _floatAnimation = Tween<double>(begin: 0, end: 5).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Passwords do not match'),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await AuthService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        gender: _selectedGender.toUpperCase(),
      );

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Account created! Please login.'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Signup failed'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                // Floating decorations with subtle animation
                _FloatingDecoration('⭐', const Offset(0.1, 0.2), _floatAnimation),
                _FloatingDecoration('🎨', const Offset(0.85, 0.3), _floatAnimation, delay: 0.5),
                _FloatingDecoration('🚀', const Offset(0.15, 0.8), _floatAnimation, delay: 0.3),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.palette_outlined, color: Colors.white, size: 40),
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
                            l10n.everyChild,
                            style: GoogleFonts.nunito(
                              color: Colors.white,
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            l10n.hiddenForest,
                            style: GoogleFonts.nunito(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
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
                        l10n.signupDesc,
                        style: GoogleFonts.nunito(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 16,
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

        // RIGHT SIDE - Signup Form
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
                      // Header with back and language
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back, color: AppColors.cartTeal, size: 18),
                            label: Text(
                              l10n.navHome,
                              style: const TextStyle(
                                color: AppColors.cartTeal,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                            ),
                          ),
                          Container(
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
                        ],
                      ),

                      const SizedBox(height: 20),

                      Text(
                        l10n.createAccount,
                        style: GoogleFonts.nunito(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppColors.cartTeal,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.signupSubtitle,
                        style: GoogleFonts.nunito(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Full Name
                      CustomTextField(
                        label: l10n.fullName,
                        hint: 'Jane Doe',
                        controller: _nameController,
                        validator: (v) => v!.isEmpty ? l10n.nameRequired : null,
                      ),
                      const SizedBox(height: 16),

                      // Gender Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cartTeal.withValues(alpha: 0.3)),
                          color: Colors.grey[50],
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedGender,
                            isExpanded: true,
                            onChanged: (v) => setState(() => _selectedGender = v!),
                            items: ['Male', 'Female'].map((g) {
                              return DropdownMenuItem(
                                value: g,
                                child: Text(
                                  g,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }).toList(),
                            icon: Icon(Icons.arrow_drop_down, color: AppColors.cartTeal),
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Email
                      CustomTextField(
                        label: l10n.emailAddress,
                        hint: 'jane@example.com',
                        controller: _emailController,
                        validator: (v) => v!.isEmpty ? l10n.emailRequired : null,
                      ),
                      const SizedBox(height: 16),

                      // Password with show/hide
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
                      const SizedBox(height: 16),

                      // Confirm Password with show/hide
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            label: l10n.confirmPassword,
                            hint: '••••••••',
                            controller: _confirmPasswordController,
                            isPassword: _obscureConfirmPassword,
                            validator: (v) => v!.isEmpty ? l10n.confirmPasswordRequired : null,
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                              child: Text(
                                _obscureConfirmPassword ? 'Show' : 'Hide',
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
                      const SizedBox(height: 32),

                      // Signup Button
                      _isLoading
                          ? Center(
                        child: Column(
                          children: [
                            const CircularProgressIndicator(
                              color: AppColors.cartTeal,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Creating account...',
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
                            onPressed: _signup,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.arrow_forward_rounded, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  l10n.signupButton,
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

                      // Login Link
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                          },
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.nunito(fontSize: 14),
                              children: [
                                TextSpan(
                                  text: l10n.alreadyHaveAccount,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                TextSpan(
                                  text: ' ${l10n.logIn}',
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
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
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
              const SizedBox(height: 16),

              // Welcome Message
              Text(
                l10n.createAccount,
                style: GoogleFonts.nunito(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.signupSubtitle,
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
                        label: l10n.fullName,
                        hint: 'Jane Doe',
                        controller: _nameController,
                        validator: (v) => v!.isEmpty ? l10n.nameRequired : null,
                      ),
                      const SizedBox(height: 16),

                      // Gender Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cartTeal.withValues(alpha: 0.3)),
                          color: Colors.grey[50],
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedGender,
                            isExpanded: true,
                            onChanged: (v) => setState(() => _selectedGender = v!),
                            items: ['Male', 'Female'].map((g) {
                              return DropdownMenuItem(
                                value: g,
                                child: Text(
                                  g,
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                  ),
                                ),
                              );
                            }).toList(),
                            icon: Icon(Icons.arrow_drop_down, color: AppColors.cartTeal),
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(
                        label: l10n.emailAddress,
                        hint: 'jane@example.com',
                        controller: _emailController,
                        validator: (v) => v!.isEmpty ? l10n.emailRequired : null,
                      ),
                      const SizedBox(height: 16),

                      // Password with show/hide
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
                      const SizedBox(height: 16),

                      // Confirm Password with show/hide
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextField(
                            label: l10n.confirmPassword,
                            hint: '••••••••',
                            controller: _confirmPasswordController,
                            isPassword: _obscureConfirmPassword,
                            validator: (v) => v!.isEmpty ? l10n.confirmPasswordRequired : null,
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                              child: Text(
                                _obscureConfirmPassword ? 'Show' : 'Hide',
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
                      const SizedBox(height: 24),

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
                          onPressed: _signup,
                          child: Text(
                            l10n.signupButton,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Center(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                          },
                          child: RichText(
                            text: TextSpan(
                              style: GoogleFonts.nunito(fontSize: 13),
                              children: [
                                TextSpan(
                                  text: l10n.alreadyHaveAccount,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                TextSpan(
                                  text: ' ${l10n.logIn}',
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
  final String emoji;
  final Offset position;
  final Animation<double> floatAnimation;
  final double delay;

  const _FloatingDecoration(
      this.emoji,
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
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}