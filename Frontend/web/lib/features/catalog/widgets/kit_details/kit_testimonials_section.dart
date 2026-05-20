import 'package:flutter/material.dart';
import '../../../../shared/i18n/app_localizations.dart';
import '../../../../util/theme/app_colors.dart';
import 'kit_details_constants.dart';
import 'testimonial_card.dart';

class KitTestimonialsSection extends StatelessWidget {
  const KitTestimonialsSection({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final sideBySide = w >= 900;

    final header = LayoutBuilder(
      builder: (context, c) {
        final narrow = c.maxWidth < 520;
        if (narrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.explorerTestimonials,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.cartTeal,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.testimonialsSubtitle,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: AppColors.cartMutedGrey,
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: _WriteReviewButton(l10n: l10n),
              ),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.explorerTestimonials,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.cartTeal,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    l10n.testimonialsSubtitle,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.5,
                      color: AppColors.cartMutedGrey,
                    ),
                  ),
                ],
              ),
            ),
            _WriteReviewButton(l10n: l10n),
          ],
        );
      },
    );

    final cards = [
      TestimonialCard(
        rating: 5,
        reviewText: l10n.testimonial1Body,
        avatarAsset: KitDetailsConstants.testimonialAvatar1,
        name: l10n.testimonial1Name,
        role: l10n.testimonial1Role,
      ),
      TestimonialCard(
        rating: 4,
        reviewText: l10n.testimonial2Body,
        avatarAsset: KitDetailsConstants.testimonialAvatar2,
        name: l10n.testimonial2Name,
        role: l10n.testimonial2Role,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        const SizedBox(height: 28),
        if (sideBySide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 20),
              Expanded(child: cards[1]),
            ],
          )
        else ...[
          cards[0],
          const SizedBox(height: 16),
          cards[1],
        ],
      ],
    );
  }
}

class _WriteReviewButton extends StatelessWidget {
  const _WriteReviewButton({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.cartTotalRose,
        side: const BorderSide(color: AppColors.cartTotalRose, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      child: Text(
        l10n.writeReview,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    );
  }
}
