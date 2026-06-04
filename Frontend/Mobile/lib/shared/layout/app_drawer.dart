import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../cubits/child_mode/child_mode_cubit.dart';
import '../../cubits/child_mode/child_mode_state.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../services/auth/auth_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: BlocConsumer<ChildModeCubit, ChildModeState>(
        listener: (context, state) {
          if (state is ChildModeStatus && state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final childState = state is ChildModeStatus
              ? state
              : ChildModeStatus(isChildMode: false, hasPin: false);

          final isChildMode = childState.isChildMode;
          final hasPin = childState.hasPin;
          final isLoading = childState.isLoading;

          return SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  color: AppColors.primary,
                  child: const Text(
                    'Talento',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Profile — always goes to ProfileScreen
                // ProfileScreen handles child mode internally
                ListTile(
                  leading: const Icon(Icons.person_outline_rounded),
                  title: const Text('الملف الشخصي'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ProfileScreen()),
                    );
                  },
                ),

                // Child Mode Toggle
                ListTile(
                  leading: isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : Icon(
                    Icons.child_care_rounded,
                    color: isChildMode ? AppColors.primary : Colors.grey,
                  ),
                  title: Text(
                    isChildMode ? 'وضع الطفل نشط' : 'وضع الطفل',
                    style: TextStyle(
                      color: isChildMode ? AppColors.primary : null,
                      fontWeight:
                      isChildMode ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                  subtitle: !isChildMode && !hasPin
                      ? const Text('لم يتم تعيين PIN',
                      style: TextStyle(fontSize: 12))
                      : null,
                  trailing: Switch(
                    value: isChildMode,
                    onChanged: isLoading
                        ? null
                        : (_) =>
                        _handleChildMode(context, isChildMode, hasPin),
                    activeColor: AppColors.primary,
                  ),
                  onTap: isLoading
                      ? null
                      : () => _handleChildMode(context, isChildMode, hasPin),
                ),

                // Settings
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('الإعدادات'),
                  onTap: () => Navigator.pop(context),
                ),

                const Spacer(),

                // Logout — hidden in child mode
                if (!isChildMode)
                  ListTile(
                    leading: const Icon(Icons.logout_rounded,
                        color: Colors.red),
                    title: const Text(
                      'تسجيل الخروج',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () async {
                      context.read<ChildModeCubit>().reset();
                      await AuthService().logout();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                              (route) => false,
                        );
                      }
                    },
                  ),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  void _handleChildMode(
      BuildContext context, bool isChildMode, bool hasPin) {
    final cubit = context.read<ChildModeCubit>();
    Navigator.pop(context);

    if (isChildMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showDisableDialog(context, cubit);
      });
      return;
    }

    if (!hasPin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSetPinSheet(context, cubit);
      });
      return;
    }

    cubit.enableChildMode();
  }

  void _showSetPinSheet(BuildContext context, ChildModeCubit cubit) {
    final pinController = TextEditingController();
    final confirmController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          top: 24,
          left: 24,
          right: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('تعيين رمز PIN',
                style:
                TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            TextField(
              controller: pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: 'أدخل PIN من 6 أرقام',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                hintText: 'تأكيد PIN',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (pinController.text.length != 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('PIN يجب أن يكون 6 أرقام')),
                    );
                    return;
                  }
                  if (pinController.text != confirmController.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PIN غير متطابق')),
                    );
                    return;
                  }
                  await cubit.setPin(pinController.text);
                  await cubit.enableChildMode();
                  if (ctx.mounted) Navigator.pop(ctx);
                },
                child: const Text('حفظ PIN'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDisableDialog(BuildContext context, ChildModeCubit cubit) {
    final pinController = TextEditingController();
    String? errorMsg;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('الخروج من وضع الطفل',
              textAlign: TextAlign.right),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'أدخل PIN',
                  border: const OutlineInputBorder(),
                  errorText: errorMsg,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                await cubit.disableChildMode(pinController.text);
                final state = cubit.state;
                if (state is ChildModeStatus && state.error != null) {
                  setState(() => errorMsg = 'PIN غير صحيح');
                  return;
                }
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('تأكيد'),
            ),
          ],
        ),
      ),
    );
  }
}
