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

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedGender = 'Male'; // Default value
  bool _isLoading = false;

  Future<void> _signup() async {
    // 1. Validate the form
    if (!_formKey.currentState!.validate()) return;

    // 2. Validate password match
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 3. Call your AuthService
      // Assuming you have a register method in AuthService
      final result = await AuthService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        gender: _selectedGender.toUpperCase(), // Match your database enum
      );

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created! Please login.'), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Return to Login
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Signup failed'), backgroundColor: Colors.redAccent),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final langProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      body: Row(
        children: [
          // LEFT SIDE
          Expanded(
            child: Container(
              color: AppColors.cartTeal,
              padding: const EdgeInsets.all(48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.palette_outlined, color: Colors.white, size: 40),
                  const Spacer(),
                  Text(l10n.everyChild, style: GoogleFonts.nunito(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900)),
                  Text(l10n.hiddenForest, style: GoogleFonts.nunito(color: Colors.white.withOpacity(0.7), fontSize: 42, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 24),
                  Text(l10n.signupDesc, style: GoogleFonts.nunito(color: Colors.white, fontSize: 16, height: 1.6)),
                  const Spacer(),
                ],
              ),
            ),
          ),

          // RIGHT SIDE
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back, color: AppColors.cartTeal),
                            label: Text(l10n.navHome, style: const TextStyle(color: AppColors.cartTeal, fontWeight: FontWeight.bold)),
                          ),
                          TextButton(
                            onPressed: () => langProvider.toggleLanguage(),
                            child: Text(l10n.language, style: const TextStyle(color: AppColors.cartTeal, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text(l10n.createAccount, style: GoogleFonts.nunito(fontSize: 32, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 32),

                      // Inputs
                      CustomTextField(label: l10n.fullName, hint: 'Jane Doe', controller: _nameController),
                      const SizedBox(height: 16),

                      // Gender Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.cartTeal),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedGender,
                            isExpanded: true,
                            onChanged: (v) => setState(() => _selectedGender = v!),
                            items: ['Male', 'Female'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      CustomTextField(label: l10n.emailAddress, hint: 'jane@example.com', controller: _emailController),
                      const SizedBox(height: 16),
                      CustomTextField(label: l10n.password, hint: '••••••••', controller: _passwordController, isPassword: true),
                      const SizedBox(height: 16),
                      CustomTextField(label: l10n.confirmPassword, hint: '••••••••', controller: _confirmPasswordController, isPassword: true),
                      const SizedBox(height: 32),

                      // Signup Button
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.cartTeal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                          onPressed: _signup,
                          child: Text(l10n.signupButton, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
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