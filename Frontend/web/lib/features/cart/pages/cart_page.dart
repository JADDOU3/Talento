import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../cubits/cart/cart_cubit.dart';
import '../../../cubits/cart/cart_state.dart';
import '../../../shared/components/footer/footer.dart';
import '../../../shared/components/navbar/navbar.dart';
import '../../../shared/i18n/app_localizations.dart';
import '../../../shared/models/cart_model.dart';
import '../../../shared/providers/language_provider.dart';
import '../../../util/theme/app_colors.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/cart_skeleton.dart';
import '../widgets/order_summary_panel.dart';
import '../widgets/promo_code_input.dart';
import '../widgets/recommended_card.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _promoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CartCubit>().loadCart();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  double _tax(double subtotal) =>
      double.parse((subtotal * 0.08).toStringAsFixed(2));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.sizeOf(context).width;
    final twoColumn = width >= 1000;

    return Scaffold(
      backgroundColor: AppColors.cartPageBackground,
      endDrawer: _buildDrawer(context, l10n),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            Navbar(scrollController: _scrollController, isLoggedIn: true),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: width >= 768 ? 40 : 20,
                vertical: 28,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: BlocBuilder<CartCubit, CartState>(
                    builder: (context, state) {
                      if (state is CartLoading || state is CartInitial) {
                        return CartSkeleton(twoColumn: twoColumn);
                      }
                      if (state is CartError) {
                        return _CartErrorView(
                          message: state.message,
                          onRetry: () => context.read<CartCubit>().loadCart(),
                        );
                      }
                      if (state is CartEmpty) {
                        return _CartEmptyView(l10n: l10n);
                      }
                      if (state is CartLoaded) {
                        return _buildCartContent(
                          context,
                          l10n,
                          state.cart,
                          twoColumn,
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ),
            Footer(scrollController: _scrollController),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AppLocalizations l10n) {
    return Drawer(
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
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/', (route) => false);
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
    );
  }

  Widget _buildCartContent(
    BuildContext context,
    AppLocalizations l10n,
    CartModel cart,
    bool twoColumn,
  ) {
    final subtotal = cart.subtotal;
    final tax = _tax(subtotal);
    final total = subtotal + tax;
    final itemCount = cart.lineItemCount;

    final mainColumn = _buildMainColumn(context, l10n, cart, itemCount);
    final sideColumn = _buildSideColumn(context, l10n, subtotal, tax, total);

    if (twoColumn) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 62, child: mainColumn),
          const SizedBox(width: 32),
          Expanded(flex: 38, child: sideColumn),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        mainColumn,
        const SizedBox(height: 28),
        sideColumn,
      ],
    );
  }

  Widget _buildMainColumn(
    BuildContext context,
    AppLocalizations l10n,
    CartModel cart,
    int itemCount,
  ) {
    final cubit = context.read<CartCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                l10n.yourBasket,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: AppColors.cartForestGreen,
                  height: 1.1,
                ),
              ),
            ),
            Text(
              l10n.cartItemsCount(itemCount).toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.1,
                color: AppColors.cartMutedGrey.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        ...cart.items.map((item) {
          return CartItemCard(
            imageAsset: item.kitImageURL,
            name: item.kitName,
            description: item.kitDescription,
            quantity: item.quantity,
            unitPrice: item.kitPrice,
            removeTooltip: l10n.cartRemoveA11y,
            onQuantityChanged: (newQty) {
              if (newQty <= 0) {
                cubit.removeItem(item.id);
              } else {
                cubit.updateItem(item.id, newQty);
              }
            },
            onRemove: () => cubit.removeItem(item.id),
          );
        }),
        const SizedBox(height: 36),
        Text(
          l10n.recommendedForYou,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.cartForestGreen,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, c) {
            final narrow = c.maxWidth < 520;
            if (narrow) {
              return Column(
                children: [
                  _rec1(context, l10n),
                  const SizedBox(height: 14),
                  _rec2(context, l10n),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _rec1(context, l10n)),
                const SizedBox(width: 16),
                Expanded(child: _rec2(context, l10n)),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _rec1(BuildContext context, AppLocalizations l10n) {
    return RecommendedCard(
      badgeLabel: l10n.badgeAddOn,
      title: l10n.cartRec1Title,
      description: l10n.cartRec1Desc,
      addButtonLabel: l10n.cartAddAmount(r'$18'),
      gradientColors: const [
        Color(0xFFE8F5E9),
        Color(0xFFD4EDD9),
      ],
      addButtonColor: AppColors.cartForestGreen,
      decorationIcon: Icons.brush_rounded,
      onAdd: () {},
    );
  }

  Widget _rec2(BuildContext context, AppLocalizations l10n) {
    return RecommendedCard(
      badgeLabel: l10n.badgeCrossSell,
      title: l10n.cartRec2Title,
      description: l10n.cartRec2Desc,
      addButtonLabel: l10n.cartAddAmount(r'$55'),
      gradientColors: const [
        Color(0xFFE0F7F4),
        Color(0xFFB8EDE0),
      ],
      addButtonColor: AppColors.cartTeal,
      decorationIcon: Icons.biotech_rounded,
      onAdd: () {},
    );
  }

  Widget _buildSideColumn(
    BuildContext context,
    AppLocalizations l10n,
    double subtotal,
    double tax,
    double total,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OrderSummaryPanel(
          subtotal: subtotal,
          tax: tax,
          total: total,
          onCheckout: () {},
        ),
        const SizedBox(height: 22),
        PromoCodeInput(
          controller: _promoController,
          onApply: () {},
        ),
      ],
    );
  }
}

class _CartEmptyView extends StatelessWidget {
  const _CartEmptyView({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 80),
      child: Column(
        children: [
          Icon(
            Icons.shopping_basket_outlined,
            size: 72,
            color: AppColors.cartMutedGrey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.cartEmptyTitle,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.cartForestGreen,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.cartEmptyMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: AppColors.cartMutedGrey.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () => Navigator.of(context).pushNamed('/catalog'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.cartTeal,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: const StadiumBorder(),
            ),
            child: Text(
              l10n.discoverKits,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _CartErrorView extends StatelessWidget {
  const _CartErrorView({
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
