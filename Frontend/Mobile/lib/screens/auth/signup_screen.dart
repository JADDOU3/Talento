import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';
import '../../shared/widgets/auth_switch_text.dart';
import '../../shared/widgets/app_background.dart';
import '../../services/auth_service.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  final AuthService _authService = AuthService();

  String? selectedRelation;
  bool _isLoading = false;

  final List<String> relations = ['الأم', 'الأب', 'أخرى'];

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  String _mapRelationToGender(String relation) {
    switch (relation) {
      case 'الأم':
        return 'FEMALE';
      case 'الأب':
        return 'MALE';
      case 'أخرى':
        return 'MALE';
      default:
        return 'MALE';
    }
  }

  String _cleanErrorMessage(Object error) {
    String message = error.toString();

    if (message.startsWith('Exception: ')) {
      message = message.replaceFirst('Exception: ', '');
    }

    final normalizedMessage = message.toLowerCase().trim();

    if (normalizedMessage.contains('already') &&
        normalizedMessage.contains('exist')) {
      return 'هذا البريد الإلكتروني مستخدم بالفعل';
    }

    if (normalizedMessage.contains('not authenticated')) {
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

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedRelation == null) {
      _showMessage('يرجى اختيار صلة القرابة', isError: true);
      return;
    }

    if (passwordController.text.trim() !=
        confirmPasswordController.text.trim()) {
      _showMessage('كلمتا المرور غير متطابقتين', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _authService.register(
        name: fullNameController.text.trim(),
        email: emailController.text.trim(),
        gender: _mapRelationToGender(selectedRelation!),
        password: passwordController.text.trim(),
      );

      if (!mounted) return;

      if (response.trim() == 'User registered successfully') {
        _showMessage('تم إنشاء الحساب بنجاح');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      } else {
        _showMessage(_cleanErrorMessage(response), isError: true);      }
    }  catch (e) {
  print(e.toString());
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
                  height: 110,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 18),
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
                          'ابدأ الرحلة !',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.headlineLarge.copyWith(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'قم بإنشاء حساب لبدء استكشاف عالم المعرفة مع طفلك',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildFieldLabel('الاسم الكامل'),
                        const SizedBox(height: 8),
                        CustomTextField(
                          hintText: 'أدخل اسمك الكامل',
                          controller: fullNameController,
                          prefixIcon: Icons.person_outline_rounded,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'هذا الحقل مطلوب';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        _buildFieldLabel('البريد الإلكتروني'),
                        const SizedBox(height: 8),
                        CustomTextField(
                          hintText: 'hello@example.com',
                          controller: emailController,
                          prefixIcon: Icons.mail_outline_rounded,
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

                        _buildFieldLabel('صلة القرابة'),
                        const SizedBox(height: 8),
                        _buildRelationSelector(),

                        const SizedBox(height: 16),

                        _buildFieldLabel('كلمة المرور'),
                        const SizedBox(height: 8),
                        CustomTextField(
                          hintText: '••••••••',
                          controller: passwordController,
                          prefixIcon: Icons.lock_outline_rounded,
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'هذا الحقل مطلوب';
                            }
                            if (value.length < 6) {
                              return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        _buildFieldLabel('تأكيد كلمة المرور'),
                        const SizedBox(height: 8),
                        CustomTextField(
                          hintText: '••••••••',
                          controller: confirmPasswordController,
                          prefixIcon: Icons.lock_reset_rounded,
                          isPassword: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'هذا الحقل مطلوب';
                            }
                            if (value != passwordController.text) {
                              return 'كلمتا المرور غير متطابقتين';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 26),

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
                            text: 'إنشاء حساب',
                            onPressed: _signup,
                          ),
                        ),

                        const SizedBox(height: 18),

                        AuthSwitchText(
                          questionText: 'لديك حساب بالفعل؟',
                          actionText: 'سجّل الدخول هنا',
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 10),
                        _buildBottomFeatures(),
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

  Widget _buildFieldLabel(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildRelationSelector() {
    return Row(
      textDirection: TextDirection.rtl,
      children: relations.map((relation) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: relation == relations.first ? 0 : 8,
            ),
            child: _buildRelationItem(relation),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRelationItem(String relation) {
    final bool isSelected = selectedRelation == relation;

    return InkWell(
      onTap: () {
        setState(() {
          selectedRelation = relation;
        });
      },
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        height: 58,
        decoration: BoxDecoration(
          color: isSelected
              ? _getRelationBackgroundColor(relation)
              : AppColors.inputFill,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? _getRelationAccentColor(relation)
                : AppColors.border,
            width: isSelected ? 1.6 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: _getRelationAccentColor(relation).withValues(
                alpha: 0.18,
              ),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          textDirection: TextDirection.rtl,
          children: [
            Icon(
              _getRelationIcon(relation),
              size: isSelected ? 30 : 24,
              color: isSelected
                  ? _getRelationAccentColor(relation)
                  : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              relation,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected
                    ? _getRelationAccentColor(relation)
                    : AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRelationAccentColor(String relation) {
    switch (relation) {
      case 'الأم':
        return AppColors.pink;
      case 'الأب':
        return AppColors.primary;
      default:
        return AppColors.yellow;
    }
  }

  Color _getRelationBackgroundColor(String relation) {
    switch (relation) {
      case 'الأم':
        return AppColors.pink.withValues(alpha: 0.10);
      case 'الأب':
        return AppColors.primary.withValues(alpha: 0.10);
      default:
        return AppColors.yellow.withValues(alpha: 0.10);
    }
  }

  IconData _getRelationIcon(String relation) {
    switch (relation) {
      case 'الأم':
        return Icons.girl;
      case 'الأب':
        return Icons.boy;
      default:
        return Icons.groups_2_outlined;
    }
  }

  Widget _buildBottomFeatures() {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        textDirection: TextDirection.rtl,
        children: const [
          _FeatureItem(
            icon: Icons.shield_outlined,
            text: 'بيانات آمنة',
          ),
          _FeatureItem(
            icon: Icons.people_outline,
            text: 'متابعة يومية',
          ),
          _FeatureItem(
            icon: Icons.rocket_launch_outlined,
            text: 'تعلم ممتع',
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureItem({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 22,
        ),
        const SizedBox(height: 6),
        Text(
          text,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}