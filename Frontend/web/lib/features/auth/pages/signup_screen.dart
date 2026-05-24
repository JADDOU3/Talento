// lib/features/auth/pages/signup_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web/shared/i18n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../shared/components/custom_text_field.dart';
import '../../../shared/components/buttons/custom_button.dart';
import '../../../shared/services/auth_service.dart';       // ← AuthService
import '../../../shared/providers/language_provider.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController            = TextEditingController();
  final _emailController           = TextEditingController();
  final _passwordController        = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey                   = GlobalKey<FormState>();
  String _selectedGender           = '';
  bool _isLoading                  = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _goHome(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  Future<void> _signup() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedGender.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseSelectGender),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await AuthService.register(
      name:     _nameController.text.trim(),
      email:    _emailController.text.trim(),
      gender:   _selectedGender.toUpperCase(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.accountCreated),
          backgroundColor: const Color(0xFF10a896),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']?.toString() ?? 'Registration failed'),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 6),
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
                  InkWell(
                    onTap: () => _goHome(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset('assets/images/logo1.png', height: 60),
                  ),
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
                  Text(l10n.everyChild,
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      )),
                  Text(l10n.hiddenForest,
                      style: GoogleFonts.nunito(
                        color: const Color(0xFF10a896),
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      )),
                  Text(l10n.untappedPotential,
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        height: 1.3,
                      )),
                  const SizedBox(height: 16),
                  Text(l10n.signupDesc,
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
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: () => _goHome(context),
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Color(0xFF10a896),
                            ),
                            label: Text(
                              l10n.navHome,
                              style: const TextStyle(
                                color: Color(0xFF10a896),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          TextButton(
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
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(l10n.createAccount,
                          style: GoogleFonts.nunito(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1A1A1A),
                          )),
                      const SizedBox(height: 8),
                      Text(l10n.signupSubtitle,
                          style: GoogleFonts.nunito(
                            color: const Color(0xFF333333),
                            fontSize: 14,
                          )),
                      const SizedBox(height: 28),

                      // Full Name
                      CustomTextField(
                        label: l10n.fullName,
                        hint: 'Jane Doe',
                        controller: _nameController,
                        validator: (v) => v!.isEmpty ? l10n.nameRequired : null,
                      ),
                      const SizedBox(height: 20),

                      // Gender
                      Text(l10n.gender,
                          style: GoogleFonts.nunito(
                            fontSize: 11,
                            letterSpacing: 1.2,
                            color: const Color(0xFF333333),
                            fontWeight: FontWeight.w600,
                          )),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF10a896)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10a896).withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            hint: Row(
                              children: [
                                const Icon(Icons.person_outline,
                                    color: Colors.grey, size: 18),
                                const SizedBox(width: 8),
                                Text(l10n.selectGender,
                                    style: GoogleFonts.nunito(
                                        color: Colors.grey)),
                              ],
                            ),
                            value: _selectedGender.isEmpty
                                ? null
                                : _selectedGender,
                            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                                color: Color(0xFF10a896)),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            items: [
                              DropdownMenuItem(
                                value: 'Male',
                                child: Row(
                                  children: [
                                    const Icon(Icons.male,
                                        color: Color(0xFF48c5dc), size: 20),
                                    const SizedBox(width: 10),
                                    Text(l10n.male,
                                        style: GoogleFonts.nunito(
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                              DropdownMenuItem(
                                value: 'Female',
                                child: Row(
                                  children: [
                                    const Icon(Icons.female,
                                        color: Color(0xFFec6886), size: 20),
                                    const SizedBox(width: 10),
                                    Text(l10n.female,
                                        style: GoogleFonts.nunito(
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ],
                            onChanged: (v) =>
                                setState(() => _selectedGender = v!),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Email
                      CustomTextField(
                        label: l10n.emailAddress,
                        hint: 'jane@example.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) =>
                            v!.isEmpty ? l10n.emailRequired : null,
                      ),
                      const SizedBox(height: 20),

                      // Password
                      CustomTextField(
                        label: l10n.password,
                        hint: '••••••••',
                        controller: _passwordController,
                        isPassword: true,
                        validator: (v) =>
                            v!.isEmpty ? l10n.passwordRequired : null,
                      ),
                      const SizedBox(height: 20),

                      // Confirm Password
                      CustomTextField(
                        label: l10n.confirmPassword,
                        hint: '••••••••',
                        controller: _confirmPasswordController,
                        isPassword: true,
                        validator: (v) {
                          if (v!.isEmpty) return l10n.confirmPasswordRequired;
                          if (v != _passwordController.text)
                            return l10n.passwordsNotMatch;
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),

                      // Signup Button
                      _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFF10a896)))
                          : CustomButton(
                              text: l10n.signupButton,
                              onPressed: _signup,
                            ),
                      const SizedBox(height: 24),

                      // OR divider
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(l10n.orContinueWith,
                                style: GoogleFonts.nunito(
                                    color: const Color(0xFF333333),
                                    fontSize: 11)),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Social buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
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

                      // Login link
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(l10n.alreadyHaveAccount,
                                style: GoogleFonts.nunito(
                                    color: const Color(0xFF333333))),
                            GestureDetector(
                              onTap: () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginScreen()),
                              ),
                              child: Text(l10n.logIn,
                                  style: GoogleFonts.nunito(
                                    color: const Color(0xFF10a896),
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Security badges
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
                          const Icon(Icons.shield,
                              size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(l10n.gdprSecured,
                              style: GoogleFonts.nunito(
                                  fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}