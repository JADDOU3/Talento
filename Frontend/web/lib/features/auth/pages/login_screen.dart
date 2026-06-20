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

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

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
        SnackBar(content: Text(result['message'] ?? 'Login failed'), backgroundColor: Colors.redAccent),
      );
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
                  const Icon(Icons.stars, color: Colors.white, size: 40),
                  const Spacer(),
                  Text(l10n.welcomeBackTitle, style: GoogleFonts.nunito(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 16),
                  Text(l10n.welcomeBackDesc, style: GoogleFonts.nunito(color: Colors.white.withOpacity(0.9), fontSize: 18, height: 1.6)),
                  const Spacer(),
                ],
              ),
            ),
          ),

          // RIGHT SIDE
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 40),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        onPressed: () => langProvider.toggleLanguage(),
                        child: Text(l10n.language, style: const TextStyle(color: AppColors.cartTeal, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    Text(l10n.welcomeBack, style: GoogleFonts.nunito(fontSize: 32, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 32),
                    CustomTextField(label: l10n.emailAddress, hint: 'name@example.com', controller: _emailController, validator: (v) => v!.isEmpty ? l10n.emailRequired : null),
                    const SizedBox(height: 20),
                    CustomTextField(label: l10n.password, hint: '••••••••', controller: _passwordController, isPassword: true, validator: (v) => v!.isEmpty ? l10n.passwordRequired : null),
                    const SizedBox(height: 32),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator(color: AppColors.cartTeal))
                        : SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.cartTeal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                        onPressed: _login,
                        child: Text(l10n.loginButton, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
                        child: Text(l10n.dontHaveAccount, style: GoogleFonts.nunito(color: Colors.black54)),
                      ),
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