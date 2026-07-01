// lib/activities/create_creature/widgets/option_picker_widget.dart

import 'package:flutter/material.dart';
//import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OptionPickerWidget extends StatelessWidget {
  final String label;
  final List<String> icons;
  final String? selectedIcon;
  final void Function(String icon) onSelected;
  final int? maxOptions;
  final String? assetFolder;

  const OptionPickerWidget({
    super.key,
    required this.label,
    required this.icons,
    required this.selectedIcon,
    required this.onSelected,
    this.maxOptions,
    this.assetFolder,
  });

  @override
  Widget build(BuildContext context) {
    final displayedIcons = maxOptions != null ? icons.take(maxOptions!).toList() : icons;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: displayedIcons.map((icon) => _OptionCard(
            icon: icon,
            isSelected: icon == selectedIcon,
            onTap: () => onSelected(icon),
            assetFolder: assetFolder,
          )).toList(),
        ),
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String icon;
  final bool isSelected;
  final VoidCallback onTap;
  final String? assetFolder;

  const _OptionCard({
    required this.icon,
    required this.isSelected,
    required this.onTap,
    this.assetFolder,
  });



  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 110,
        height: 80,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE0E0E0) : Colors.white,
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Image.asset(
            assetFolder != null ? '$assetFolder/$icon.png' : 'assets/images/cards/$icon.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.broken_image_outlined,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}