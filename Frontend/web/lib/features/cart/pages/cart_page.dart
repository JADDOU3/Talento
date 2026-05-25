import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/components/footer/footer.dart';
import '../../../shared/components/navbar/navbar.dart';
import '../../../shared/i18n/app_localizations.dart';
import '../../../shared/providers/language_provider.dart';
import '../../../util/theme/app_colors.dart';
import '../widgets/cart_item_card.dart';
import '../widgets/order_summary_panel.dart';
import '../widgets/promo_code_input.dart';
import '../widgets/recommended_card.dart';

class _CartEntry {
  final int lineIndex;
  final String imageAsset;
  final double unitPrice;
  int quantity;

  _CartEntry({
    required this.lineIndex,
    required this.imageAsset,
    required this.unitPrice,
  }) : quantity = 1;

  String name(AppLocalizations l10n) {
    return switch (lineIndex) {
      0 => l10n.cartLine1Title,
      1 => l10n.cartLine2Title,
      _ => l10n.cartLine3Title,
    };
  }

  String description(AppLocalizations l10n) {
    return switch (lineIndex) {
      0 => l10n.cartLine1Desc,
      1 => l10n.cartLine2Desc,
      _ => l10n.cartLine3Desc,
    };
  }
}

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _promoController = TextEditingController();

  late final List<_CartEntry> _entries = [
    _CartEntry(lineIndex: 0, imageAsset: 'assets/images/img1.jpg', unitPrice: 45),
    _CartEntry(lineIndex: 1, imageAsset: 'assets/images/img2.jpg', unitPrice: 22),
    _CartEntry(lineIndex: 2, imageAsset: 'assets/images/img3.jpg', unitPrice: 10),
  ];

  @override
  void dispose() {
    _scrollController.dispose();
    _promoController.dispose();
    super.dispose();
  }

  double get _subtotal =>
      _entries.fold<double>(0, (s, e) => s + e.unitPrice * e.quantity);

  int get _itemCount => _entries.fold<int>(0, (s, e) => s + e.quantity);

  double get _tax => double.parse((_subtotal * 0.08).toStringAsFixed(2));

  double get _total => _subtotal + _tax;

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
                    Provider.of<LanguageProvider>(context, listen: false).toggleLanguage();
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
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            Navbar(scrollController: _scrollController, isLoggedIn: true),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: width >= 768 ? 40 : 20, vertical: 28),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: twoColumn
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 62, child: _buildMainColumn(context, l10n)),
                            const SizedBox(width: 32),
                            Expanded(flex: 38, child: _buildSideColumn(context, l10n)),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildMainColumn(context, l10n),
                            const SizedBox(height: 28),
                            _buildSideColumn(context, l10n),
                          ],
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

  Widget _buildMainColumn(BuildContext context, AppLocalizations l10n) {
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
              l10n.cartItemsCount(_itemCount).toUpperCase(),
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
        ...List.generate(_entries.length, (index) {
          final e = _entries[index];
          return CartItemCard(
            imageAsset: e.imageAsset,
            name: e.name(l10n),
            description: e.description(l10n),
            quantity: e.quantity,
            unitPrice: e.unitPrice,
            removeTooltip: l10n.cartRemoveA11y,
            onQuantityChanged: (v) {
              setState(() => e.quantity = v);
            },
            onRemove: () {
              setState(() => _entries.removeAt(index));
            },
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

  Widget _buildSideColumn(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OrderSummaryPanel(
          subtotal: _subtotal,
          tax: _tax,
          total: _total,
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
