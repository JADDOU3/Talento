// lib/features/profile/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../shared/components/footer/footer.dart';
import '../../../shared/components/navbar/navbar.dart';
import '../../../shared/i18n/app_localizations.dart';
import '../../../shared/providers/language_provider.dart';
import '../../../shared/services/auth_service.dart';
import '../../../shared/services/auth_state.dart';
import '../../../shared/models/parent_profile.dart';
import '../../../util/theme/app_colors.dart';
import '../cubits/orders/orders_cubit.dart';
import '../widgets/account_settings_card.dart';
import '../widgets/kit_progress_card.dart';
import '../widgets/order_history_card.dart';
import '../widgets/recommended_kit_card.dart';
// ✅ REMOVED: import '../widgets/subscription_card.dart';
import '../widgets/welcome_header.dart';

Widget _decorativeCircle(double size, Color color) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

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

  Future<void> _handleLogout(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFE07A5F).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.logout_rounded,
                    color: const Color(0xFFE07A5F), size: 26),
              ),
              const SizedBox(height: 18),
              Text(
                l10n.profileSignOut,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: AppColors.cartForestGreen,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to logout?',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.cartMutedGrey.withOpacity(0.9),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.cartMutedGrey,
                        side: BorderSide(
                            color: AppColors.cartMutedGrey.withOpacity(0.3)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE07A5F),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (shouldLogout == true && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(
            color: AppColors.cartTeal,
          ),
        ),
      );

      try {
        await AuthService.logout();

        if (!mounted) return;
        Navigator.pop(context);

        Navigator.of(context).pushNamedAndRemoveUntil(
          '/',
              (route) => false,
        );
      } catch (e) {
        if (!mounted) return;
        Navigator.pop(context);

        AuthState.instance.setLoggedIn(false);
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/',
              (route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error during logout: $e'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
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
        endDrawer: _ProfileDrawer(onLogout: () => _handleLogout(context)),
        body: Stack(
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  _ProfileHero(
                    userName: _loadingProfile ? null : _parentProfile?.name,
                  ),
                  Padding(
                    padding: EdgeInsetsDirectional.fromSTEB(
                      horizontalPadding,
                      0,
                      horizontalPadding,
                      40,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1180),
                        child: Transform.translate(
                          offset: const Offset(0, 60),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (twoColumn)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      flex: 62,
                                      child: _buildMainColumn(context, l10n),
                                    ),
                                    const SizedBox(width: 28),
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
                                    // ✅ REPLACED: SubscriptionCard with AccountSettingsCard
                                    const AccountSettingsCard(),
                                    const SizedBox(height: 20),
                                    const OrderHistoryCard(),
                                  ],
                                ),
                              const SizedBox(height: 40),
                              _buildRecommendedSection(context, l10n, width),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Footer(scrollController: _scrollController),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Navbar(scrollController: _scrollController),
            ),
          ],
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
        // ✅ REPLACED: SubscriptionCard with AccountSettingsCard
        AccountSettingsCard(),
      ],
    );
  }

  Widget _buildSideColumn(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OrderHistoryCard(),
        SizedBox(height: 20),
        //AccountSettingsCard(),
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
        Row(
          children: [
            Container(
              width: 4,
              height: 24,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.cartTeal, Color(0xFFDDA83A)],
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.profileRecommendedForLeo(l10n.profileChildName),
                textAlign: TextAlign.start,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.cartForestGreen,
                ),
              ),
            ),
            const Text('✨', style: TextStyle(fontSize: 20)),
          ],
        ),
        const SizedBox(height: 20),
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

// ─── Hero backdrop behind the WelcomeHeader ──────────────────────────────────
class _ProfileHero extends StatelessWidget {
  final String? userName;

  const _ProfileHero({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 150, 24, 100),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.cartForestGreen,
            AppColors.cartTeal,
            Color(0xFF3FA796),
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: -20,
            right: -10,
            child: _decorativeCircle(70, const Color(0xFFE07A5F).withOpacity(0.35)),
          ),
          Positioned(
            top: 50,
            right: 60,
            child: _decorativeCircle(22, const Color(0xFFDDA83A).withOpacity(0.55)),
          ),
          Positioned(
            bottom: -30,
            left: -10,
            child: _decorativeCircle(90, Colors.white.withOpacity(0.14)),
          ),
          Positioned(
            bottom: 10,
            left: 100,
            child: _decorativeCircle(16, const Color(0xFFE07A5F).withOpacity(0.5)),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1180),
              child: WelcomeHeader(userName: userName),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Drawer ───────────────────────────────────────────────────────────────────
class _ProfileDrawer extends StatelessWidget {
  final VoidCallback onLogout;

  const _ProfileDrawer({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 204),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.cartForestGreen,
                    AppColors.cartTeal,
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _drawerLink(
                      icon: Icons.language_rounded,
                      label: l10n.language,
                      onTap: () {
                        Provider.of<LanguageProvider>(context, listen: false)
                            .toggleLanguage();
                        Navigator.of(context).pop();
                      },
                    ),
                    _drawerLink(
                      icon: Icons.home_rounded,
                      label: l10n.navHome,
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context)
                            .pushNamedAndRemoveUntil('/', (route) => false);
                      },
                    ),
                    _drawerLink(
                      icon: Icons.info_outline_rounded,
                      label: l10n.navAbout,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    _drawerLink(
                      icon: Icons.sell_outlined,
                      label: l10n.navPricing,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    _drawerLink(
                      icon: Icons.article_outlined,
                      label: l10n.navBlog,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onLogout,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE07A5F),
                    side: BorderSide(
                        color: const Color(0xFFE07A5F).withOpacity(0.4)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: Text(
                    l10n.profileSignOut,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerLink({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 20, color: AppColors.cartTeal),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.cartForestGreen,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}