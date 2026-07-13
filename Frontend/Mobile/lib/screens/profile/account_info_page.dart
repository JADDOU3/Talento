import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AccountInfoPage extends StatefulWidget {
  const AccountInfoPage({super.key});

  @override
  State<AccountInfoPage> createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends State<AccountInfoPage> {
  final _formKey = GlobalKey<FormState>();

  // Temporary preview values until the account endpoint is connected.
  final TextEditingController _nameController = TextEditingController(
    text: 'اسم ولي الأمر',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'parent@example.com',
  );
  final TextEditingController _passwordController = TextEditingController(
    text: '12345678',
  );

  bool _isEditing = false;
  bool _isSaving = false;
  String _selectedRelation = 'الأم';

  String _savedName = 'اسم ولي الأمر';
  String _savedEmail = 'parent@example.com';
  String _savedPassword = '12345678';
  String _savedRelation = 'الأم';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _startEditing() {
    setState(() => _isEditing = true);
  }

  void _cancelEditing() {
    _nameController.text = _savedName;
    _emailController.text = _savedEmail;
    _passwordController.text = _savedPassword;

    setState(() {
      _selectedRelation = _savedRelation;
      _isEditing = false;
    });
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    // UI-only delay. Replace this block with the update-account request later.
    await Future<void>.delayed(const Duration(milliseconds: 550));

    if (!mounted) return;

    _savedName = _nameController.text.trim();
    _savedEmail = _emailController.text.trim();
    _savedPassword = _passwordController.text;
    _savedRelation = _selectedRelation;

    setState(() {
      _isSaving = false;
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Row(
          textDirection: TextDirection.rtl,
          children: [
            const Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.white,
            ),
            const SizedBox(width: 10),
            Text(
              'تم حفظ التعديلات بنجاح',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          leading: IconButton(
            tooltip: 'رجوع',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          title: Text(
            'معلومات الحساب',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          actions: [
            if (!_isEditing)
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: TextButton.icon(
                  onPressed: _startEditing,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: Text(
                    'تعديل',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: Stack(
          children: [
            const Positioned(
              top: -80,
              left: -70,
              child: _BackgroundCircle(
                size: 190,
                color: AppColors.secondary,
              ),
            ),
            const Positioned(
              top: 210,
              right: -70,
              child: _BackgroundCircle(
                size: 165,
                color: AppColors.pink,
              ),
            ),
            SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SectionHeader(
                        title: 'بيانات ولي الأمر',
                        subtitle: _isEditing
                            ? 'عدّل البيانات التي ترغب بتحديثها'
                            : 'البيانات الأساسية المرتبطة بحسابك',
                        icon: Icons.badge_outlined,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.96),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.10),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withValues(alpha: 0.035),
                              blurRadius: 18,
                              offset: const Offset(0, 7),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _FieldLabel(
                              text: 'الاسم الكامل',
                              icon: Icons.person_outline_rounded,
                            ),
                            const SizedBox(height: 8),
                            _AccountTextField(
                              controller: _nameController,
                              hintText: 'أدخل الاسم الكامل',
                              icon: Icons.person_outline_rounded,
                              enabled: _isEditing,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'يرجى إدخال الاسم الكامل';
                                }
                                return null;
                              },
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 18),
                            const _FieldLabel(
                              text: 'البريد الإلكتروني',
                              icon: Icons.mail_outline_rounded,
                            ),
                            const SizedBox(height: 8),
                            _AccountTextField(
                              controller: _emailController,
                              hintText: 'hello@example.com',
                              icon: Icons.mail_outline_rounded,
                              enabled: false,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              validator: (value) {
                                final email = value?.trim() ?? '';
                                if (email.isEmpty) {
                                  return 'يرجى إدخال البريد الإلكتروني';
                                }
                                if (!email.contains('@') ||
                                    !email.contains('.')) {
                                  return 'أدخل بريدًا إلكترونيًا صحيحًا';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 18),
                            const _FieldLabel(
                              text: 'صلة القرابة',
                              icon: Icons.family_restroom_rounded,
                            ),
                            const SizedBox(height: 8),
                            _RelationSelector(
                              selectedRelation: _selectedRelation,
                              enabled: _isEditing,
                              onSelected: (relation) {
                                setState(() {
                                  _selectedRelation = relation;
                                });
                              },
                            ),
                            const SizedBox(height: 18),
                            const _FieldLabel(
                              text: 'كلمة المرور',
                              icon: Icons.lock_outline_rounded,
                            ),
                            const SizedBox(height: 8),
                            _AccountTextField(
                              controller: _passwordController,
                              hintText: 'أدخل كلمة المرور',
                              icon: Icons.lock_outline_rounded,
                              enabled: _isEditing,
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              validator: (value) {
                                final password = value ?? '';
                                if (password.isEmpty) {
                                  return 'يرجى إدخال كلمة المرور';
                                }
                                if (password.length < 6) {
                                  return 'يجب أن تتكون كلمة المرور من 6 أحرف على الأقل';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                      if (_isEditing) ...[
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: SizedBox(
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: _isSaving ? null : _saveChanges,
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.white,
                                    disabledBackgroundColor: AppColors.primary
                                        .withValues(alpha: 0.55),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  child: _isSaving
                                      ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: AppColors.white,
                                    ),
                                  )
                                      : Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.check_rounded,
                                        size: 21,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'حفظ التعديلات',
                                        style: AppTextStyles.button,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SizedBox(
                                height: 54,
                                child: OutlinedButton(
                                  onPressed:
                                  _isSaving ? null : _cancelEditing,
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.textSecondary,
                                    side: const BorderSide(
                                      color: AppColors.border,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  child: Text(
                                    'إلغاء',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final IconData icon;

  const _FieldLabel({
    required this.text,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          text,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _AccountTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool enabled;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final bool obscureText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const _AccountTextField({
    required this.controller,
    required this.hintText,
    required this.icon,
    required this.enabled,
    required this.textInputAction,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textAlign: TextAlign.right,
      validator: validator,
      onChanged: onChanged,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textPrimary,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.hint,
          fontSize: 13,
        ),
        prefixIcon: Icon(
          icon,
          color: enabled ? AppColors.primary : AppColors.textSecondary,
          size: 20,
        ),
        suffixIcon: enabled
            ? const Icon(
          Icons.edit_rounded,
          color: AppColors.primary,
          size: 17,
        )
            : const Icon(
          Icons.lock_outline_rounded,
          color: AppColors.hint,
          size: 17,
        ),
        filled: true,
        fillColor: enabled
            ? AppColors.white
            : AppColors.inputFill.withValues(alpha: 0.88),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.28),
            width: 1.2,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide(
            color: AppColors.border.withValues(alpha: 0.90),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.6,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(
            color: AppColors.error,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

class _RelationSelector extends StatelessWidget {
  final String selectedRelation;
  final bool enabled;
  final ValueChanged<String> onSelected;

  const _RelationSelector({
    required this.selectedRelation,
    required this.enabled,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RelationItem(
            label: 'الأم',
            icon: Icons.woman_2_rounded,
            accentColor: AppColors.pink,
            isSelected: selectedRelation == 'الأم',
            enabled: enabled,
            onTap: () => onSelected('الأم'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _RelationItem(
            label: 'الأب',
            icon: Icons.man_2_rounded,
            accentColor: AppColors.primary,
            isSelected: selectedRelation == 'الأب',
            enabled: enabled,
            onTap: () => onSelected('الأب'),
          ),
        ),
      ],
    );
  }
}

class _RelationItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accentColor;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  const _RelationItem({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.isSelected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(17),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        height: 58,
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: enabled ? 0.10 : 0.07)
              : AppColors.inputFill.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: isSelected
                ? accentColor.withValues(alpha: enabled ? 0.70 : 0.35)
                : AppColors.border,
            width: isSelected ? 1.3 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? accentColor
                  : AppColors.textSecondary.withValues(alpha: 0.70),
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? accentColor : AppColors.textSecondary,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              Icon(
                enabled
                    ? Icons.check_circle_rounded
                    : Icons.lock_outline_rounded,
                size: 16,
                color: accentColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _BackgroundCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _BackgroundCircle({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.07),
        ),
      ),
    );
  }
}
