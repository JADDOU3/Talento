import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../cubits/child_mode/child_mode_cubit.dart';
import '../../cubits/child_mode/child_mode_state.dart';
import '../../screens/community/community_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/home/new_user.dart';
import '../../screens/journal/journal_screen.dart';
import '../../screens/kit_library/kit_library_screen.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _NavItem(
        Icons.home_outlined,
        Icons.home_rounded,
        'الرئيسية',
        AppColors.yellow,
        const Color(0xFFE0A300),
      ),
      _NavItem(
        Icons.widgets_outlined,
        Icons.widgets_rounded,
        'الصناديق',
        AppColors.primary,
        AppColors.primary,
      ),
      _NavItem(
        Icons.groups_outlined,
        Icons.groups_rounded,
        'المجتمع',
        AppColors.pink,
        AppColors.pink,
      ),
      _NavItem(
        Icons.school_outlined,
        Icons.school_rounded,
        'دروس',
        AppColors.secondary,
        AppColors.secondary,
      ),
      _NavItem(
        Icons.auto_stories_outlined,
        Icons.auto_stories_rounded,
        'متابعة التقدّم',
        AppColors.success,
        AppColors.success,
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.93),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.white.withValues(alpha: 0.92),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.08),
                blurRadius: 22,
                offset: const Offset(0, 9),
              ),
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.055),
                blurRadius: 24,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 7),
              child: Row(
                children: List.generate(tabs.length, (index) {
                  final item = tabs[index];
                  final isSelected = index == selectedIndex;

                  return Expanded(
                    child: _BottomNavItemWidget(
                      item: item,
                      isSelected: isSelected,
                      onTap: () => _handleNavigation(context, index),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    if (index == selectedIndex) return;

    final childModeState = context.read<ChildModeCubit>().state;
    final isChildMode =
        childModeState is ChildModeStatus && childModeState.isChildMode;

    // دروس - حاليًا بدون شاشة جاهزة
    if (index == 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('قسم الدروس قريبًا'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // اليوميات في وضع الطفل
    if (isChildMode && index == 4) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const NewUser()),
      );
      return;
    }

    Widget screen;

    switch (index) {
      case 0:
        screen = const HomeScreen();
        break;
      case 1:
        screen = const KitLibraryScreen();
        break;
      case 2:
        screen = const CommunityScreen();
        break;
      case 4:
        screen = const JournalScreen();
        break;
      default:
        return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionDuration: const Duration(milliseconds: 180),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }
}

class _BottomNavItemWidget extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _BottomNavItemWidget({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        splashColor: item.color.withValues(alpha: 0.08),
        highlightColor: item.color.withValues(alpha: 0.04),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 230),
          curve: Curves.easeOutCubic,
          height: 58,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: isSelected
                ? LinearGradient(
              colors: [
                item.color.withValues(alpha: 0.22),
                item.color.withValues(alpha: 0.09),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )
                : null,
            border: isSelected
                ? Border.all(
              color: item.color.withValues(alpha: 0.25),
              width: 1,
            )
                : null,
            boxShadow: isSelected
                ? [
              BoxShadow(
                color: item.color.withValues(alpha: 0.20),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 230),
                curve: Curves.easeOutCubic,
                width: isSelected ? 31 : 28,
                height: isSelected ? 31 : 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected
                      ? AppColors.white.withValues(alpha: 0.95)
                      : Colors.transparent,
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: item.color.withValues(alpha: 0.18),
                      blurRadius: 9,
                      offset: const Offset(0, 3),
                    ),
                  ]
                      : [],
                ),
                child: Icon(
                  isSelected ? item.activeIcon : item.icon,
                  size: isSelected ? 20.5 : 20,
                  color: isSelected
                      ? item.activeColor
                      : AppColors.hint.withValues(alpha: 0.82),
                ),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 230),
                curve: Curves.easeOutCubic,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: isSelected ? 10.2 : 9.4,
                  height: 1,
                  fontWeight:
                  isSelected ? FontWeight.w900 : FontWeight.w600,
                  color: isSelected
                      ? item.activeColor
                      : AppColors.hint.withValues(alpha: 0.80),
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Color color;
  final Color activeColor;

  const _NavItem(
      this.icon,
      this.activeIcon,
      this.label,
      this.color,
      this.activeColor,
      );
}