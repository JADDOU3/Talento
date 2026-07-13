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

  @override
  Widget build(BuildContext context) {
    return isChildMode
        ? _ChildProfileCard(
      name: name,
      avatarUrl: avatarUrl,
    )
        : _ParentProfileCard(
      name: name,
      email: email,
    );
  }
}

class _ParentProfileCard extends StatelessWidget {
  final String name;
  final String email;

  const _ParentProfileCard({
    required this.name,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = name.trim().isNotEmpty ? name.trim() : email.trim();
    final displayEmail = email.trim();

    return _ProfileShell(
      accentColor: AppColors.primary,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          const _ParentAvatar(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 9),
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (displayEmail.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    displayEmail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChildProfileCard extends StatelessWidget {
  final String name;
  final String? avatarUrl;

  const _ChildProfileCard({
    required this.name,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return _ProfileShell(
      accentColor: AppColors.secondary,
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          _ChildAvatar(
            name: name,
            avatarUrl: avatarUrl,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProfileLabel(
                  icon: Icons.auto_awesome_rounded,
                  text: 'ملف الطفل',
                  color: AppColors.primary,
                ),
                const SizedBox(height: 9),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.headlineMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'مستكشف صغير في تالينتو',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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

class _ProfileShell extends StatelessWidget {
  final Color accentColor;
  final Widget child;

  const _ProfileShell({
    required this.accentColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.18),
          width: 1.3,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.035),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ProfileLabel extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _ProfileLabel({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: color,
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ParentAvatar extends StatelessWidget {
  const _ParentAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 82,
      height: 82,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.primary.withValues(alpha: 0.18),
            AppColors.secondary.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.20),
        ),
      ),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.white,
        ),
        child: const Icon(
          Icons.family_restroom_rounded,
          color: AppColors.primary,
          size: 39,
        ),
      ),
    );
  }
}

class _ChildAvatar extends StatelessWidget {
  final String name;
  final String? avatarUrl;

  const _ChildAvatar({
    required this.name,
    required this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final trimmedAvatar = avatarUrl?.trim();
    final hasAvatar =
        trimmedAvatar != null && trimmedAvatar.isNotEmpty;

    return Container(
      width: 84,
      height: 84,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.primary.withValues(alpha: 0.18),
            AppColors.secondary.withValues(alpha: 0.10),
          ],
        ),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.22),
          width: 1.5,
        ),
      ),
      child: ClipOval(
        child: hasAvatar
            ? Image.network(
          trimmedAvatar,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
              _InitialAvatar(name: name),
        )
            : _InitialAvatar(name: name),
      ),
    );
  }
}

class _InitialAvatar extends StatelessWidget {
  final String name;

  const _InitialAvatar({
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    final trimmedName = name.trim();
    final initial = trimmedName.isEmpty
        ? 'ط'
        : trimmedName.characters.first.toUpperCase();

    return Container(
      color: AppColors.white,
      alignment: Alignment.center,
      child: Text(
        initial,
        style: AppTextStyles.headlineLarge.copyWith(
          color: AppColors.primary,
          fontSize: 34,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
