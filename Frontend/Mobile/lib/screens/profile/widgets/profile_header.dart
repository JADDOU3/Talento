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
    if (isChildMode) {
      return _ChildModeHeader(
        name: name,
        avatarUrl: avatarUrl,
        defaultAssetPath: _defaultChildAvatarAsset,
      );
    }

    return _ParentHeader(
      name: name,
      email: email,
    );
  }
}


class _ParentHeader extends StatelessWidget {
  final String name;
  final String email;

  const _ParentHeader({
    required this.name,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = name.trim().isNotEmpty ? name.trim() : email.trim();
    final displayEmail = email.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.16),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.055),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.ltr,
        children: [
          const _ParentIconBadge(),
          const SizedBox(width: 16),
          Container(
            width: 1.2,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'حساب ولي الأمر',
                    textAlign: TextAlign.right,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    displayName,
                    textAlign: TextAlign.right,
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (displayEmail.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      displayEmail,
                      textAlign: TextAlign.right,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParentIconBadge extends StatelessWidget {
  const _ParentIconBadge();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 85,
      height: 85,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: 6,
            left: 6,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.16),
                    AppColors.primary.withValues(alpha: 0.04),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: 14,
            left: 14,
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.92),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: const Icon(
                Icons.escalator_warning_rounded,
                color: AppColors.primary,
                size: 35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChildModeHeader extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final String defaultAssetPath;

  const _ChildModeHeader({
    required this.name,
    required this.avatarUrl,
    required this.defaultAssetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.18),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _ChildAvatar(
            avatarUrl: avatarUrl,
            defaultAssetPath: defaultAssetPath,
          ),
          const SizedBox(width: 16),
          Container(
            width: 1.2,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ملف الطفل',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    name,
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'مستكشف صغير في تالينتو',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
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
      width: 82,
      height: 82,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.22),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
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




