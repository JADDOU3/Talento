import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../util/theme/app_colors.dart';
import 'quantity_stepper.dart';

class CartItemCard extends StatelessWidget {
  final String imageAsset;
  final String name;
  final String description;
  final int quantity;
  final double unitPrice;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;
  final String removeTooltip;

  const CartItemCard({
    super.key,
    required this.imageAsset,
    required this.name,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.onQuantityChanged,
    required this.onRemove,
    required this.removeTooltip,
  });

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.simpleCurrency(locale: 'en_US');
    final lineTotal = unitPrice * quantity;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(top: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset(
                    imageAsset,
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.cartForestGreen,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: AppColors.cartMutedGrey,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          QuantityStepper(
                            count: quantity,
                            onChanged: onQuantityChanged,
                          ),
                          const Spacer(),
                          Text(
                            currency.format(lineTotal),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.cartTeal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          PositionedDirectional(
            top: 0,
            end: 0,
            child: IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: removeTooltip,
              onPressed: onRemove,
              icon: Icon(
                Icons.close,
                size: 20,
                color: AppColors.cartMutedGrey.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
