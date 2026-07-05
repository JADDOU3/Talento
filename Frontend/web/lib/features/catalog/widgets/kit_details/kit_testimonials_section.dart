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

class _TestimonialsContent extends StatefulWidget {
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
  State<_TestimonialsContent> createState() => _TestimonialsContentState();
}

class _TestimonialsContentState extends State<_TestimonialsContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final sideBySide = w >= 900;
    final display = widget.reviews.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FunHeader(
          l10n: widget.l10n,
          averageRating: widget.averageRating,
          totalReviews: widget.totalReviews,
          floatAnimation: _floatAnimation,
        ),
        const SizedBox(height: 28),
        if (sideBySide && display.length >= 2)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(20 * (1 - value), 0),
                        child: child,
                      ),
                    );
                  },
                  child: _buildTestimonialCard(display[0], 0),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  builder: (context, value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.translate(
                        offset: Offset(20 * (1 - value), 0),
                        child: child,
                      ),
                    );
                  },
                  child: _buildTestimonialCard(display[1], 1),
                ),
              ),
            ],
          )
        else ...[
          for (var i = 0; i < display.length; i++) ...[
            if (i > 0) const SizedBox(height: 16),
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: Duration(milliseconds: 400 + (i * 100)),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(20 * (1 - value), 0),
                    child: child,
                  ),
                );
              },
              child: _buildTestimonialCard(display[i], i),
            ),
          ],
        ],
        if (widget.reviews.length > 2) ...[
          const SizedBox(height: 16),
          _ViewAllButton(
            l10n: widget.l10n,
            totalReviews: widget.totalReviews,
          ),
        ],
      ],
    );
  }

  Widget _buildTestimonialCard(ReviewModel review, int index) {
    final childName = _getChildName(review.parentName);
    final childAge = _getChildAge(index);

    return TestimonialCard(
      rating: review.rating,
      reviewText: review.comment,
      name: review.parentName,
      role: widget.l10n.verifiedExplorer,
      createdAt: review.createdAt,
      childName: childName,
      childAge: childAge,
    );
  }

  String _getChildName(String parentName) {
    final names = ['Layla', 'Omar', 'Yara', 'Zain', 'Sara', 'Adam', 'Leen', 'Rayan'];
    final index = parentName.length % names.length;
    return names[index];
  }

  int _getChildAge(int index) {
    return 4 + (index % 4);
  }
}

class _FunHeader extends StatelessWidget {
  const _FunHeader({
    required this.l10n,
    required this.averageRating,
    required this.totalReviews,
    required this.floatAnimation,
  });

  final AppLocalizations l10n;
  final double averageRating;
  final int totalReviews;
  final Animation<double> floatAnimation;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final isNarrow = c.maxWidth < 520;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fun emoji header
                  Row(
                    children: [
                      const Text('🌟', style: TextStyle(fontSize: 32)),
                      const SizedBox(width: 8),
                      Text(
                        l10n.explorerTestimonials,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppColors.cartTeal,
                          height: 1.15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Rating summary with fun emojis
                  Row(
                    children: [
                      // Stars
                      Row(
                        children: List.generate(5, (index) {
                          final fullStars = averageRating.floor();
                          final hasHalfStar = averageRating - fullStars >= 0.5;

                          if (index < fullStars) {
                            return const Text('⭐', style: TextStyle(fontSize: 18));
                          } else if (index == fullStars && hasHalfStar) {
                            return const Text('⭐', style: TextStyle(fontSize: 18));
                          } else {
                            return const Text('☆',
                                style: TextStyle(fontSize: 18, color: Colors.grey));
                          }
                        }),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '($totalReviews)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.cartMutedGrey,
                        ),
                      ),
                    ],
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
            if (!isNarrow) ...[
              const SizedBox(width: 16),
              AnimatedBuilder(
                animation: floatAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -3 * floatAnimation.value),
                    child: child,
                  );
                },
                child: _WriteReviewButton(l10n: l10n),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ViewAllButton extends StatelessWidget {
  const _ViewAllButton({
    required this.l10n,
    required this.totalReviews,
  });

  final AppLocalizations l10n;
  final int totalReviews;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0.95, end: 1.0),
        duration: const Duration(milliseconds: 500),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: child,
          );
        },
        child: OutlinedButton.icon(
          onPressed: () {
            // TODO: Navigate to all reviews
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.cartTeal,
            side: BorderSide(color: AppColors.cartTeal.withValues(alpha: 0.3), width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          icon: const Icon(Icons.arrow_forward_rounded, size: 16),
          label: Text(
            '👀 ${l10n.explorationsViewAll} ($totalReviews)',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _TestimonialsEmpty extends StatelessWidget {
  const _TestimonialsEmpty({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cartTeal.withValues(alpha: 0.05),
            AppColors.cartTeal.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.cartTeal.withValues(alpha: 0.1),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('📝', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            l10n.explorerTestimonials,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: AppColors.cartTeal,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.noReviewsYet,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.cartMutedGrey,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          _WriteReviewButton(l10n: l10n),
        ],
      ),
    );
  }
}

class _TestimonialsShimmer extends StatelessWidget {
  const _TestimonialsShimmer({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final sideBySide = w >= 900;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Text('🌟', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 8),
            Text(
              l10n.explorerTestimonials,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.cartTeal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (sideBySide)
          Row(
            children: [
              Expanded(child: _shimmerCard()),
              const SizedBox(width: 20),
              Expanded(child: _shimmerCard()),
            ],
          )
        else
          Column(
            children: [
              _shimmerCard(),
              const SizedBox(height: 16),
              _shimmerCard(),
            ],
          ),
      ],
    );
  }

  Widget _shimmerCard() {
    return Container(
      height: 180,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rating shimmer
          Row(
            children: List.generate(
              5,
                  (_) => Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Text shimmer
          Container(
            height: 12,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 12,
            width: 0.7,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          // Avatar shimmer
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 10,
                      width: 0.5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      height: 8,
                      width: 0.3,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WriteReviewButton extends StatelessWidget {
  const _WriteReviewButton({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0.95, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: child,
        );
      },
      child: ElevatedButton.icon(
        onPressed: () {
          // TODO: Open write review dialog
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.cartTotalRose,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.star_border, size: 18),
        label: Text(
          '✍️ ${l10n.writeReview}',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}