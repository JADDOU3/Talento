import 'package:flutter/material.dart';
import '../../../shared/i18n/app_localizations.dart';
import '../../../util/theme/app_colors.dart';
import 'order_row.dart';

class OrderHistoryCard extends StatelessWidget {
  const OrderHistoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.all(28),
      decoration: BoxDecoration(
        color: AppColors.cartTeal,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.profileOrderHistory,
            textAlign: TextAlign.start,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 22),
          OrderRow(
            imageAsset: 'assets/images/img1.jpg',
            orderNumber: l10n.profileOrder1Number,
            subtitle: l10n.profileOrder1Subtitle,
            statusLabel: l10n.profileDelivered,
          ),
          OrderRow(
            imageAsset: 'assets/images/img2.jpg',
            orderNumber: l10n.profileOrder2Number,
            subtitle: l10n.profileOrder2Subtitle,
            statusLabel: l10n.profileDelivered,
          ),
          OrderRow(
            imageAsset: 'assets/images/img3.jpg',
            orderNumber: l10n.profileOrder3Number,
            subtitle: l10n.profileOrder3Subtitle,
            statusLabel: l10n.profileDelivered,
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              l10n.profileViewAllOrders,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
