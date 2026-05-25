import 'package:flutter/material.dart';
import '../../../shared/i18n/app_localizations.dart';
import '../../../util/theme/app_colors.dart';

class KitProgressCard extends StatelessWidget {
  const KitProgressCard({super.key});

  static const Color _mintTint = Color(0xFFE8F5F0);
  static const Color _badgeTeal = Color(0xFF1B4332);
  static const double _progress = 0.68;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _mintTint,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          PositionedDirectional(
            end: -20,
            bottom: -30,
            child: Opacity(
              opacity: 0.35,
              child: Image.asset(
                'assets/images/img4.jpg',
                width: 200,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Icon(
                  Icons.eco_rounded,
                  size: 160,
                  color: AppColors.cartTeal.withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(28, 28, 28, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsetsDirectional.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _badgeTeal,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l10n.profileCuriosityProgress,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  l10n.profileKitTitle,
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.cartForestGreen,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Text(
                    l10n.profileKitDescription,
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppColors.cartMutedGrey.withValues(alpha: 0.95),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  l10n.profileMasteryReached(68),
                  textAlign: TextAlign.start,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: AppColors.cartForestGreen,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 10,
                    backgroundColor: Colors.white.withValues(alpha: 0.7),
                    color: AppColors.cartTeal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
