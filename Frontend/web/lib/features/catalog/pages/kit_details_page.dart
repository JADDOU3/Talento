import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/components/footer/footer.dart';
import '../../../shared/components/navbar/navbar.dart';
import '../../../shared/i18n/app_localizations.dart';
import '../../../shared/providers/language_provider.dart';
import '../../../util/theme/app_colors.dart';
import '../widgets/kit_details/kit_details_constants.dart';
import '../widgets/kit_details/kit_hero_section.dart';
import '../widgets/kit_details/kit_mindset_section.dart';
import '../widgets/kit_details/kit_testimonials_section.dart';
import '../widgets/kit_details/kit_whats_inside_section.dart';

/// Kit product page (mock data, no API). Uses shared [Navbar] and [Footer].
class KitDetailsPage extends StatefulWidget {
  const KitDetailsPage({super.key});

  @override
  State<KitDetailsPage> createState() => _KitDetailsPageState();
}

class _KitDetailsPageState extends State<KitDetailsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onAddToCart(BuildContext context, AppLocalizations l10n) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.kitDetailsAddToCartDemo),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.cartForestGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.sizeOf(context).width;
    final hPad = width >= 768 ? 40.0 : 20.0;

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
                    Navigator.of(context).pushNamed('/home');
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
            Navbar(
              scrollController: _scrollController,
              isLoggedIn: true,
            ),
            Padding(
              padding: EdgeInsetsDirectional.fromSTEB(hPad, 28, hPad, 0),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      KitHeroSection(
                        l10n: l10n,
                        mainImageAsset: KitDetailsConstants.heroMain,
                        thumbnailAssets: const [
                          KitDetailsConstants.heroThumb1,
                          KitDetailsConstants.heroThumb2,
                        ],
                        reviewCount: 128,
                        rating: 4.5,
                        onAddToCart: () => _onAddToCart(context, l10n),
                      ),
                      const SizedBox(height: 56),
                      KitMindsetSection(l10n: l10n),
                      const SizedBox(height: 56),
                      KitWhatsInsideSection(l10n: l10n),
                      const SizedBox(height: 56),
                      KitTestimonialsSection(l10n: l10n),
                      const SizedBox(height: 48),
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
}
