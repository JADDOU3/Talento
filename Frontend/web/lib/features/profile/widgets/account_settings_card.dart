import 'package:flutter/material.dart';
import '../../../shared/i18n/app_localizations.dart';
import '../../../util/theme/app_colors.dart';
import 'settings_row.dart';

class AccountSettingsCard extends StatelessWidget {
  const AccountSettingsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsetsDirectional.fromSTEB(24, 24, 24, 12),
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
          Text(
            l10n.profileAccountSettings,
            textAlign: TextAlign.start,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.cartForestGreen,
            ),
          ),
          const SizedBox(height: 8),
          SettingsRow(
            icon: Icons.person_outline_rounded,
            label: l10n.profileProfileInformation,
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          SettingsRow(
            icon: Icons.credit_card_outlined,
            label: l10n.profilePaymentMethods,
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          SettingsRow(
            icon: Icons.local_shipping_outlined,
            label: l10n.profileShippingAddress,
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          SettingsRow(
            icon: Icons.logout_rounded,
            label: l10n.profileSignOut,
            isDestructive: true,
          ),
        ],
      ),
    );
  }
}
