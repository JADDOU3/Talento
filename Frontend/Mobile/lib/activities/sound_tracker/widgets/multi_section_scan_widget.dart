import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../screens/qr_scanner/qr_scanner_screen.dart';

class MultiSectionScanWidget extends StatefulWidget {
  final int sectionCount;
  final List<String> expectedSequence;
  final Future<void> Function(int sectionIndex, String scannedValue)
  onSectionScanned;
  final List<bool> sectionAnswered;
  final List<bool> sectionCorrect;

  const MultiSectionScanWidget({
    super.key,
    required this.sectionCount,
    required this.expectedSequence,
    required this.onSectionScanned,
    required this.sectionAnswered,
    required this.sectionCorrect,
  });

  @override
  State<MultiSectionScanWidget> createState() => _MultiSectionScanWidgetState();
}

class _MultiSectionScanWidgetState extends State<MultiSectionScanWidget> {
  int? _busySectionIndex;

  Future<void> _openScannerForSection(int sectionIndex) async {
    if (_busySectionIndex != null) return;
    if (!_canScanSection(sectionIndex)) return;

    setState(() {
      _busySectionIndex = sectionIndex;
    });

    try {
      final String? scannedValue = await Navigator.of(context).push<String>(
        MaterialPageRoute(
          builder: (_) => const QrScannerScreen(
            returnFirstScan: true,
          ),
        ),
      );

      if (!mounted) return;

      if (scannedValue == null || scannedValue.trim().isEmpty) {
        return;
      }

      await widget.onSectionScanned(
        sectionIndex,
        scannedValue.trim(),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _busySectionIndex = null;
      });
    }
  }

  bool _canScanSection(int sectionIndex) {
    if (sectionIndex < 0 || sectionIndex >= widget.sectionCount) {
      return false;
    }

    if (sectionIndex == 0) return true;

    return _safeBool(widget.sectionAnswered, sectionIndex - 1) &&
        _safeBool(widget.sectionCorrect, sectionIndex - 1);
  }

  bool _safeBool(List<bool> values, int index) {
    if (index < 0 || index >= values.length) return false;
    return values[index];
  }

  String _sectionTitle(int index) {
    switch (index) {
      case 0:
        return 'الصوت ١';
      case 1:
        return 'الصوت ٢';
      case 2:
        return 'الصوت ٣';
      default:
        return 'الصوت ${index + 1}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.sectionCount.clamp(2, 3).toInt();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground.withOpacity(0.94),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.12),
            width: 1.3,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 14),
            Row(
              children: List.generate(count, (index) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: index == count - 1 ? 0 : 8,
                    ),
                    child: _buildSectionPanel(index),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'امسح البطاقات بالترتيب',
          textAlign: TextAlign.center,
          style: AppTextStyles.headlineMedium.copyWith(
            fontSize: 21,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          'ابدأ بالصوت الأول، وبعدها افتح الصوت التالي',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium.copyWith(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionPanel(int index) {
    final answered = _safeBool(widget.sectionAnswered, index);
    final correct = _safeBool(widget.sectionCorrect, index);
    final enabled = _canScanSection(index);
    final busy = _busySectionIndex == index;

    final Color borderColor;
    final Color backgroundColor;

    if (answered && correct) {
      borderColor = AppColors.success;
      backgroundColor = AppColors.success.withOpacity(0.08);
    } else if (answered && !correct) {
      borderColor = AppColors.error;
      backgroundColor = AppColors.error.withOpacity(0.07);
    } else if (enabled) {
      borderColor = AppColors.primary.withOpacity(0.35);
      backgroundColor = AppColors.primary.withOpacity(0.05);
    } else {
      borderColor = AppColors.border;
      backgroundColor = AppColors.inputFill.withOpacity(0.75);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: borderColor,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          _buildStatusIcon(
            answered: answered,
            correct: correct,
            enabled: enabled,
            busy: busy,
          ),
          const SizedBox(height: 9),
          Text(
            _sectionTitle(index),
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyLarge.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: enabled ? AppColors.textPrimary : AppColors.hint,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _statusText(
              answered: answered,
              correct: correct,
              enabled: enabled,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 11.5,
              height: 1.25,
              color: _statusTextColor(
                answered: answered,
                correct: correct,
                enabled: enabled,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildScanButton(
            index: index,
            answered: answered,
            correct: correct,
            enabled: enabled,
            busy: busy,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon({
    required bool answered,
    required bool correct,
    required bool enabled,
    required bool busy,
  }) {
    final IconData icon;
    final Color color;

    if (busy) {
      icon = Icons.qr_code_scanner_rounded;
      color = AppColors.primary;
    } else if (answered && correct) {
      icon = Icons.check_circle_rounded;
      color = AppColors.success;
    } else if (answered && !correct) {
      icon = Icons.cancel_rounded;
      color = AppColors.error;
    } else if (enabled) {
      icon = Icons.qr_code_2_rounded;
      color = AppColors.primary;
    } else {
      icon = Icons.lock_rounded;
      color = AppColors.hint;
    }

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: busy
          ? Padding(
        padding: const EdgeInsets.all(11),
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: color,
        ),
      )
          : Icon(
        icon,
        size: 25,
        color: color,
      ),
    );
  }

  Widget _buildScanButton({
    required int index,
    required bool answered,
    required bool correct,
    required bool enabled,
    required bool busy,
  }) {
    final bool canTap = enabled && !correct && !busy;

    final String label;

    if (busy) {
      label = 'جاري المسح';
    } else if (answered && correct) {
      label = 'تم';
    } else if (answered && !correct) {
      label = 'حاول مرة';
    } else if (enabled) {
      label = 'امسح';
    } else {
      label = 'مقفل';
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canTap ? () => _openScannerForSection(index) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: answered && !correct
              ? AppColors.error
              : AppColors.primary,
          disabledBackgroundColor:
          correct ? AppColors.success.withOpacity(0.18) : AppColors.border,
          disabledForegroundColor: correct ? AppColors.success : AppColors.hint,
          foregroundColor: AppColors.white,
          elevation: canTap ? 4 : 0,
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 10,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          textStyle: AppTextStyles.button.copyWith(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  String _statusText({
    required bool answered,
    required bool correct,
    required bool enabled,
  }) {
    if (answered && correct) return 'إجابة صحيحة';
    if (answered && !correct) return 'جرّب بطاقة أخرى';
    if (enabled) return 'جاهز للمسح';
    return 'افتح السابق أولًا';
  }

  Color _statusTextColor({
    required bool answered,
    required bool correct,
    required bool enabled,
  }) {
    if (answered && correct) return AppColors.success;
    if (answered && !correct) return AppColors.error;
    if (enabled) return AppColors.primary;
    return AppColors.hint;
  }
}