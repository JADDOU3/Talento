import 'package:flutter/material.dart';

class ChecklistItemWidget extends StatelessWidget {
  final String text;
  final bool isChecked;
  final VoidCallback onToggle;

  const ChecklistItemWidget({
    super.key,
    required this.text,
    required this.isChecked,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Row(
          children: [
            Checkbox(
              value: isChecked,
              onChanged: (_) => onToggle(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
  text,
  style: const TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
    height: 1.4,
  ),
)
            ),
          ],
        ),
      ),
    );
  }
}