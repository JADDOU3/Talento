// lib/features/profile/widgets/subscription_card.dart
import 'package:flutter/material.dart';
import '../../../shared/i18n/app_localizations.dart';
import '../../../util/theme/app_colors.dart';
import 'badge_icon.dart';

class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard({super.key});

  static const Color _badgePink = Color(0xFFFFD6D6);
  static const Color _badgePinkText = Color(0xFFB84A5A);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final width = MediaQuery.sizeOf(context).width;
    final sideBySide = width >= 640;

    final subscriptionPanel = Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.profileManageSubscription,
                  textAlign: TextAlign.start,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.cartForestGreen,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4F0E8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.profileActive,
                  maxLines: 1,
                  softWrap: false,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: Directionality.of(context) == TextDirection.rtl ? 0 : 0.8,
                    color: AppColors.cartTeal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            l10n.profilePlanName,
            textAlign: TextAlign.start,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.cartForestGreen,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.profileNextDelivery,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.cartMutedGrey.withOpacity(0.95),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.profileBillingAmount,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.cartMutedGrey.withOpacity(0.95),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.cartTeal,
                side: const BorderSide(color: AppColors.cartTeal, width: 1.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                l10n.profilePauseOrUpdate,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );

    final badgesPanel = Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _badgePink,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.profileLeosBadges(l10n.profileChildName),
            textAlign: TextAlign.start,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _badgePinkText,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.profileBadgesSubtitle,
            textAlign: TextAlign.start,
            style: TextStyle(
              fontSize: 13,
              color: _badgePinkText.withOpacity(0.75),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const BadgeIcon(
                label: 'Eco',
                color: AppColors.cartTeal,
                icon: Icons.eco_rounded,
              ),
              const SizedBox(width: 12),
              const BadgeIcon(
                label: 'Flight',
                color: Color(0xFFFF8FA3),
                icon: Icons.flight_rounded,
              ),
              const SizedBox(width: 12),
              const BadgeIcon(
                label: 'Sun',
                color: Color(0xFF8BC34A),
                icon: Icons.wb_sunny_rounded,
              ),
              const SizedBox(width: 12),
              BadgeIcon(
                label: 'Coming soon...',
                color: Colors.grey,
                icon: Icons.add_rounded,
              ),
            ],
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () {},
            child: Text(
              l10n.profileViewPortfolio,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.1,
                color: _badgePinkText,
              ),
            ),
          ),
        ],
      ),
    );

    if (sideBySide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: subscriptionPanel),
          const SizedBox(width: 20),
          Expanded(child: badgesPanel),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        subscriptionPanel,
        const SizedBox(height: 20),
        badgesPanel,
      ],
    );
  }
}