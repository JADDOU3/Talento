import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/activities/pattern_hacker/pattern_hacker_choice_model.dart';
import 'pattern_icon_widget.dart';

/// Row of tappable choice cards. The number of choices is read from the data,
/// never hardcoded. The selected card is highlighted; tapping it again clears
/// the selection (handled by the cubit).
class PatternChoicesWidget extends StatelessWidget {
  final List<PatternHackerChoiceModel> choices;
  final String? selectedIcon;
  final ValueChanged<String> onChoiceSelected;

  const PatternChoicesWidget({
    super.key,
    required this.choices,
    required this.selectedIcon,
    required this.onChoiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 14,
      runSpacing: 14,
      children: List.generate(
        choices.length,
        (index) {
          final choice = choices[index];
          final isSelected = selectedIcon == choice.icon;

          return _ChoiceCard(
            iconName: choice.icon,
            isSelected: isSelected,
            onTap: () => onChoiceSelected(choice.icon),
          );
        },
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final String iconName;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.iconName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 96,
          height: 96,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.secondary.withOpacity(0.25)
                : AppColors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.border.withOpacity(0.9),
              width: isSelected ? 3 : 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.18)
                    : AppColors.black.withOpacity(0.06),
                blurRadius: isSelected ? 16 : 10,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: buildPatternIcon(iconName, size: 50),
        ),
      ),
    );
  }
}
