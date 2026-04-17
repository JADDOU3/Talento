import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/auth_switch_text.dart';
import '../../shared/widgets/social_button.dart';
import '../../shared/widgets/app_background.dart';
import '../../services/auth_service.dart';
import '../../services/token_storage_service.dart';
import '../home/home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String _cleanErrorMessage(Object error) {
    String message = error.toString();

    if (message.startsWith('Exception: ')) {
      message = message.replaceFirst('Exception: ', '');
    }

    final normalized = message.toLowerCase().trim();

    if (normalized.contains('not authenticated')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    }

    return message;
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final token = await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final cleanToken = token.trim();

      if (!cleanToken.contains('.') || cleanToken.split('.').length != 3) {
        throw Exception('not authenticated');
      }

      await TokenStorageService.saveToken(cleanToken);

      if (!mounted) return;

      _showMessage('تم تسجيل الدخول بنجاح');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showMessage(_cleanErrorMessage(e), isError: true);
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            child: Column(
              children: [
                const SizedBox(height: 8),
                Image.asset(
                  'assets/icons/logo1.png',
                  height: 120,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 430),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 28,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.65),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.10),
                        blurRadius: 30,
                        offset: const Offset(0, 14),
                      ),
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.04),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          'أهلاً بك من جديد!',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headlineLarge.copyWith(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'لنبدأ رحلة ممتعة نحو اكتشاف المواهب',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 26),

                        CustomTextField(
                          hintText: 'البريد الإلكتروني',
                          controller: emailController,
                          prefixIcon: Icons.alternate_email_rounded,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'هذا الحقل مطلوب';
                            }
                            if (!value.contains('@')) {
                              return 'أدخل بريدًا إلكترونيًا صحيحًا';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        CustomTextField(
                          hintText: 'كلمة المرور',
                          controller: passwordController,
                          prefixIcon: Icons.lock_outline_rounded,
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'هذا الحقل مطلوب';
                            }
                            return null;
                          },
                        ),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'ميزة استعادة كلمة المرور ستتم إضافتها لاحقًا',
                                    textDirection: TextDirection.rtl,
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              );
                            },
                            child: const Text('هل نسيت كلمة المرور؟'),
                          ),
                        ),

                        const SizedBox(height: 8),

                        _isLoading
                            ? const CircularProgressIndicator()
                            : DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withValues(
                                  alpha: 0.20,
                                ),
                                blurRadius: 18,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: CustomButton(
                            text: 'تسجيل الدخول',
                            onPressed: _login,
                          ),
                        ),

                        const SizedBox(height: 20),

                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: AppColors.secondary.withValues(
                                  alpha: 0.18,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Text(
                                'أو',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary.withValues(
                                    alpha: 0.8,
                                  ),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: AppColors.secondary.withValues(
                                  alpha: 0.18,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        Row(
                          children: [
                            SocialButton(
                              text: 'Facebook',
                              assetPath: 'assets/icons/facebook.png',
                              onTap: () {},
                            ),
                            const SizedBox(width: 12),
                            SocialButton(
                              text: 'Google',
                              assetPath: 'assets/icons/google.png',
                              onTap: () {},
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        AuthSwitchText(
                          questionText: 'ليس لديك حساب؟',
                          actionText: 'انشاء حساب',
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignupScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
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