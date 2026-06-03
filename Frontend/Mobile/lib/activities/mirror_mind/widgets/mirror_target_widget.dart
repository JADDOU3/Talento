import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/activities/mirror_mind/mirror_mind_challenge_model.dart';
import '../../../models/activities/mirror_mind/mirror_mind_choice_model.dart';
import 'mirror_icon_widget.dart';

class MirrorTargetWidget extends StatelessWidget {
  final MirrorMindChallengeModel challenge;
  final MirrorMindChoiceModel? selectedChoice;

  const MirrorTargetWidget({
    super.key,
    required this.challenge,
    this.selectedChoice,
  });

  @override
  Widget build(BuildContext context) {
    final leftIcons = challenge.originalSideIcons;
    final selectedIcons = selectedChoice?.displayIcons ?? <String>[];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.94),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.secondary.withOpacity(0.22),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.10),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _titleForChallenge(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'DGAgnadeen',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MirrorSideCard(
                  label: 'هنا',
                  child: MirrorIconSequence(
                    icons: leftIcons,
                    iconSize: _iconSizeForCount(leftIcons.length),
                    spacing: 10,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const _MirrorDivider(),
              const SizedBox(width: 12),
              Expanded(
                child: _MirrorSideCard(
                  label: 'الانعكاس',
                  isBlank: selectedIcons.isEmpty,
                  child: selectedIcons.isEmpty
                      ? const _BlankSlot()
                      : MirrorIconSequence(
                    icons: selectedIcons,
                    iconSize: _iconSizeForCount(selectedIcons.length),
                    spacing: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _titleForChallenge() {
    switch (challenge.type) {
      case MirrorMindChallengeType.simpleReflection:
        return 'أين يظهر انعكاس الشكل؟';
      case MirrorMindChallengeType.mirrorSequence:
        return 'اختَر ترتيب الأشكال في المرآة';
      case MirrorMindChallengeType.directionReflection:
        return 'كيف يبدو الاتجاه في المرآة؟';
      case MirrorMindChallengeType.unknown:
        return 'اختَر الإجابة الصحيحة';
    }
  }

  static double _iconSizeForCount(int count) {
    if (count >= 3) return 34;
    if (count == 2) return 40;
    return 54;
  }
}

class _MirrorSideCard extends StatelessWidget {
  final String label;
  final Widget child;
  final bool isBlank;

  const _MirrorSideCard({
    required this.label,
    required this.child,
    this.isBlank = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isBlank
            ? AppColors.inputFill.withOpacity(0.78)
            : AppColors.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isBlank
              ? AppColors.border
              : AppColors.primary.withOpacity(0.16),
          width: 1.3,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'ArialRounded',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Center(child: child),
          const Spacer(),
        ],
      ),
    );
  }
}

class _MirrorDivider extends StatelessWidget {
  const _MirrorDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.secondary.withOpacity(0.15),
            AppColors.secondary,
            AppColors.primary,
            AppColors.secondary.withOpacity(0.15),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.55),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

class _BlankSlot extends StatelessWidget {
  const _BlankSlot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 66,
      height: 66,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.25),
          width: 2,
        ),
      ),
      child: const Text(
        '؟',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          color: AppColors.primary,
        ),
      ),
    );
  }
}