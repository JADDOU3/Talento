import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../shared/components/footer/footer.dart';
import '../../../shared/components/navbar/navbar.dart';
import '../../../shared/i18n/app_localizations.dart';
import '../../../shared/providers/language_provider.dart';
import '../../../shared/services/auth_service.dart';
import '../../../shared/models/parent_profile.dart';
import '../../../util/theme/app_colors.dart';
import '../cubits/orders/orders_cubit.dart';
import '../widgets/account_settings_card.dart';
import '../widgets/kit_progress_card.dart';
import '../widgets/order_history_card.dart';
import '../widgets/recommended_kit_card.dart';
import '../widgets/subscription_card.dart';
import '../widgets/welcome_header.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ScrollController _scrollController = ScrollController();
  late final OrdersCubit _ordersCubit;

  ParentProfile? _parentProfile;
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _ordersCubit = OrdersCubit()..loadOrders();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await AuthService.getCurrentUser();
    if (!mounted) return;
    setState(() {
      _parentProfile = profile;
      _loadingProfile = false;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _ordersCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.sizeOf(context).width;
    final twoColumn = width >= 1000;
    final horizontalPadding = width >= 768 ? 40.0 : 20.0;

    return BlocProvider.value(
      value: _ordersCubit,
      child: Scaffold(
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
              // Fixed: was hardcoded `isLoggedIn: true`, which permanently
              // overrode real auth state. Now reads it live from AuthState.
              Navbar(
                scrollController: _scrollController,
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(
                  horizontalPadding,
                  28,
                  horizontalPadding,
                  28,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1180),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        WelcomeHeader(
                          // null while loading -> WelcomeHeader falls back
                          // to the old placeholder text automatically.
                          userName: _loadingProfile ? null : _parentProfile?.name,
                          // Child name still not wired — see note above
                          // about /children/selected. Falls back too.
                        ),
                        const SizedBox(height: 28),
                        if (twoColumn)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 62,
                                child: _buildMainColumn(context, l10n),
                              ),
                              const SizedBox(width: 32),
                              Expanded(
                                flex: 38,
                                child: _buildSideColumn(context),
                              ),
                            ],
                          )
                        else
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const KitProgressCard(),
                              const SizedBox(height: 20),
                              const OrderHistoryCard(),
                              const SizedBox(height: 20),
                              const SubscriptionCard(),
                              const SizedBox(height: 20),
                              const AccountSettingsCard(),
                              const SizedBox(height: 32),
                              _buildRecommendedSection(context, l10n, width),
                            ],
                          ),
                        if (twoColumn) ...[
                          const SizedBox(height: 36),
                          _buildRecommendedSection(context, l10n, width),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              Footer(scrollController: _scrollController),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainColumn(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: const [
        KitProgressCard(),
        SizedBox(height: 20),
        SubscriptionCard(),
      ],
    );
  }

  Widget _buildSideColumn(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OrderHistoryCard(),
        SizedBox(height: 20),
        AccountSettingsCard(),
      ],
    );
  }

  Widget _buildRecommendedSection(
      BuildContext context,
      AppLocalizations l10n,
      double width,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.profileRecommendedForLeo(l10n.profileChildName),
          textAlign: TextAlign.start,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.cartForestGreen,
          ),
        ),
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth;
            if (cardWidth >= 900) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _recCard1(l10n)),
                  const SizedBox(width: 16),
                  Expanded(child: _recCard2(l10n)),
                  const SizedBox(width: 16),
                  Expanded(child: _recCard3(l10n)),
                ],
              );
            }
            if (cardWidth >= 560) {
              return Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _recCard1(l10n)),
                      const SizedBox(width: 16),
                      Expanded(child: _recCard2(l10n)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _recCard3(l10n),
                ],
              );
            }
            return Column(
              children: [
                _recCard1(l10n),
                const SizedBox(height: 16),
                _recCard2(l10n),
                const SizedBox(height: 16),
                _recCard3(l10n),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _recCard1(AppLocalizations l10n) {
    return RecommendedKitCard(
      imageAsset: 'assets/images/img5.png',
      badgeLabel: l10n.profileRec1Badge,
      title: l10n.profileRec1Title,
    );
  }

  Widget _recCard2(AppLocalizations l10n) {
    return RecommendedKitCard(
      imageAsset: 'assets/images/img6.png',
      badgeLabel: l10n.profileRec2Badge,
      title: l10n.profileRec2Title,
    );
  }

  Widget _recCard3(AppLocalizations l10n) {
    return RecommendedKitCard(
      imageAsset: 'assets/images/img7.png',
      badgeLabel: l10n.profileRec3Badge,
      title: l10n.profileRec3Title,
    );
  }
}