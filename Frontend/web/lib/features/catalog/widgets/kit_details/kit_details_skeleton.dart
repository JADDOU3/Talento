import 'package:flutter/material.dart';

/// Full-page shimmer placeholder matching kit details layout.
class KitDetailsSkeleton extends StatelessWidget {
  const KitDetailsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final twoCol = w >= 960;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (twoCol)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _block(height: 320)),
              const SizedBox(width: 40),
              Expanded(child: _detailsSkeleton()),
            ],
          )
        else ...[
          _block(height: 280),
          const SizedBox(height: 24),
          _detailsSkeleton(),
        ],
        const SizedBox(height: 56),
        _block(height: 48),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _block(height: 180)),
            const SizedBox(width: 18),
            Expanded(child: _block(height: 180)),
            const SizedBox(width: 18),
            Expanded(child: _block(height: 180)),
          ],
        ),
        const SizedBox(height: 56),
        _block(height: 320),
        const SizedBox(height: 56),
        _block(height: 220),
      ],
    );
  }

  Widget _detailsSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _block(height: 28, width: 140),
        const SizedBox(height: 16),
        _block(height: 36),
        const SizedBox(height: 12),
        _block(height: 20, width: 180),
        const SizedBox(height: 20),
        _block(height: 200),
      ],
    );
  }

  Widget _block({required double height, double? width}) {
    return _ShimmerBox(
      height: height,
      width: width,
      borderRadius: 16,
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
