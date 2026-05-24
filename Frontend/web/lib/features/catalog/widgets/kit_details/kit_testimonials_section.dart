import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../cubits/reviews/kit_reviews_cubit.dart';
import '../../../../cubits/reviews/kit_reviews_state.dart';
import '../../../../shared/i18n/app_localizations.dart';
import '../../../../shared/models/review_model.dart';
import '../../../../util/theme/app_colors.dart';
import 'testimonial_card.dart';

class KitTestimonialsSection extends StatelessWidget {
  const KitTestimonialsSection({super.key, required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<KitReviewsCubit, KitReviewsState>(
      builder: (context, state) {
        if (state is KitReviewsHidden) {
          return const SizedBox.shrink();
        }
        if (state is KitReviewsLoading || state is KitReviewsInitial) {
          return _TestimonialsShimmer(l10n: l10n);
        }
        if (state is KitReviewsEmpty) {
          return _TestimonialsEmpty(l10n: l10n);
        }
        if (state is KitReviewsLoaded) {
          return _TestimonialsContent(
            l10n: l10n,
            reviews: state.reviews,
            averageRating: state.averageRating,
            totalReviews: state.totalReviews,
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _TestimonialsContent extends StatelessWidget {
  const _TestimonialsContent({
    required this.l10n,
    required this.reviews,
    required this.averageRating,
    required this.totalReviews,
  });

  final AppLocalizations l10n;
  final List<ReviewModel> reviews;
  final double averageRating;
  final int totalReviews;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final sideBySide = w >= 900;
    final display = reviews.take(2).toList();

    final header = LayoutBuilder(
      builder: (context, c) {
        final narrow = c.maxWidth < 520;
        final ratingLine = l10n.kitRatingSummary(
          averageRating.toStringAsFixed(1),
          totalReviews,
        );
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
              const SizedBox(height: 8),
              Text(
                ratingLine,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cartMutedGrey,
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
                  const SizedBox(height: 8),
                  Text(
                    ratingLine,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.cartMutedGrey,
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

    final cards = display
        .map(
          (r) => TestimonialCard(
            rating: r.rating,
            reviewText: r.comment,
            name: r.parentName,
            role: l10n.verifiedExplorer,
            createdAt: r.createdAt,
          ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        const SizedBox(height: 28),
        if (sideBySide && cards.length >= 2)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 20),
              Expanded(child: cards[1]),
            ],
          )
        else ...[
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            cards[i],
          ],
        ],
      ],
    );
  }
}

class _TestimonialsEmpty extends StatelessWidget {
  const _TestimonialsEmpty({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.explorerTestimonials,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.cartTeal,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.noReviewsYet,
          style: TextStyle(fontSize: 15, color: AppColors.cartMutedGrey),
        ),
      ],
    );
  }
}

class _TestimonialsShimmer extends StatelessWidget {
  const _TestimonialsShimmer({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.explorerTestimonials,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: AppColors.cartTeal,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
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
