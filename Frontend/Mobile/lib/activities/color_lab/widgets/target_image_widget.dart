import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/activities/color_lab/color_lab_models.dart';

/// Shows the object the child must match (TARGET image).
/// Big image, very thin yellow border hugging the image (minimal padding).
class TargetImageWidget extends StatelessWidget {
  final ColorLabImage challenge;

  const TargetImageWidget({
    super.key,
    required this.challenge,
  });

  /// Friendly Arabic label for the object, falling back to the raw label.
  String get _displayLabel {
    final raw = challenge.label.trim();
    final key = raw.toLowerCase();
    const map = {
      'banana': 'موزة',
      'blue sky': 'سماء زرقاء',
      'sky': 'سماء',
      'red apple': 'تفاحة حمراء',
      'apple': 'تفاحة',
      'green leaf': 'ورقة شجر خضراء',
      'leaf': 'ورقة شجر',
      'orange': 'برتقالة',
      'grapes': 'عنب',
      'grape': 'عنب',
      'grass': 'عشب',
      'light blue sky': 'سماء زرقاء فاتحة',
      'light sky': 'سماء فاتحة',
      'light leaf': 'ورقة فاتحة',
      'light green leaf': 'ورقة خضراء فاتحة',
    };
    return map[key] ?? raw;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.yellow, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 1.8, // wide & short → big image, little wasted height
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: challenge.hasImage
                  ? Image.network(
                challenge.url,
                fit: BoxFit.cover, // fills the frame → image looks bigger
                errorBuilder: (_, __, ___) => _placeholder(),
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                },
              )
                  : _placeholder(),
            ),
          ),
          if (_displayLabel.trim().isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              _displayLabel,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppColors.inputFill,
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        color: AppColors.hint,
        size: 46,
      ),
    );
  }
}
