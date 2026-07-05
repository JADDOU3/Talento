import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? avatarUrl;
  final bool isChildMode;

  const ProfileHeader({
    super.key,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.isChildMode = false,
  });

  static const String _defaultChildAvatarAsset =
      'assets/images/default_child_avatar.png';

  @override
  Widget build(BuildContext context) {
    final hasEmail = email.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontSize: 22,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (hasEmail) ...[
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          if (isChildMode) ...[
            const SizedBox(width: 16),
            _ChildAvatar(
              avatarUrl: avatarUrl,
              defaultAssetPath: _defaultChildAvatarAsset,
            ),
          ],
        ],
      ),
    );
  }
}

class _ChildAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String defaultAssetPath;

  const _ChildAvatar({
    required this.avatarUrl,
    required this.defaultAssetPath,
  });

  bool get _hasNetworkAvatar =>
      avatarUrl != null && avatarUrl!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 78,
      height: 78,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.22),
          width: 1.5,
        ),
      ),
      child: ClipOval(
        child: _hasNetworkAvatar
            ? Image.network(
          avatarUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _DefaultChildAvatar(
            assetPath: defaultAssetPath,
          ),
        )
            : _DefaultChildAvatar(
          assetPath: defaultAssetPath,
        ),
      ),
    );
  }
}

class _DefaultChildAvatar extends StatelessWidget {
  final String assetPath;

  const _DefaultChildAvatar({
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: AppColors.inputFill,
        child: const Icon(
          Icons.child_care_rounded,
          color: AppColors.primary,
          size: 38,
        ),
      ),
    );
  }
}