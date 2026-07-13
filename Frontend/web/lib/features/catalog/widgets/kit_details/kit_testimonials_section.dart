// lib/features/catalog/widgets/kit_details/kit_testimonials_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../cubits/reviews/kit_reviews_cubit.dart';
import '../../../../cubits/reviews/kit_reviews_state.dart';
import '../../../../shared/i18n/app_localizations.dart';
import '../../../../shared/services/auth_state.dart';
import '../../../../util/theme/app_colors.dart';
import 'review_card.dart';
import 'write_review_dialog.dart';

class KitTestimonialsSection extends StatefulWidget {
  final AppLocalizations l10n;
  final int kitId;

  const KitTestimonialsSection({
    super.key,
    required this.l10n,
    required this.kitId,
  });

  @override
  State<KitTestimonialsSection> createState() => _KitTestimonialsSectionState();
}

class _KitTestimonialsSectionState extends State<KitTestimonialsSection> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<KitReviewsCubit>().loadForKit(widget.kitId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final reviewsState = context.watch<KitReviewsCubit>().state;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.l10n.explorerTestimonials,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.cartForestGreen,
              ),
            ),
            if (AuthState.instance.isLoggedIn)
              OutlinedButton(
                onPressed: _isLoading
                    ? null
                    : () {
                  _showWriteReviewDialog(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.cartTeal,
                  side: const BorderSide(color: AppColors.cartTeal),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(widget.l10n.writeReview),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          widget.l10n.testimonialsSubtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),
        if (reviewsState is KitReviewsLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: CircularProgressIndicator(
                color: AppColors.cartTeal,
                strokeWidth: 2,
              ),
            ),
          ),
        if (reviewsState is KitReviewsLoaded)
          _buildReviewList(reviewsState),
        if (reviewsState is KitReviewsEmpty)
          _buildEmptyState(),
        if (reviewsState is KitReviewsHidden)
          const SizedBox.shrink(),
        if (reviewsState is KitReviewsError)
          _buildErrorState(reviewsState.message),
      ],
    );
  }

  Widget _buildReviewList(KitReviewsLoaded state) {
    if (state.reviews.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.star,
                color: Color(0xFFFFB800),
                size: 28,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${state.averageRating.toStringAsFixed(1)} out of 5',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  Text(
                    '${state.totalReviews} reviews',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.reviews.length,
          itemBuilder: (context, index) {
            return ReviewCard(review: state.reviews[index]);
          },
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'No reviews yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Be the first to share your experience!',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
          if (AuthState.instance.isLoggedIn) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.cartTeal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: _isLoading
                  ? null
                  : () {
                _showWriteReviewDialog(context);
              },
              child: const Text('Write a Review'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              if (mounted) {
                context.read<KitReviewsCubit>().loadForKit(widget.kitId);
              }
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _showWriteReviewDialog(BuildContext context) {
    if (_isLoading) return;

    debugPrint('🔵 Opening write review dialog for kit ${widget.kitId}');

    // ✅ Use a separate context for the dialog
    final dialogContext = context;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WriteReviewDialog(
          kitId: widget.kitId,
          onSubmit: (rating, comment) async {
            debugPrint('🔵 Dialog onSubmit called: rating=$rating, kitId=${widget.kitId}');

            try {
              // ✅ Use the cubit from the dialog's context
              final cubit = context.read<KitReviewsCubit>();
              final success = await cubit.submitReview(
                widget.kitId,
                rating,
                comment,
              );

              debugPrint('🔵 Submit result: success=$success');

              // ✅ Use the dialog context for snackbar
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'Review submitted successfully! 🎉' : 'Failed to submit review',
                    ),
                    backgroundColor: success ? Colors.green : Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            } catch (e) {
              debugPrint('❌ Error in onSubmit: $e');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${e.toString()}'),
                    backgroundColor: Colors.redAccent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
          },
        );
      },
    );
  }
}