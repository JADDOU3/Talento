import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/activities/mirror_mind/mirror_mind_choice_model.dart';
import 'mirror_icon_widget.dart';

class MirrorChoicesWidget extends StatelessWidget {
  final List<MirrorMindChoiceModel> choices;
  final int? selectedChoiceIndex;
  final ValueChanged<int> onChoiceSelected;

  const MirrorChoicesWidget({
    super.key,
    required this.choices,
    required this.selectedChoiceIndex,
    required this.onChoiceSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: List.generate(
        choices.length,
            (index) {
          final choice = choices[index];
          final isSelected = selectedChoiceIndex == index;

          return _ChoiceCard(
            choice: choice,
            isSelected: isSelected,
            onTap: () => onChoiceSelected(index),
          );
        },
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final MirrorMindChoiceModel choice;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChoiceCard({
    required this.choice,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final icons = choice.displayIcons;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: icons.length >= 3 ? 142 : 116,
          height: 90,
          padding: const EdgeInsets.all(10),
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
          child: MirrorIconSequence(
            icons: icons,
            iconSize: icons.length >= 3 ? 28 : 34,
            spacing: 6,
          ),
        ),
      ),
    );
  }
}