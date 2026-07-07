import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  void _openDrawer(BuildContext context) {
    final scaffold = Scaffold.maybeOf(context);

    if (scaffold != null && scaffold.hasDrawer) {
      scaffold.openDrawer();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.92),
                width: 1.1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.05),
                  blurRadius: 13,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                _TopCircleButton(
                  onPressed: () => _openDrawer(context),
                  icon: Icons.menu_rounded,
                ),
                const Spacer(),
                Image.asset(
                  'assets/icons/logo1.png',
                  height: 42,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) {
                    return const Text(
                      'Talento',
                      style: TextStyle(
                        fontFamily: 'BerlinSans',
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopCircleButton extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;

  const _TopCircleButton({
    required this.onPressed,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white.withValues(alpha: 0.95),
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: AppColors.black.withValues(alpha: 0.08),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 22,
          ),
        ),
      ),
    );
  }
}