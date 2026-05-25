import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/auth_switch_text.dart';
import '../../shared/widgets/social_button.dart';
import '../../shared/widgets/app_background.dart';
import '../../services/auth/auth_service.dart';
import '../home/new_user.dart';
import 'signup_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../cubits/child_mode/child_mode_cubit.dart';

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
        backgroundColor: isError ? AppColors.red : AppColors.primary,
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.login(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      await context.read<ChildModeCubit>().checkChildMode();

      if (!mounted) return;

      _showMessage('تم تسجيل الدخول بنجاح');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const NewUser(),
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
              vertical: 16,
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),

                Image.asset(
                  'assets/icons/logo1.png',
                  height: 105,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 430),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 28,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.65),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
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
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'لنبدأ رحلة ممتعة نحو اكتشاف المواهب',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 18,
                            height: 1.5,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),

                        const SizedBox(height: 24),

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
                            onPressed: () {},
                            child: Text(
                              'هل نسيت كلمة المرور؟',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.pink.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        _isLoading
                            ? const CircularProgressIndicator()
                            : CustomButton(
                          text: 'تسجيل الدخول',
                          onPressed: _login,
                        ),

                        const SizedBox(height: 18),

                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                color: AppColors.secondary.withValues(alpha: 0.2),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Text('التواصل الاحتماعي'),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                color: AppColors.secondary.withValues(alpha: 0.2),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

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

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}