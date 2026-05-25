import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../cubits/cart/cart_cubit.dart';
import '../../../cubits/kit/kit_cubit.dart';
import '../../../cubits/kit/kit_state.dart';
import '../../../cubits/reviews/kit_reviews_cubit.dart';
import '../../../cubits/reviews/kit_reviews_state.dart';
import '../../../shared/components/footer/footer.dart';
import '../../../shared/components/navbar/navbar.dart';
import '../../../shared/i18n/app_localizations.dart';
import '../../../shared/providers/language_provider.dart';
import '../../../util/theme/app_colors.dart';
import '../widgets/kit_details/kit_details_constants.dart';
import '../widgets/kit_details/kit_details_skeleton.dart';
import '../widgets/kit_details/kit_hero_section.dart';
import '../widgets/kit_details/kit_mindset_section.dart';
import '../widgets/kit_details/kit_testimonials_section.dart';
import '../widgets/kit_details/kit_whats_inside_section.dart';

class KitDetailsPage extends StatefulWidget {
  const KitDetailsPage({super.key});

  @override
  State<KitDetailsPage> createState() => _KitDetailsPageState();
}

class _KitDetailsPageState extends State<KitDetailsPage> {
  final ScrollController _scrollController = ScrollController();
  bool _addingToCart = false;
  int? _kitId;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  int _resolveKitId(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    return args is int ? args : 1;
  }

  Future<void> _onAddToCart(BuildContext context, KitLoaded loaded) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _addingToCart = true);

    final ok = await context.read<CartCubit>().addItem(loaded.kit.id, 1);

    if (!context.mounted) return;
    setState(() => _addingToCart = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? l10n.addedToCart : l10n.addToCartFailed),
        behavior: SnackBarBehavior.floating,
        backgroundColor: ok ? AppColors.cartForestGreen : Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.sizeOf(context).width;
    final hPad = width >= 768 ? 40.0 : 20.0;
    _kitId ??= _resolveKitId(context);

    return Scaffold(
      backgroundColor: AppColors.cartPageBackground,
      endDrawer: Drawer(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: AlignmentDirectional.topEnd,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    Provider.of<LanguageProvider>(context, listen: false)
                        .toggleLanguage();
                    Navigator.of(context).pop();
                  },
                  child: Text(l10n.language),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                  },
                  child: Text(l10n.navHome),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.navAbout),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.navPricing),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(l10n.navBlog),
                ),
              ],
            ),
          ),
        ),
      ),
      body: BlocBuilder<KitCubit, KitState>(
        builder: (context, state) {
          return SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                Navbar(
                  scrollController: _scrollController,
                  isLoggedIn: true,
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(hPad, 28, hPad, 0),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1180),
                      child: _buildContent(context, l10n, state),
                    ),
                  ),
                ),
                Footer(scrollController: _scrollController),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n, KitState state) {
    if (state is KitLoading || state is KitInitial) {
      return const KitDetailsSkeleton();
    }

    if (state is KitError) {
      return _KitErrorView(
        message: state.message,
        onRetry: () => context.read<KitCubit>().getKitById(_kitId!),
      );
    }

    if (state is KitLoaded) {
      final kit = state.kit;
      final criteria = kit.mindset?.criteria ?? [];
      final reviewCount = _reviewCount(context);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KitHeroSection(
            l10n: l10n,
            kit: kit,
            reviewCount: reviewCount,
            rating: _averageRating(context) ?? kit.rating,
            fallbackMainAsset: KitDetailsConstants.heroMain,
            fallbackThumbAssets: const [
              KitDetailsConstants.heroThumb1,
              KitDetailsConstants.heroThumb2,
            ],
            isAddingToCart: _addingToCart,
            onAddToCart: () => _onAddToCart(context, state),
          ),
          const SizedBox(height: 56),
          KitMindsetSection(
            l10n: l10n,
            criteria: criteria,
          ),
          const SizedBox(height: 56),
          KitWhatsInsideSection(
            l10n: l10n,
            items: kit.kitItems,
            imageUrl: kit.imageURL,
            fallbackImageAsset: KitDetailsConstants.whatsInsideImage,
          ),
          const SizedBox(height: 56),
          KitTestimonialsSection(l10n: l10n),
          const SizedBox(height: 48),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  int _reviewCount(BuildContext context) {
    final rState = context.watch<KitReviewsCubit>().state;
    if (rState is KitReviewsLoaded) return rState.totalReviews;
    return 0;
  }

  double? _averageRating(BuildContext context) {
    final rState = context.watch<KitReviewsCubit>().state;
    if (rState is KitReviewsLoaded) return rState.averageRating;
    return null;
  }
}

class _KitErrorView extends StatelessWidget {
  const _KitErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 56, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.cartTeal,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
            ),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }
}
