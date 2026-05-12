import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import '../../../shared/i18n/app_localizations.dart';
import '../../../util/theme/app_colors.dart';

class OrderSummaryPanel extends StatelessWidget {
  final double subtotal;
  final double tax;
  final double total;
  final VoidCallback onCheckout;

  const OrderSummaryPanel({
    super.key,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final currency = intl.NumberFormat.simpleCurrency(locale: 'en_US');
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final checkoutIcon = isRtl ? Icons.arrow_back : Icons.arrow_forward;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.cartSummaryPink,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.cartSummaryPink.withValues(alpha: 0.45),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.cartSummary,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.cartForestGreen,
            ),
          ),
          const SizedBox(height: 20),
          _SummaryRow(label: l10n.cartSubtotal, value: currency.format(subtotal)),
          const SizedBox(height: 10),
          _SummaryRow(
            label: l10n.cartShipping,
            valueWidget: Text(
              l10n.cartShippingFree,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.cartTeal,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _SummaryRow(label: l10n.cartTax, value: currency.format(tax)),
          const SizedBox(height: 18),
          Divider(color: AppColors.cartForestGreen.withValues(alpha: 0.12), thickness: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.cartTotal,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.cartForestGreen,
                ),
              ),
              Text(
                currency.format(total),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColors.cartTotalRose,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          FilledButton(
            onPressed: onCheckout,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.cartTeal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              shape: const StadiumBorder(),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.proceedToCheckout,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(width: 10),
                Icon(checkoutIcon, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.cartSupportNote.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 0.6,
              height: 1.5,
              color: AppColors.cartMutedGrey.withValues(alpha: 0.95),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.cartDeliveryCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.cartStepperPink.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.local_shipping_outlined, color: AppColors.cartTotalRose, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.cartDeliveryEstimate,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cartForestGreen,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;

  const _SummaryRow({
    required this.label,
    this.value,
    this.valueWidget,
  }) : assert(value != null || valueWidget != null);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.cartMutedGrey,
            fontWeight: FontWeight.w500,
          ),
        ),
        valueWidget ??
            Text(
              value!,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.cartForestGreen,
              ),
            ),
      ],
    );
  }
}
