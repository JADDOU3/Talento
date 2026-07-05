import 'package:flutter/material.dart';
import '../../../shared/i18n/app_localizations.dart';
import '../../../util/theme/app_colors.dart';

class WelcomeHeader extends StatelessWidget {
  /// The logged-in parent's real name (from ParentProfile). Pass null while
  /// still loading to show a lightweight fallback instead of blank text.
  final String? userName;

  /// The child's name — not yet wireable to real data; see note in
  /// ProfilePage about the /children/selected endpoint. Falls back to the
  /// old placeholder text until that's connected.
  final String? childName;

  const WelcomeHeader({super.key, this.userName, this.childName});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final resolvedUserName = userName ?? l10n.profileUserName;
    final resolvedChildName = childName ?? l10n.profileChildName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.profileWelcomeBack(resolvedUserName),
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
          l10n.profileWelcomeSubtitle(resolvedChildName),
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