// lib/features/profile/widgets/account_settings_card.dart
import 'package:flutter/material.dart';
import '../../../shared/i18n/app_localizations.dart';
import '../../../shared/services/auth_state.dart';
import '../../../util/theme/app_colors.dart';
import 'settings_row.dart';

class AccountSettingsCard extends StatelessWidget {
  const AccountSettingsCard({super.key});

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Sign Out',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A2E),
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[400],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              AuthState.instance.setLoggedIn(false);
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
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
          // Header
          Text(
            l10n.profileAccountSettings,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.cartForestGreen,
            ),
          ),
          const SizedBox(height: 18),

          // Profile Information
          SettingsRow(
            icon: Icons.person_outline,
            title: l10n.profileProfileInformation,
            onTap: () {
              // Navigate to profile edit page
              // Navigator.pushNamed(context, '/profile/edit');
            },
          ),

          // ✅ REMOVED: Payment Methods
          // ✅ REMOVED: Shipping Address

          // Sign Out (with divider above)
          SettingsRow(
            icon: Icons.logout,
            title: l10n.profileSignOut,
            isDanger: true,
            onTap: () => _handleLogout(context),
          ),
        ],
      ),
    );
  }
}