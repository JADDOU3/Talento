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
      _NavItem(Icons.home_outlined, Icons.home_rounded, 'الرئيسية'),
      _NavItem(Icons.widgets_outlined, Icons.widgets_rounded, 'الصناديق'),
      _NavItem(Icons.groups_outlined, Icons.groups_rounded, 'المجتمع'),
      _NavItem(Icons.school_outlined, Icons.school_rounded, 'دروس'),
      _NavItem(
        Icons.auto_stories_outlined,
        Icons.auto_stories_rounded,
        'اليوميات',
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.98),
          border: Border(
            top: BorderSide(
              color: AppColors.border.withValues(alpha: 0.75),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.06),
              blurRadius: 18,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 7, 8, 7),
            child: Row(
              children: List.generate(tabs.length, (index) {
                final item = tabs[index];
                final isSelected = index == selectedIndex;

                return Expanded(
                  child: InkWell(
                    onTap: () => _handleNavigation(context, index),
                    borderRadius: BorderRadius.circular(14),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.yellow.withValues(alpha: 0.16)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.yellow.withValues(alpha: 0.22)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isSelected ? item.activeIcon : item.icon,
                              size: 21,
                              color: isSelected
                                  ? const Color(0xFFE0A300)
                                  : AppColors.hint,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 9.7,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFFE0A300)
                                  : AppColors.hint,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
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
        transitionDuration: const Duration(milliseconds: 160),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem(this.icon, this.activeIcon, this.label);
}