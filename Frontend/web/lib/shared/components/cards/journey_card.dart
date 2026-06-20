import 'package:flutter/material.dart';

class JourneyCard extends StatefulWidget {
  final Widget iconWidget; // Changed from IconData to Widget for more flexibility
  final String title;
  final String description;
  final Color themeColor;

  const JourneyCard({
    super.key,
    required this.iconWidget,
    required this.title,
    required this.description,
    required this.themeColor,
  });

  @override
  State<JourneyCard> createState() => _JourneyCardState();
}

class _JourneyCardState extends State<JourneyCard> with SingleTickerProviderStateMixin {
  bool isHovered = false;
  late AnimationController _wiggleController;

  @override
  void initState() {
    super.initState();
    _wiggleController = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _wiggleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedScale(
        scale: isHovered ? 1.05 : 1.0,
        curve: Curves.easeOutBack,
        duration: const Duration(milliseconds: 400),
        child: Column(
          children: [
            // Floating/Wiggle Icon Area
            AnimatedBuilder(
              animation: _wiggleController,
              builder: (context, child) => Transform.rotate(
                angle: (_wiggleController.value - 0.5) * 0.05,
                child: child,
              ),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.themeColor.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Center(child: widget.iconWidget),
              ),
            ),
            const SizedBox(height: 24),
            // Title and Description
            Text(widget.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(widget.description, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, color: Colors.black54, height: 1.5)),
            ),
          ],
        ),
      ),
    );
  }
}