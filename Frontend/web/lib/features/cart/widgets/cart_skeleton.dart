import 'package:flutter/material.dart';

/// Skeleton placeholder for cart items list and order summary while loading.
class CartSkeleton extends StatelessWidget {
  const CartSkeleton({super.key, required this.twoColumn});

  final bool twoColumn;

  @override
  Widget build(BuildContext context) {
    final itemsColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _block(height: 36, width: 220),
        const SizedBox(height: 28),
        _block(height: 132),
        const SizedBox(height: 16),
        _block(height: 132),
        const SizedBox(height: 16),
        _block(height: 132),
      ],
    );

    final summaryColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _block(height: 320),
        const SizedBox(height: 22),
        _block(height: 52),
      ],
    );

    if (twoColumn) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 62, child: itemsColumn),
          const SizedBox(width: 32),
          Expanded(flex: 38, child: summaryColumn),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        itemsColumn,
        const SizedBox(height: 28),
        summaryColumn,
      ],
    );
  }

  Widget _block({required double height, double? width}) {
    return _ShimmerBox(
      height: height,
      width: width,
      borderRadius: 20,
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  const _ShimmerBox({
    required this.height,
    this.width,
    this.borderRadius = 12,
  });

  final double height;
  final double? width;
  final double borderRadius;

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            color: Color.lerp(
              const Color(0xFFE8E4DF),
              const Color(0xFFF5F2EE),
              _controller.value,
            ),
          ),
        );
      },
    );
  }
}
