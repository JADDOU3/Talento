import 'package:flutter/material.dart';

import '../../../core/theme/app_text_styles.dart';

class ActivityTemplateButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double height;
  final double borderRadius;
  final double fontSize;
  final TextStyle? textStyle;

  const ActivityTemplateButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.backgroundColor,
    this.textColor = Colors.white,
    this.height = 78,
    this.borderRadius = 28,
    this.fontSize = 34,
    this.textStyle,
  });

  @override
  State<ActivityTemplateButton> createState() => _ActivityTemplateButtonState();
}

class _ActivityTemplateButtonState extends State<ActivityTemplateButton> {
  bool _isPressed = false;

  void _setPressed(bool value) {
    if (!mounted) return;
    setState(() => _isPressed = value);
  }

  Color _lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  Widget build(BuildContext context) {
    final topColor = _lighten(widget.backgroundColor, 0.05);
    final bottomColor = _darken(widget.backgroundColor, 0.06);

    final glowColor = _lighten(widget.backgroundColor, 0.16);
    final shadowColor = _darken(widget.backgroundColor, 0.22);

    final effectiveTextStyle = (widget.textStyle ?? AppTextStyles.button)
        .copyWith(
      color: widget.textColor,
      fontSize: widget.fontSize,
      height: 1.05,
      shadows: [
        Shadow(
          color: Colors.black.withOpacity(0.22),
          offset: const Offset(0, 2),
          blurRadius: 3,
        ),
      ],
    );

    return AnimatedScale(
      scale: _isPressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutBack,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: double.infinity,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: [
            BoxShadow(
              color: glowColor.withOpacity(_isPressed ? 0.28 : 0.48),
              blurRadius: _isPressed ? 12 : 24,
              spreadRadius: _isPressed ? 2 : 4,
              offset: Offset.zero,
            ),

            BoxShadow(
              color: shadowColor.withOpacity(_isPressed ? 0.18 : 0.30),
              blurRadius: _isPressed ? 10 : 18,
              offset: Offset(0, _isPressed ? 5 : 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: InkWell(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            onTap: widget.onPressed,
            onTapDown: (_) => _setPressed(true),
            onTapUp: (_) => _setPressed(false),
            onTapCancel: () => _setPressed(false),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    topColor,
                    widget.backgroundColor,
                    bottomColor,
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.35),
                  width: 1.6,
                ),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    widget.text,
                    textAlign: TextAlign.center,
                    style: effectiveTextStyle,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}