import 'package:flutter/material.dart';
import '../../../util/theme/app_colors.dart';

class CustomButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final String? emoji;

  const CustomButton({super.key, required this.text, required this.onPressed, this.emoji});

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: Tween(begin: 1.0, end: 0.88)
          .chain(CurveTween(curve: Curves.elasticOut))
          .animate(_controller),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            _controller.forward().then((_) => _controller.reverse());
            widget.onPressed();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.cartTeal,
            padding: const EdgeInsets.symmetric(vertical: 18),
            elevation: 6,
            shadowColor: AppColors.cartTeal.withOpacity(0.6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)), // chunkier
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.emoji != null) Text(widget.emoji!, style: const TextStyle(fontSize: 20)),
              if (widget.emoji != null) const SizedBox(width: 8),
              Text(widget.text, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ),
    );
  }
}