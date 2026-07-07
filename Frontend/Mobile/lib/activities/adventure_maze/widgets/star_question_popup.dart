import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/activities/adventure_maze/adventure_maze_models.dart';

/// Popup shown when the ball collides with a star.
///
/// Behavior per §6 of the spec:
///   - cognitive: correct = only the isCorrect==true choice. Wrong answers
///     stay tappable (no penalty), and show brief incorrect feedback.
///   - emotional: every choice is correct — any tap collects the star.
///
/// The parent screen owns the game/cubit interaction; this dialog only
/// reports which choice was tapped via [onChoiceSelected] and closes
/// itself when [onChoiceSelected] returns true (a valid answer).
class StarQuestionPopup extends StatefulWidget {
  final StarChallenge challenge;

  /// Returns true if the tap collected the star (valid answer), false if
  /// the popup should stay open (wrong cognitive answer).
  final bool Function(StarChoice choice) onChoiceSelected;

  const StarQuestionPopup({
    super.key,
    required this.challenge,
    required this.onChoiceSelected,
  });

  @override
  State<StarQuestionPopup> createState() => _StarQuestionPopupState();
}

class _StarQuestionPopupState extends State<StarQuestionPopup> {
  String? _wrongIcon; // shows brief "incorrect" state on this choice

  void _handleTap(StarChoice choice) {
    final valid = widget.onChoiceSelected(choice);
    if (valid) return; // parent will close the popup
    setState(() => _wrongIcon = choice.icon);
    // Clear the wrong indicator after a moment so the child can try again.
    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) setState(() => _wrongIcon = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: AppColors.cardBackground,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.yellow.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.star_rounded,
                  size: 34,
                  color: AppColors.yellow,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                widget.challenge.prompt,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: widget.challenge.choices
                    .map((c) => _ChoiceTile(
                  choice: c,
                  isWrongFeedback: _wrongIcon == c.icon,
                  onTap: () => _handleTap(c),
                ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  final StarChoice choice;
  final bool isWrongFeedback;
  final VoidCallback onTap;

  const _ChoiceTile({
    required this.choice,
    required this.isWrongFeedback,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isWrongFeedback
        ? AppColors.red.withValues(alpha: 0.12)
        : AppColors.inputFill;
    final border = isWrongFeedback ? AppColors.red : AppColors.border;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 92,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border, width: 1.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ChoiceIcon(icon: choice.icon, label: choice.label),
            const SizedBox(height: 8),
            Text(
              choice.label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceIcon extends StatelessWidget {
  final String icon;
  final String label;
  const _ChoiceIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    // Try to load an image asset first; fall back to a nice emoji lookup
    // based on the label, else the icon slug's initial.
    final assetPath = 'assets/images/cards/$icon.png';
    return SizedBox(
      width: 48,
      height: 48,
      child: Image.asset(
        assetPath,
        errorBuilder: (_, __, ___) => _EmojiFallback(icon: icon, label: label),
      ),
    );
  }
}

/// Nice emoji-style fallback that never shows a single random letter.
class _EmojiFallback extends StatelessWidget {
  final String icon;
  final String label;
  const _EmojiFallback({required this.icon, required this.label});

  /// Map of keywords → emoji. Checked in order (English icon slug first,
  /// then label word — supports both English and Arabic labels).
  static const Map<String, String> _emojiMap = {
    // — English —
    'happy': '😊', 'joy': '😊', 'joyful': '😊', 'smile': '😊', 'good': '😊',
    'sad': '😢', 'cry': '😢', 'crying': '😢',
    'angry': '😠', 'anger': '😠', 'mad': '😠',
    'scared': '😨', 'fear': '😨', 'afraid': '😨',
    'surprised': '😲', 'shock': '😲', 'wow': '😲',
    'love': '❤️', 'heart': '❤️',
    'star': '⭐', 'sun': '☀️', 'moon': '🌙', 'cloud': '☁️',
    'yes': '✅', 'ok': '✅', 'correct': '✅', 'true': '✅',
    'no': '❌', 'wrong': '❌', 'false': '❌',
    'apple': '🍎', 'banana': '🍌', 'orange': '🍊', 'grape': '🍇',
    'car': '🚗', 'ball': '⚽', 'book': '📖', 'pencil': '✏️',
    'run': '🏃', 'walk': '🚶', 'jump': '🤸', 'sleep': '😴',
    'eat': '🍽️', 'drink': '🥤',
    'family': '👨‍👩‍👧', 'friend': '🤝', 'friends': '🤝',
    'help': '🙌', 'share': '🤲', 'listen': '👂', 'talk': '🗣️',
    'thanks': '🙏', 'sorry': '😔', 'please': '🙏',
    'water': '💧', 'fire': '🔥', 'tree': '🌳', 'flower': '🌸',
    'dog': '🐶', 'cat': '🐱', 'bird': '🐦', 'fish': '🐟',
    'up': '⬆️', 'down': '⬇️', 'left': '⬅️', 'right': '➡️',
    'red': '🔴', 'blue': '🔵', 'green': '🟢', 'yellow': '🟡',
    'big': '🐘', 'small': '🐭',
    'hot': '🥵', 'cold': '🥶',
    'day': '☀️', 'night': '🌙',
    'music': '🎵', 'game': '🎮', 'toy': '🧸',
    'home': '🏠', 'school': '🏫', 'hospital': '🏥',
    'mom': '👩', 'dad': '👨', 'baby': '👶',
    'question': '❓', 'idea': '💡', 'think': '🤔',

    // — عربي (كلمات مفتاحية) —
    'سعيد': '😊', 'فرحان': '😊', 'مبسوط': '😊', 'مسرور': '😊', 'فرح': '😊',
    'حزين': '😢', 'زعلان': '😢', 'حزن': '😢', 'يبكي': '😢', 'بكاء': '😢',
    'غاضب': '😠', 'غضب': '😠', 'زعل': '😠', 'عصبي': '😠',
    'خائف': '😨', 'خوف': '😨', 'خايف': '😨',
    'متفاجئ': '😲', 'مندهش': '😲', 'دهشة': '😲',
    'حب': '❤️', 'محب': '❤️', 'قلب': '❤️',
    'نجمة': '⭐', 'شمس': '☀️', 'قمر': '🌙', 'غيمة': '☁️',
    'نعم': '✅', 'صح': '✅', 'صحيح': '✅', 'صواب': '✅',
    'لا': '❌', 'خطأ': '❌', 'غلط': '❌',
    'تفاحة': '🍎', 'موز': '🍌', 'موزة': '🍌', 'برتقال': '🍊', 'عنب': '🍇',
    'سيارة': '🚗', 'كرة': '⚽', 'كتاب': '📖', 'قلم': '✏️',
    'يجري': '🏃', 'يمشي': '🚶', 'ينط': '🤸', 'ينام': '😴', 'نوم': '😴',
    'يأكل': '🍽️', 'أكل': '🍽️', 'يشرب': '🥤', 'شرب': '🥤',
    'عائلة': '👨‍👩‍👧', 'صديق': '🤝', 'أصدقاء': '🤝',
    'مساعدة': '🙌', 'يساعد': '🙌', 'يشارك': '🤲', 'مشاركة': '🤲',
    'يستمع': '👂', 'يتكلم': '🗣️', 'يحكي': '🗣️',
    'شكرا': '🙏', 'آسف': '😔', 'اعتذار': '😔', 'من فضلك': '🙏',
    'ماء': '💧', 'نار': '🔥', 'شجرة': '🌳', 'وردة': '🌸', 'زهرة': '🌸',
    'كلب': '🐶', 'قطة': '🐱', 'قط': '🐱', 'طائر': '🐦', 'سمكة': '🐟',
    'فوق': '⬆️', 'تحت': '⬇️', 'يسار': '⬅️', 'يمين': '➡️',
    'أحمر': '🔴', 'أزرق': '🔵', 'أخضر': '🟢', 'أصفر': '🟡',
    'كبير': '🐘', 'صغير': '🐭',
    'حار': '🥵', 'بارد': '🥶',
    'نهار': '☀️', 'ليل': '🌙',
    'موسيقى': '🎵', 'لعبة': '🎮', 'دمية': '🧸',
    'بيت': '🏠', 'منزل': '🏠', 'مدرسة': '🏫', 'مستشفى': '🏥',
    'أم': '👩', 'ماما': '👩', 'أب': '👨', 'بابا': '👨', 'طفل': '👶', 'رضيع': '👶',
    'سؤال': '❓', 'فكرة': '💡', 'يفكر': '🤔', 'تفكير': '🤔',
  };

  @override
  Widget build(BuildContext context) {
    // Try both the icon slug and each word in the label.
    final iconKey = icon.toLowerCase().trim();
    if (_emojiMap.containsKey(iconKey)) {
      return _emojiWidget(_emojiMap[iconKey]!);
    }
    // Break label into words and try each one.
    final words = label.trim().split(RegExp(r'\s+'));
    for (final w in words) {
      final wLow = w.toLowerCase().replaceAll(RegExp(r'[.,!?()]'), '');
      if (_emojiMap.containsKey(wLow)) {
        return _emojiWidget(_emojiMap[wLow]!);
      }
    }
    // Nothing matched — friendly circle icon (never a random letter).
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.emoji_emotions_rounded,
        color: AppColors.primary,
        size: 26,
      ),
    );
  }

  Widget _emojiWidget(String emoji) {
    return Center(
      child: Text(emoji, style: const TextStyle(fontSize: 34)),
    );
  }
}
