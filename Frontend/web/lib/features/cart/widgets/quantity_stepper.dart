import 'package:flutter/material.dart';
import '../../../util/theme/app_colors.dart';

/// Quantity controls. In RTL the visual order becomes +, count, − (Row mirrors).
class QuantityStepper extends StatelessWidget {
  final int count;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;

  const QuantityStepper({
    super.key,
    required this.count,
    required this.onChanged,
    this.min = 1,
    this.max = 99,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperChip(
            label: '−',
            onTap: count > min ? () => onChanged(count - 1) : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              '$count',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.cartForestGreen,
              ),
            ),
          ),
          _StepperChip(
            label: '+',
            onTap: count < max ? () => onChanged(count + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _StepperChip extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;

  const _StepperChip({required this.label, this.onTap});

  @override
  State<_StepperChip> createState() => _StepperChipState();
}

class _StepperChipState extends State<_StepperChip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _hover && enabled
                ? AppColors.cartStepperPink.withValues(alpha: 0.35)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: enabled
                  ? AppColors.cartStepperPink
                  : AppColors.cartStepperPink.withValues(alpha: 0.35),
            ),
          ),
        ),
      ),
    );
  }
}
