// lib/features/auth/pages/login_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web/shared/i18n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../shared/components/custom_text_field.dart';
import '../../../shared/components/buttons/custom_button.dart';
import '../../../shared/services/auth_service.dart';       // ← AuthService
import '../../../shared/providers/language_provider.dart';
import 'signup_screen.dart';
import '../../home/pages/home_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey            = GlobalKey<FormState>();
  bool _isLoading           = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final result = await AuthService.login(
      email:    _emailController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    final l10n = AppLocalizations.of(context)!;

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.loginSuccess),
          backgroundColor: const Color(0xFF10a896),
        ),
      );
      // Navigate to home and clear back stack
      Navigator.pushReplacementNamed(context, '/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']?.toString() ?? 'Invalid credentials'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n         = AppLocalizations.of(context)!;
    final langProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: Row(
        children: [
          // ===== LEFT SIDE =====
          Expanded(
            child: Container(
              color: const Color(0xFF0D2B1F),
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset('assets/images/logo1.png', height: 60),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.eco, color: Color(0xFF10a896), size: 14),
                      const SizedBox(width: 4),
                      Text(l10n.nurturingTomorrow,
                          style: GoogleFonts.nunito(
                            color: const Color(0xFF10a896),
                            fontSize: 11,
                            letterSpacing: 1.5,
                          )),
                    ],
                  ),
                  const Spacer(),
                  Text(l10n.welcomeBackTitle,
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      )),
                  Text(l10n.learningGarden,
                      style: GoogleFonts.nunito(
                        color: const Color(0xFF10a896),
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      )),
                  const SizedBox(height: 16),
                  Text(l10n.welcomeBackDesc,
                      style: GoogleFonts.nunito(
                        color: Colors.white60,
                        fontSize: 13,
                        height: 1.6,
                      )),
                  const Spacer(),
                  Row(
                    children: [
                      Image.asset('assets/images/icon.png', height: 40),
                      const SizedBox(width: 12),
                      Text(l10n.trustedByEducators,
                          style: GoogleFonts.nunito(
                            color: Colors.white60,
                            fontSize: 12,
                          )),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(l10n.copyright,
                      style: GoogleFonts.nunito(
                        color: Colors.white30,
                        fontSize: 11,
                      )),
                ],
              ),
            ),
          ),

          // ===== RIGHT SIDE =====
          Expanded(
            child: Container(
              color: const Color(0xFFFAF7F4),
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Language Toggle
                    Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        onPressed: () => langProvider.toggleLanguage(),
                        child: Text(
                          l10n.language,
                          style: const TextStyle(
                            color: Color(0xFF10a896),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(l10n.welcomeBack,
                        style: GoogleFonts.nunito(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1A1A1A),
                        )),
                    const SizedBox(height: 8),
                    Text(l10n.loginSubtitle,
                        style: GoogleFonts.nunito(
                          color: const Color(0xFF333333),
                          fontSize: 14,
                        )),
                    const SizedBox(height: 36),
                    CustomTextField(
                      label: l10n.emailAddress,
                      hint: 'jane@example.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => v!.isEmpty ? l10n.emailRequired : null,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      label: l10n.password,
                      hint: '••••••••',
                      controller: _passwordController,
                      isPassword: true,
                      suffixText: l10n.forgotPassword,
                      validator: (v) => v!.isEmpty ? l10n.passwordRequired : null,
                    ),
                    const SizedBox(height: 28),
                    _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFF10a896)))
                        : CustomButton(
                            text: l10n.loginButton,
                            onPressed: _login,
                          ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(l10n.orContinueWith,
                              style: GoogleFonts.nunito(
                                  color: const Color(0xFF333333),
                                  fontSize: 11)),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide.none,
                              backgroundColor: const Color(0xFFdce3f8),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset('assets/images/google.png',
                                    height: 20),
                                const SizedBox(width: 8),
                                Text(l10n.google,
                                    style: GoogleFonts.nunito(
                                        color: const Color(0xFF1a1a4b),
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.apple, size: 22),
                            label: Text(l10n.apple,
                                style: GoogleFonts.nunito()),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide.none,
                              foregroundColor: const Color(0xFF4a0030),
                              backgroundColor: const Color(0xFFfadadd),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(l10n.dontHaveAccount,
                              style: GoogleFonts.nunito(
                                  color: const Color(0xFF333333))),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SignupScreen()),
                            ),
                            child: Text(l10n.signUp,
                                style: GoogleFonts.nunito(
                                  color: const Color(0xFF10a896),
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.lock, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(l10n.aesEncrypted,
                            style: GoogleFonts.nunito(
                                fontSize: 10, color: Colors.grey)),
                        const SizedBox(width: 12),
                        const Icon(Icons.verified_user,
                            size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(l10n.coppaCompliant,
                            style: GoogleFonts.nunito(
                                fontSize: 10, color: Colors.grey)),
                        const SizedBox(width: 12),
                        const Icon(Icons.shield, size: 12, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(l10n.gdprSecured,
                            style: GoogleFonts.nunito(
                                fontSize: 10, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}