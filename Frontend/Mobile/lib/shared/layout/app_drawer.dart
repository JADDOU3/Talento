import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../cubits/child_mode/child_mode_cubit.dart';
import '../../cubits/child_mode/child_mode_state.dart';
import '../../cubits/coins/coins_cubit.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../services/auth/auth_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  static const String _drawerHeaderAsset =
      'assets/images/drawer_header_talento.png';

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(
          left: Radius.circular(26),
        ),
      ),
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
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  const _DrawerHeroHeader(),

                  Transform.translate(
                    offset: const Offset(0, -75),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Column(
                        children: [
                          _DrawerActionTile(
                            title: 'الملف الشخصي',
                            icon: Icons.person_outline_rounded,
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ProfileScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          _ChildModeTile(
                            isChildMode: isChildMode,
                            hasPin: hasPin,
                            isLoading: isLoading,
                            onTap: isLoading
                                ? null
                                : () => _handleChildMode(
                              context,
                              isChildMode,
                              hasPin,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Spacer(),

                  if (!isChildMode)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                      child: _LogoutTile(
                        onTap: () async {
                          context.read<ChildModeCubit>().reset();
                          context.read<CoinsCubit>().reset();
                          await AuthService().logout();

                          if (context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                                  (route) => false,
                            );
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _handleChildMode(
      BuildContext context,
      bool isChildMode,
      bool hasPin,
      ) {
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
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(26),
        ),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            top: 24,
            left: 24,
            right: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'تعيين رمز PIN',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'أدخل PIN من 6 أرقام',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confirmController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'تأكيد PIN',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    if (pinController.text.length != 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('PIN يجب أن يكون 6 أرقام'),
                        ),
                      );
                      return;
                    }

                    if (pinController.text != confirmController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('PIN غير متطابق'),
                        ),
                      );
                      return;
                    }

                    await cubit.setPin(pinController.text);
                    await cubit.enableChildMode();

                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'حفظ PIN',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
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
        builder: (ctx, setState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            title: const Text(
              'الخروج من وضع الطفل',
              textAlign: TextAlign.right,
            ),
            content: TextField(
              controller: pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'أدخل PIN',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                errorText: errorMsg,
              ),
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                ),
                child: const Text('تأكيد'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerHeroHeader extends StatelessWidget {
  const _DrawerHeroHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FFFE),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Image.asset(
          AppDrawer._drawerHeaderAsset,
          fit: BoxFit.cover,
          alignment: Alignment.topCenter,
          filterQuality: FilterQuality.high,
          errorBuilder: (_, __, ___) => const _DrawerHeaderFallback(),
        ),
      ),
    );
  }
}

class _DrawerHeaderFallback extends StatelessWidget {
  const _DrawerHeaderFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFEFFFFD),
            Color(0xFFFFF6F8),
            Color(0xFFFFFFFF),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
      ),
      child: const Center(
        child: Text(
          'Talento',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 27,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _DrawerActionTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _DrawerActionTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _DrawerTileShell(
      onTap: onTap,
      child: Row(
        children: [
          _DrawerIconBubble(
            icon: icon,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Icon(
            Icons.chevron_left_rounded,
            color: AppColors.primary.withValues(alpha: 0.72),
            size: 24,
          ),
        ],
      ),
    );
  }
}

class _ChildModeTile extends StatelessWidget {
  final bool isChildMode;
  final bool hasPin;
  final bool isLoading;
  final VoidCallback? onTap;

  const _ChildModeTile({
    required this.isChildMode,
    required this.hasPin,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _DrawerTileShell(
      onTap: onTap,
      child: Row(
        children: [
          isLoading
              ? const SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
              : _DrawerIconBubble(
            icon: Icons.child_care_rounded,
            color: isChildMode ? AppColors.primary : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isChildMode ? 'وضع الطفل نشط' : 'وضع الطفل',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color:
                    isChildMode ? AppColors.primary : AppColors.textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (!isChildMode && !hasPin) ...[
                  const SizedBox(height: 3),
                  Text(
                    'لم يتم تعيين PIN',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Transform.scale(
            scale: 0.82,
            child: Switch(
              value: isChildMode,
              onChanged: isLoading ? null : (_) => onTap?.call(),
              activeColor: AppColors.primary,
              inactiveThumbColor: AppColors.white,
              inactiveTrackColor: Colors.grey.withValues(alpha: 0.25),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoutTile extends StatelessWidget {
  final Future<void> Function() onTap;

  const _LogoutTile({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.075),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: AppColors.error.withValues(alpha: 0.16),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.logout_rounded,
                color: AppColors.error,
                size: 21,
              ),
              const SizedBox(width: 10),
              Text(
                'تسجيل الخروج',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 14.2,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerTileShell extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _DrawerTileShell({
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(19),
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 60,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(19),
            border: Border.all(
              color: const Color(0xFFBDEDEA).withValues(alpha: 0.90),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.07),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
              BoxShadow(
                color: AppColors.white.withValues(alpha: 0.90),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _DrawerIconBubble extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _DrawerIconBubble({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 39,
      height: 39,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: 22,
      ),
    );
  }
}