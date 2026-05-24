import 'package:flutter/material.dart';
import '../../../shared/i18n/app_localizations.dart';
import '../../../util/theme/app_colors.dart';

class WelcomeHeader extends StatelessWidget {
  const WelcomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.profileWelcomeBack(l10n.profileUserName),
          textAlign: TextAlign.start,
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.w900,
            color: AppColors.cartForestGreen,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          l10n.profileWelcomeSubtitle(l10n.profileChildName),
          textAlign: TextAlign.start,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.cartMutedGrey.withValues(alpha: 0.95),
            height: 1.45,
          ),
        ),
      ],
    );
  }
}
