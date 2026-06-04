import 'package:flutter/material.dart';

class ActivityMascot extends StatefulWidget {
  final String assetPath;
  final double width;
  final BoxFit fit;
  final bool animateFloat;

  const ActivityMascot({
    super.key,
    required this.assetPath,
    required this.width,
    this.fit = BoxFit.contain,
    this.animateFloat = true,
  });

  @override
  State<ActivityMascot> createState() => _ActivityMascotState();
}

class _ActivityMascotState extends State<ActivityMascot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _floatAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _floatAnimation = Tween<double>(
      begin: 0,
      end: -14,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.035,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _rotateAnimation = Tween<double>(
      begin: -0.015,
      end: 0.015,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.animateFloat) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant ActivityMascot oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.animateFloat && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.animateFloat && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mascotImage = Image.asset(
      widget.assetPath,
      width: widget.width,
      fit: widget.fit,
    );

    if (!widget.animateFloat) {
      return mascotImage;
    }

    return AnimatedBuilder(
      animation: _controller,
      child: mascotImage,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: Transform.rotate(
            angle: _rotateAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            ),
          ),
        );
      },
    );
  }
}