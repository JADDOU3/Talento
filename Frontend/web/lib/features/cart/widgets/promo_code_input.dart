import 'package:flutter/material.dart';
import '../../../shared/i18n/app_localizations.dart';
import '../../../util/theme/app_colors.dart';

class PromoCodeInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onApply;

  const PromoCodeInput({
    super.key,
    required this.controller,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.promoCode.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
            color: AppColors.cartMutedGrey,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: l10n.enterPromoCode,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AppColors.cartTeal, width: 1.4),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: onApply,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.cartApplyPink,
                foregroundColor: AppColors.cartTotalRose,
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: Text(
                l10n.apply,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
