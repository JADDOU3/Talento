import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/layout/app_background.dart';

/// Focused single-scan QR screen for Emotion Chain.
/// Returns the first scanned value via Navigator.pop(value).
///
/// (The shared QrScannerScreen is a multi-scan utility that doesn't return a
/// value, so this activity uses its own lightweight scanner.)
class EmotionChainScannerScreen extends StatefulWidget {
  const EmotionChainScannerScreen({super.key});

  @override
  State<EmotionChainScannerScreen> createState() =>
      _EmotionChainScannerScreenState();
}

class _EmotionChainScannerScreenState extends State<EmotionChainScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_handled) return;

    final barcode = capture.barcodes.isNotEmpty ? capture.barcodes.first : null;
    final value = barcode?.rawValue?.trim();
    if (value == null || value.isEmpty) return;

    _handled = true;
    await HapticFeedback.heavyImpact();
    if (!mounted) return;
    Navigator.pop(context, value);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: AppBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'امسح البطاقة',
                        style: TextStyle(
                          fontFamily: 'DGAgnadeen',
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          MobileScanner(
                            controller: _controller,
                            onDetect: _onDetect,
                          ),
                          IgnorePointer(
                            child: Center(
                              child: Container(
                                width: 220,
                                height: 220,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: AppColors.white,
                                    width: 3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'وجّه الكاميرا نحو بطاقة الإجابة',
                    style: TextStyle(
                      fontFamily: 'ArialRounded',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
