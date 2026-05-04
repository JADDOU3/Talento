// lib/shared/components/cards/kit_card.dart

import 'package:flutter/material.dart';
import '../../../util/theme/app_colors.dart';
import '../../i18n/catalog_translations.dart';

class KitCard extends StatefulWidget {
  final String id; // Unique identifier
  final String imagePath;
  final String titleKey;
  final String descKey;
  final String ageKey;
  final double price;
  final bool isNew;
  final String lang;
  final bool isFav;
  final VoidCallback onFavToggle;

  const KitCard({
    super.key,
    required this.id,
    required this.imagePath,
    required this.titleKey,
    required this.descKey,
    required this.ageKey,
    required this.price,
    required this.lang,
    required this.isFav,
    required this.onFavToggle,
    this.isNew = false,
  });

  @override
  State<KitCard> createState() => _KitCardState();
}

class _KitCardState extends State<KitCard> {
  bool _hovering = false;

  bool get isAr => widget.lang == 'ar';

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: _hovering ? (Matrix4.identity()..translate(0, -6)) : Matrix4.identity(),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_hovering ? 0.10 : 0.05),
              blurRadius: _hovering ? 20 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    child: Image.asset(
                      widget.imagePath,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (widget.isNew)
                    Positioned(
                      top: 12,
                      right: isAr ? null : 12,
                      left: isAr ? 12 : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF4D6D),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          t('new_arrival', widget.lang),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Text(
                      t(widget.titleKey, widget.lang),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: isAr ? TextAlign.right : TextAlign.left,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      t(widget.descKey, widget.lang),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: isAr ? TextAlign.right : TextAlign.left,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            t(widget.ageKey, widget.lang),
                            style: const TextStyle(
                              color: AppColors.teal,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '\$${widget.price.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.teal,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('${t('add_to_cart', widget.lang)}: ${t(widget.titleKey, widget.lang)}'),
                                  duration: const Duration(seconds: 1),
                                ),
                              );
                            },
                            icon: const Icon(Icons.shopping_cart_outlined, size: 16),
                            label: Text(
                              t('add_to_cart', widget.lang),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: widget.onFavToggle,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: widget.isFav
                                  ? const Color(0xFFFFE4E8)
                                  : Colors.grey.withOpacity(0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              widget.isFav ? Icons.favorite : Icons.favorite_border,
                              size: 18,
                              color: widget.isFav ? const Color(0xFFFF4D6D) : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}