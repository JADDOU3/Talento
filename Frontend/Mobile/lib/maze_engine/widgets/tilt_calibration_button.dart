import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../tilt/tilt_controller.dart';

/// Reusable "hold the phone flat, tap to calibrate" control so every future
/// maze doesn't rebuild this from scratch.
///
/// Calls [TiltController.calibrate] and shows a brief confirmation so the
/// child gets clear feedback that calibration happened.
class TiltCalibrationButton extends StatefulWidget {
  const TiltCalibrationButton({
    super.key,
    required this.tiltController,
    this.onCalibrated,
  });

  final TiltController tiltController;

  /// Optional extra callback, e.g. to re-center a ball's position.
  final VoidCallback? onCalibrated;

  @override
  State<TiltCalibrationButton> createState() => _TiltCalibrationButtonState();
}

class _TiltCalibrationButtonState extends State<TiltCalibrationButton> {
  bool _justCalibrated = false;
  Timer? _resetTimer;

  void _handleTap() {
    widget.tiltController.calibrate();
    widget.onCalibrated?.call();

    setState(() => _justCalibrated = true);
    _resetTimer?.cancel();
    _resetTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) setState(() => _justCalibrated = false);
    });
  }

  @override
  void dispose() {
    _resetTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton.icon(
        onPressed: _handleTap,
        icon: Icon(
          _justCalibrated ? Icons.check_circle_rounded : Icons.tune_rounded,
        ),
        label: Text(
          _justCalibrated ? 'تمت المعايرة!' : 'امسكي الجهاز بشكل مسطح واضغطي للمعايرة',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              _justCalibrated ? AppColors.primary : AppColors.primary,
          foregroundColor: AppColors.cardBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
      ),
    );
  }
}
