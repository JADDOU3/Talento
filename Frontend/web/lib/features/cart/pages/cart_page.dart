import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../shared/components/footer/footer.dart';
import '../../../shared/components/navbar/navbar.dart';
import '../../../shared/i18n/app_localizations.dart';
import '../../../shared/providers/language_provider.dart';
import '../../../util/theme/app_colors.dart';
import '../../../cubits/cart/cart_cubit.dart';
import '../../../cubits/cart/cart_state.dart';
import '../widgets/cart_item_card.dart';
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.sizeOf(context).width;
    final twoColumn = width >= 1000;

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
                  onPressed: () => Navigator.of(context).pop(),
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
      body: BlocBuilder<CartCubit, CartState>(
        builder: (context, state) {
          return SingleChildScrollView(
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
                      child: _buildBody(context, state, l10n, twoColumn),
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

  Widget _buildBody(BuildContext context, CartState state,
      AppLocalizations l10n, bool twoColumn) {
    if (state is CartLoading || state is CartInitial) return _buildSkeleton();
    if (state is CartError) return _buildError(context, state.message, l10n);
    if (state is CartEmpty) return _buildEmpty(context, l10n);

    if (state is CartLoaded) {
      final cart = state.cart;
      return twoColumn
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    flex: 62,
                    child: _buildMainColumn(context, l10n, state)),
                const SizedBox(width: 32),
                Expanded(
                    flex: 38,
                    child: _buildSideColumn(context, l10n, cart.subtotal,
                        cart.tax, cart.total)),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildMainColumn(context, l10n, state),
                const SizedBox(height: 28),
                _buildSideColumn(context, l10n, cart.subtotal, cart.tax,
                    cart.total),
              ],
            );
    }

    return const SizedBox();
  }

  Widget _buildMainColumn(
      BuildContext context, AppLocalizations l10n, CartLoaded state) {
    final cart = state.cart;
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
              l10n.cartItemsCount(cart.lineItemCount).toUpperCase(),
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
        ...cart.items.map((item) => CartItemCard(
              imageAsset: item.kitImageURL.isNotEmpty
                  ? item.kitImageURL
                  : 'assets/images/img1.jpg',
              name: item.kitName,
              description: item.kitDescription,
              quantity: item.quantity,
              unitPrice: item.kitPrice,
              removeTooltip: l10n.cartRemoveA11y,
              onQuantityChanged: (v) {
                if (v <= 0) {
                  context.read<CartCubit>().removeItem(item.id);
                } else {
                  context.read<CartCubit>().updateItem(item.id, v);
                }
              },
              onRemove: () {
                context.read<CartCubit>().removeItem(item.id);
              },
            )),
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
      gradientColors: const [Color(0xFFE8F5E9), Color(0xFFD4EDD9)],
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
      gradientColors: const [Color(0xFFE0F7F4), Color(0xFFB8EDE0)],
      addButtonColor: AppColors.cartTeal,
      decorationIcon: Icons.biotech_rounded,
      onAdd: () {},
    );
  }

  Widget _buildSideColumn(BuildContext context, AppLocalizations l10n,
      double subtotal, double tax, double total) {
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

  // ===== LOADING SKELETON =====
  Widget _buildSkeleton() {
    return Column(
      children: List.generate(
        3,
        (_) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  // ===== EMPTY STATE =====
  Widget _buildEmpty(BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          children: [
            const Icon(Icons.shopping_cart_outlined,
                size: 80, color: Colors.grey),
            const SizedBox(height: 20),
            Text(
              l10n.cartEmpty,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.cartForestGreen,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.cartEmptyDesc,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pushNamed('/catalog'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.cartTeal,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 16),
                shape: const StadiumBorder(),
              ),
              child: Text(l10n.discoverKits),
            ),
          ],
        ),
      ),
    );
  }

  // ===== ERROR STATE =====
  Widget _buildError(
      BuildContext context, String message, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          children: [
            const Icon(Icons.error_outline, size: 80, color: Colors.redAccent),
            const SizedBox(height: 20),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => context.read<CartCubit>().loadCart(),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.cartTeal,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 16),
                shape: const StadiumBorder(),
              ),
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}