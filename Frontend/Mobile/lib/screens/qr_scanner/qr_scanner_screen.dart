import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../shared/layout/app_background.dart';
import 'widgets/camera_viewfinder.dart';
import 'widgets/pro_tip_card.dart';
import 'widgets/scanner_action_button.dart';
import 'widgets/scanner_badge.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({
    super.key,
    this.returnFirstScan = false,
  });

  /// When true, the scanner returns the first scanned QR value
  /// using Navigator.pop(context, value).
  ///
  /// Default is false to keep the old multi-scan behavior unchanged.
  final bool returnFirstScan;

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  static const int _maxScans = 5;
  static const Duration _debounceDuration = Duration(seconds: 5);

  final MobileScannerController _scannerController = MobileScannerController();
  final List<String> _scannedValues = [];
  final Map<String, DateTime> _lastScanTimeByValue = {};

  bool _isScannerStopped = false;
  bool _isDuplicateDialogVisible = false;
  bool _isReturningScanValue = false;

  bool get _hasReachedMaxScans => _scannedValues.length >= _maxScans;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _handleDetect(BarcodeCapture capture) async {
    if (_isScannerStopped ||
        _hasReachedMaxScans ||
        _isReturningScanValue) {
      return;
    }

    final Barcode? barcode =
    capture.barcodes.isNotEmpty ? capture.barcodes.first : null;

    final String? value = barcode?.rawValue?.trim();

    if (value == null || value.isEmpty) return;

    final now = DateTime.now();
    final lastScanTime = _lastScanTimeByValue[value];

    if (lastScanTime != null &&
        now.difference(lastScanTime) < _debounceDuration) {
      return;
    }

    _lastScanTimeByValue[value] = now;

    await HapticFeedback.heavyImpact();

    if (!mounted) return;

    /// Conflict Resolution / activity mode:
    /// return the first scanned value immediately.
    if (widget.returnFirstScan) {
      _isReturningScanValue = true;

      setState(() {
        _isScannerStopped = true;
      });

      await _scannerController.stop();

      if (!mounted) return;

      Navigator.of(context).pop(value);
      return;
    }

    final bool wasAlreadyScanned = _scannedValues.contains(value);

    setState(() {
      _scannedValues.remove(value);
      _scannedValues.add(value);
    });

    _showScanMessage(
      value: value,
      wasAlreadyScanned: wasAlreadyScanned,
    );

    if (_hasReachedMaxScans) {
      await _stopScanner();
    }
  }

  void _showScanMessage({
    required String value,
    required bool wasAlreadyScanned,
  }) {
    ScaffoldMessenger.of(context).clearSnackBars();

    if (wasAlreadyScanned) {
      _showAlreadyScannedDialog();
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(18),
        backgroundColor: AppColors.primary,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        content: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.white,
                size: 23,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تم مسح البطاقة!',
                    textAlign: TextAlign.right,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.white,
                      fontSize: 14.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    textAlign: TextAlign.left,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.ltr,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.white.withValues(alpha: 0.88),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        duration: const Duration(milliseconds: 1400),
      ),
    );
  }

  void _showAlreadyScannedDialog() {
    if (_isDuplicateDialogVisible) return;

    _isDuplicateDialogVisible = true;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'already_scanned_dialog',
      barrierColor: AppColors.black.withValues(alpha: 0.25),
      transitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        Future.delayed(const Duration(milliseconds: 1400), () {
          if (!mounted) return;

          if (_isDuplicateDialogVisible &&
              Navigator.of(dialogContext).canPop()) {
            Navigator.of(dialogContext).pop();
          }
        });

        return Directionality(
          textDirection: TextDirection.rtl,
          child: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: 280,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 24,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7E6),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: const Color(0xFFFFE7A8),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 62,
                      height: 62,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.22),
                            blurRadius: 14,
                            offset: const Offset(0, 7),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.info_rounded,
                        color: AppColors.white,
                        size: 34,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'هذا الـ QR تم مسحه من قبل',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.headlineMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return Transform.scale(
          scale: 0.88 + (animation.value * 0.12),
          child: Opacity(
            opacity: animation.value,
            child: child,
          ),
        );
      },
    ).then((_) {
      _isDuplicateDialogVisible = false;
    });
  }

  Future<void> _stopScanner() async {
    if (_isScannerStopped) return;

    setState(() {
      _isScannerStopped = true;
    });

    await _scannerController.stop();
  }

  Future<void> _resumeScanner() async {
    if (!_isScannerStopped || _hasReachedMaxScans) return;

    setState(() {
      _isScannerStopped = false;
    });

    await _scannerController.start();
  }

  Future<void> _restartScanner() async {
    setState(() {
      _isScannerStopped = false;
      _isReturningScanValue = false;
      _scannedValues.clear();
      _lastScanTimeByValue.clear();
    });

    await _scannerController.start();
  }

  @override
  Widget build(BuildContext context) {
    final bool isComplete = _hasReachedMaxScans;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: AppBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
              child: Column(
                children: [
                  ScannerBadge(
                    currentScans: _scannedValues.length,
                    maxScans: _maxScans,
                    isComplete: isComplete,
                  ),
                  const SizedBox(height: 26),
                  CameraViewfinder(
                    scannerController: _scannerController,
                    onDetect: _handleDetect,
                    isScannerStopped: _isScannerStopped,
                    hasReachedMaxScans: isComplete,
                  ),
                  const SizedBox(height: 24),
                  const ProTipCard(),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: ScannerActionButton(
                          icon: Icons.refresh_rounded,
                          label: 'إعادة التجربة',
                          onTap: _restartScanner,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: ScannerActionButton(
                          icon: isComplete
                              ? Icons.check_circle_rounded
                              : _isScannerStopped
                              ? Icons.play_arrow_rounded
                              : Icons.stop_rounded,
                          label: isComplete
                              ? 'اكتملت الجلسة'
                              : _isScannerStopped
                              ? 'تشغيل المسح'
                              : 'إيقاف المسح',
                          isMuted: isComplete,
                          onTap: isComplete
                              ? null
                              : _isScannerStopped
                              ? _resumeScanner
                              : _stopScanner,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  _buildScannedList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScannedList() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'القيم التي تم مسحها',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          if (_scannedValues.isEmpty)
            Text(
              'لم يتم مسح أي بطاقة بعد.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            )
          else
            ...List.generate(_scannedValues.length, (index) {
              final value = _scannedValues[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 9),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9FAF6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        '${index + 1}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        value,
                        textAlign: TextAlign.left,
                        textDirection: TextDirection.ltr,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}