import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../home/new_user.dart';
import '../../journal/journal_screen.dart';
import '../../kit_library/kit_library_screen.dart';
import '../../profile/profile_screen.dart';
import '../community_screen.dart';

class CustomBottomNav extends StatelessWidget {
  final int selectedIndex;

  const CustomBottomNav({
    super.key,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(Icons.home_outlined, 'الرئيسية'),
      _NavItem(Icons.widgets_outlined, 'الحزم'),
      _NavItem(Icons.groups_rounded, 'المجتمع'),
      _NavItem(Icons.auto_stories_outlined, 'اليوميات'),
      _NavItem(Icons.person_outline_rounded, 'حسابي'),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.98),
          border: Border(top: BorderSide(color: AppColors.border.withValues(alpha: 0.75))),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.07),
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
              children: List.generate(items.length, (index) {
                final isSelected = selectedIndex == index;
                final item = items[index];

                return Expanded(
                  child: InkWell(
                    onTap: () => _goToScreen(context, index),
                    borderRadius: BorderRadius.circular(18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          width: index == 2 ? 48 : 32,
                          height: index == 2 ? 48 : 32,
                          margin: EdgeInsets.only(top: index == 2 ? 0 : 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            shape: BoxShape.circle,
                            boxShadow: index == 2
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.30),
                                      blurRadius: 16,
                                      offset: const Offset(0, 7),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Icon(
                            item.icon,
                            size: index == 2 ? 24 : 22,
                            color: isSelected ? AppColors.white : AppColors.hint,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 10,
                            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                            color: isSelected ? AppColors.primary : AppColors.hint,
                          ),
                        ),
                      ],
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

  void _goToScreen(BuildContext context, int index) {
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
  final String label;

  const _NavItem(this.icon, this.label);
}
