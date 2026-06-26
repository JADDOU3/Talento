import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/empathy_mirror/empathy_mirror_models.dart';

/// On-screen emotion choices for Level 2.
/// Tapping a card SELECTS it (toggle); it does NOT submit. The parent shows a
/// Submit button and reads the current selection via [onSelectionChanged].
class CardChoicesWidget extends StatefulWidget {
  final List<ChoiceModel> choices;
  final ValueChanged<String?> onSelectionChanged;

  const CardChoicesWidget({
    super.key,
    required this.choices,
    required this.onSelectionChanged,
  });

  @override
  State<CardChoicesWidget> createState() => _CardChoicesWidgetState();
}

class _CardChoicesWidgetState extends State<CardChoicesWidget> {
  String? _selectedIcon;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 14,
      runSpacing: 14,
      children: widget.choices.map((choice) {
        final isSelected = _selectedIcon == choice.icon;

        return _ChoiceCard(
          icon: choice.icon,
          isSelected: isSelected,
          isDisabled: false,
          onTap: () {
            setState(() {
              // toggle selection
              _selectedIcon = isSelected ? null : choice.icon;
            });
            widget.onSelectionChanged(_selectedIcon);
          },
        );
      }).toList(),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  final String icon;
  final bool isSelected;
  final bool isDisabled;
  final VoidCallback? onTap;

  const _ChoiceCard({
    required this.icon,
    required this.isSelected,
    required this.isDisabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDisabled ? 0.4 : 1.0,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 90,
          height: 100,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.12)
                : AppColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Try asset first, show icon emoji as fallback
              _buildIcon(),
              const SizedBox(height: 8),
              Text(
                _labelFor(icon),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon() {
    // Try loading assets/images/cards/{icon}.png; fallback to emoji.
    return Image.asset(
      'assets/images/cards/$icon.png',
      width: 44,
      height: 44,
      errorBuilder: (_, __, ___) {
        return Text(
          _emojiFor(icon),
          style: const TextStyle(fontSize: 34),
        );
      },
    );
  }

  String _emojiFor(String icon) {
    const map = {
      'sad': '😢',
      'happy': '😊',
      'angry': '😠',
      'scared': '😨',
      'surprised': '😲',
      'disgusted': '🤢',
      'excited': '🤩',
      'bored': '😑',
      'proud': '😊',
      'jealous': '😒',
      'lonely': '🥺',
      'grateful': '🙏',
    };
    return map[icon.toLowerCase()] ?? '🃏';
  }

  String _labelFor(String icon) {
    const map = {
      'sad': 'حزين',
      'happy': 'سعيد',
      'angry': 'غاضب',
      'scared': 'خائف',
      'surprised': 'مندهش',
      'disgusted': 'متقزز',
      'excited': 'متحمس',
      'bored': 'ممل',
      'proud': 'فخور',
      'jealous': 'غيور',
      'lonely': 'وحيد',
      'grateful': 'ممتن',
    };
    return map[icon.toLowerCase()] ?? icon;
  }
}
