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
    if (choices.isEmpty) {
      return const SizedBox.shrink();
    }

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
    final visualPartsCount = _visualPartsCount(icons);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: _cardWidth(visualPartsCount),
          height: 92,
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
            iconSize: _iconSize(visualPartsCount),
            spacing: 6,
          ),
        ),
      ),
    );
  }

  static int _visualPartsCount(List<String> icons) {
    if (icons.isEmpty) return 1;

    var count = 0;

    for (final icon in icons) {
      count += _countPartsForIconName(icon);
    }

    return count;
  }

  static int _countPartsForIconName(String iconName) {
    final safeSingleNames = {
      'cat_face',
      'left_arrow',
      'right_arrow',
      'up_arrow',
      'down_arrow',
      'arrow_left',
      'arrow_right',
      'arrow_up',
      'arrow_down',
      'arrow_up_left',
      'arrow_up_right',
      'arrow_down_left',
      'arrow_down_right',
    };

    if (!iconName.contains('_')) return 1;
    if (safeSingleNames.contains(iconName)) return 1;

    return iconName
        .split('_')
        .where((part) => part.trim().isNotEmpty)
        .length;
  }

  static double _cardWidth(int visualPartsCount) {
    if (visualPartsCount >= 4) return 172;
    if (visualPartsCount == 3) return 150;
    if (visualPartsCount == 2) return 126;
    return 116;
  }

  static double _iconSize(int visualPartsCount) {
    if (visualPartsCount >= 4) return 24;
    if (visualPartsCount == 3) return 28;
    if (visualPartsCount == 2) return 32;
    return 38;
  }
}