import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../screens/home/new_user.dart';
import '../../screens/kit_library/kit_library_screen.dart';
import '../../screens/journal/journal_screen.dart';
class BottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const BottomNavBar({
    super.key,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.grid_view_rounded, 'label': 'Kit'},
      {'icon': Icons.groups_rounded, 'label': 'Community'},
      {'icon': Icons.menu_book_rounded, 'label': 'Journal'},
      {'icon': Icons.person_rounded, 'label': 'Profile'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        border: const Border(
          top: BorderSide(color: AppColors.border),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(tabs.length, (i) {
              final isSelected = i == selectedIndex;

              return GestureDetector(
                onTap: () => _handleNavigation(context, i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        tabs[i]['icon'] as IconData,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.hint,
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tabs[i]['label'] as String,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 11,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.hint,
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
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    if (index == selectedIndex) return;

    switch (index) {
      case 0: // Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const NewUser()),
        );
        break;

      case 1: // Kit
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const KitLibraryScreen()),
        );
        break;

      case 2: // Community
      // TODO later
        break;

      case 3: // Journal
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const JournalScreen()),
        );
        break;

      case 4: // Profile
      // TODO later
        break;
    }
  }
}