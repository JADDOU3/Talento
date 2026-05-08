import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../screens/home/new_user.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/kit_library/kit_library_screen.dart';
import '../../screens/journal/journal_screen.dart';
import '../../screens/community/community_screen.dart';

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
      _NavItem(Icons.widgets_outlined, Icons.widgets_rounded, 'الحزم'),
      _NavItem(Icons.groups_outlined, Icons.groups_rounded, 'المجتمع'),
      _NavItem(Icons.auto_stories_outlined, Icons.auto_stories_rounded, 'اليوميات'),
      _NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'حسابي'),
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
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Row(
              children: List.generate(tabs.length, (index) {
                final item = tabs[index];
                final isSelected = index == selectedIndex;

                return Expanded(
                  child: InkWell(
                    onTap: () => _handleNavigation(context, index),
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.yellow.withValues(alpha: 0.16)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.yellow.withValues(alpha: 0.22)
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isSelected ? item.activeIcon : item.icon,
                              size: 22,
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
                              fontSize: 10.5,
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

    final screens = [
      const NewUser(),
      const KitLibraryScreen(),
      const CommunityScreen(),
      const JournalScreen(),
      const ProfileScreen(),
    ];

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screens[index],
        transitionDuration: const Duration(milliseconds: 160),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
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