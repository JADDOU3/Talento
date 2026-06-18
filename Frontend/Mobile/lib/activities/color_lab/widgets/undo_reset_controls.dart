import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Undo + Reset buttons row. No API calls — purely local actions.
class UndoResetControls extends StatelessWidget {
  final VoidCallback onUndo;
  final VoidCallback onReset;
  final bool canUndo;
  final bool canReset;
  final int undosLeft;

  const UndoResetControls({
    super.key,
    required this.onUndo,
    required this.onReset,
    required this.canUndo,
    required this.canReset,
    required this.undosLeft,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ControlButton(
            icon: Icons.undo_rounded,
            label: 'تراجع',
            color: AppColors.secondary,
            enabled: canUndo,
            onTap: onUndo,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ControlButton(
            icon: Icons.refresh_rounded,
            label: 'مسح الكل',
            color: AppColors.pink,
            enabled: canReset,
            onTap: onReset,
          ),
        ),
      ],
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool enabled;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.45,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w900,
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
