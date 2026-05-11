import 'package:flutter/material.dart';
import '../../../util/theme/app_colors.dart';

class RecommendedCard extends StatefulWidget {
  final String badgeLabel;
  final String title;
  final String description;
  final String addButtonLabel;
  final List<Color> gradientColors;
  final IconData decorationIcon;
  final Color addButtonColor;
  final VoidCallback onAdd;

  const RecommendedCard({
    super.key,
    required this.badgeLabel,
    required this.title,
    required this.description,
    required this.addButtonLabel,
    required this.gradientColors,
    required this.decorationIcon,
    required this.addButtonColor,
    required this.onAdd,
  });

  @override
  State<RecommendedCard> createState() => _RecommendedCardState();
}

class _RecommendedCardState extends State<RecommendedCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onAdd,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 200),
          offset: Offset(0, _hover ? -0.02 : 0),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: widget.gradientColors,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _hover ? 0.1 : 0.05),
                blurRadius: _hover ? 20 : 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              PositionedDirectional(
                bottom: -8,
                end: -8,
                child: Icon(
                  widget.decorationIcon,
                  size: 100,
                  color: Colors.white.withValues(alpha: 0.22),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.badgeLabel,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.9,
                          color: AppColors.cartForestGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.cartForestGreen,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Text(
                        widget.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.4,
                          color: AppColors.cartForestGreen.withValues(alpha: 0.75),
                        ),
                      ),
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: FilledButton(
                        onPressed: widget.onAdd,
                        style: FilledButton.styleFrom(
                          backgroundColor: widget.addButtonColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          shape: const StadiumBorder(),
                          elevation: 0,
                        ),
                        child: Text(
                          widget.addButtonLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ],
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
