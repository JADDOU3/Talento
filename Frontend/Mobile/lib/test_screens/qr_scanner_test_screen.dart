import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';


/*
Talento QR Scanner Prototype

Package chosen: mobile_scanner
Version used: 7.2.0


Why mobile_scanner:
- Supports Android and iOS.
- Supports continuous scanning in the same camera session.
- Allows custom UI overlay above the camera preview.
- Allows programmatic start/stop using MobileScannerController.

Prototype behavior:
- Shows live camera preview with Talento-style scanner overlay.
- Tracks scans using a counter: 0/5 to 5/5.
- Allows multiple scans without restarting the camera.
- Uses a 5-second debounce window to avoid accidental duplicate scans.
- The same QR can be scanned again after the debounce window.
- Stops scanning automatically after 5 accepted scans.
- Shows scanned values in a list.
- Shows a non-blocking SnackBar after each successful scan.

Haptic feedback:
- Uses Flutter built-in HapticFeedback instead of the vibration package.
- Uses HapticFeedback.heavyImpact() because mediumImpact felt too light during testing.
- If longer/custom vibration patterns are needed later, the vibration package should be tested.

*/

class QrScannerTestScreen extends StatefulWidget {
  const QrScannerTestScreen({super.key});

  @override
  State<QrScannerTestScreen> createState() => _QrScannerTestScreenState();
}

class _QrScannerTestScreenState extends State<QrScannerTestScreen>
    with SingleTickerProviderStateMixin {
  static const int _maxScans = 5;
  static const Duration _debounceDuration = Duration(seconds: 5);

  final MobileScannerController _scannerController = MobileScannerController();
  final List<String> _scannedValues = [];
  final Map<String, DateTime> _lastScanTimeByValue = {};

  late final AnimationController _scanLineController;

  bool _isScannerStopped = false;

  @override
  void initState() {
    super.initState();

    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanLineController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  void _handleDetect(BarcodeCapture capture) async {
    if (_isScannerStopped || _scannedValues.length >= _maxScans) return;

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

    setState(() {

      _scannedValues.remove(value);
      _scannedValues.add(value);

    });

    _showScanMessage(value);

    if (_scannedValues.length >= _maxScans) {
      await _stopScanner();
    }
  }

  void _showScanMessage(String value) {
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(18),
        backgroundColor: const Color(0xFF10A896),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        content: Text(
          'تم مسح البطاقة! — $value',
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        duration: const Duration(milliseconds: 1200),
      ),
    );
  }

  Future<void> _stopScanner() async {
    if (_isScannerStopped) return;

    setState(() {
      _isScannerStopped = true;
    });

    await _scannerController.stop();
  }

  Future<void> _restartScanner() async {
    setState(() {
      _isScannerStopped = false;
      _scannedValues.clear();
      _lastScanTimeByValue.clear();
    });

    await _scannerController.start();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE9FAF6),
                Color(0xFFFFF9EA),
                Color(0xFFFFEEF3),
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                children: [
                  _buildTopBar(context),
                  const SizedBox(height: 18),
                  _buildScannerBadge(),
                  const SizedBox(height: 22),
                  _buildCameraViewfinder(),
                  const SizedBox(height: 20),
                  _buildTipCard(),
                  const SizedBox(height: 18),
                  _buildActionButtons(),
                  const SizedBox(height: 20),
                  _buildScannedList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: const Color(0xFF123835),
        ),
        const Expanded(
          child: Text(
            'تجربة ماسح QR',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF123835),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildScannerBadge() {
    final isComplete = _scannedValues.length >= _maxScans;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 22,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: isComplete ? const Color(0xFF10A896) : const Color(0xFFF3A6A0),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.qr_code_scanner_rounded,
            size: 20,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
          Text(
            'عدد المسحات: ${_scannedValues.length}/$_maxScans',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraViewfinder() {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final viewfinderHeight = (screenWidth - 40) * 1.08;

    return Container(
      height: viewfinderHeight.clamp(330.0, 440.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10A896).withValues(alpha: 0.12),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller: _scannerController,
                  onDetect: _handleDetect,
                ),

                Container(
                  color: Colors.black.withValues(alpha: 0.08),
                ),

                CustomPaint(
                  painter: _CameraGridPainter(
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                ),

                AnimatedBuilder(
                  animation: _scanLineController,
                  builder: (context, child) {
                    final scanTop = 56 +
                        _scanLineController.value *
                            (constraints.maxHeight - 150);

                    return Positioned(
                      top: scanTop,
                      left: 38,
                      right: 38,
                      child: child!,
                    );
                  },
                  child: const SizedBox(
                    height: 30,
                    child: CustomPaint(
                      painter: _ScanLinePainter(
                        color: Color(0xFF10A896),
                      ),
                    ),
                  ),
                ),

                const CustomPaint(
                  painter: _ScannerCornerPainter(
                    color: Color(0xFF10A896),
                    strokeWidth: 7,
                    cornerLength: 64,
                    inset: 24,
                    radius: 22,
                  ),
                ),

                if (_isScannerStopped)
                  Container(
                    color: Colors.black.withValues(alpha: 0.55),
                    child: const Center(
                      child: Text(
                        'تم إيقاف المسح\nوصلتِ إلى 5/5',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),

                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 22,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Text(
                      _isScannerStopped
                          ? 'اضغطي إعادة التجربة لبدء جلسة جديدة'
                          : 'وجّهي الكاميرا نحو بطاقة تالينتو!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF123835),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTipCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E6),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF10A896),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10A896).withValues(alpha: 0.20),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تلميح ذكي!',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Color(0xFF123835),
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    height: 1.15,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'ثبّت الهاتف جيدًا، واجعل البطاقة في منتصف الصندوق.',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Color(0xFF60706D),
                    fontSize: 13,
                    height: 1.55,
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

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _ScannerActionButton(
            icon: Icons.refresh_rounded,
            label: 'إعادة التجربة',
            onTap: _restartScanner,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: _ScannerActionButton(
            icon: _isScannerStopped
                ? Icons.play_arrow_rounded
                : Icons.stop_rounded,
            label: _isScannerStopped ? 'تشغيل المسح' : 'إيقاف المسح',
            onTap: _isScannerStopped ? _restartScanner : _stopScanner,
            isMuted: _scannedValues.length >= _maxScans,
          ),
        ),
      ],
    );
  }

  Widget _buildScannedList() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'القيم التي تم مسحها',
            style: TextStyle(
              color: Color(0xFF123835),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          if (_scannedValues.isEmpty)
            const Text(
              'لم يتم مسح أي بطاقة بعد.',
              style: TextStyle(
                color: Color(0xFF60706D),
                fontSize: 14,
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
                      backgroundColor: const Color(0xFF10A896),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
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
                        style: const TextStyle(
                          color: Color(0xFF123835),
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

class _ScannerActionButton extends StatelessWidget {
  const _ScannerActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isMuted = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isMuted;

  @override
  Widget build(BuildContext context) {
    final opacity = isMuted ? 0.55 : 1.0;

    return Opacity(
      opacity: opacity,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 76,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE7A8),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 14,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: const Color(0xFF123835),
                size: 24,
              ),
              const SizedBox(height: 7),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF123835),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CameraGridPainter extends CustomPainter {
  const _CameraGridPainter({
    required this.color,
  });

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    final verticalGap = size.width / 3;
    final horizontalGap = size.height / 3;

    for (int i = 1; i < 3; i++) {
      canvas.drawLine(
        Offset(verticalGap * i, 0),
        Offset(verticalGap * i, size.height),
        paint,
      );

      canvas.drawLine(
        Offset(0, horizontalGap * i),
        Offset(size.width, horizontalGap * i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CameraGridPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _ScanLinePainter extends CustomPainter {
  const _ScanLinePainter({
    required this.color,
  });

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.95)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final glowPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          color.withValues(alpha: 0.0),
          color.withValues(alpha: 0.30),
          color.withValues(alpha: 0.0),
        ],
      ).createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      glowPaint,
    );

    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScanLinePainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _ScannerCornerPainter extends CustomPainter {
  const _ScannerCornerPainter({
    required this.color,
    required this.strokeWidth,
    required this.cornerLength,
    required this.inset,
    required this.radius,
  });

  final Color color;
  final double strokeWidth;
  final double cornerLength;
  final double inset;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final left = inset;
    final top = inset;
    final right = size.width - inset;
    final bottom = size.height - inset;

    _drawTopLeft(canvas, paint, left, top);
    _drawTopRight(canvas, paint, right, top);
    _drawBottomLeft(canvas, paint, left, bottom);
    _drawBottomRight(canvas, paint, right, bottom);
  }

  void _drawTopLeft(Canvas canvas, Paint paint, double left, double top) {
    final path = Path()
      ..moveTo(left, top + cornerLength)
      ..lineTo(left, top + radius)
      ..quadraticBezierTo(left, top, left + radius, top)
      ..lineTo(left + cornerLength, top);

    canvas.drawPath(path, paint);
  }

  void _drawTopRight(Canvas canvas, Paint paint, double right, double top) {
    final path = Path()
      ..moveTo(right - cornerLength, top)
      ..lineTo(right - radius, top)
      ..quadraticBezierTo(right, top, right, top + radius)
      ..lineTo(right, top + cornerLength);

    canvas.drawPath(path, paint);
  }

  void _drawBottomLeft(Canvas canvas, Paint paint, double left, double bottom) {
    final path = Path()
      ..moveTo(left, bottom - cornerLength)
      ..lineTo(left, bottom - radius)
      ..quadraticBezierTo(left, bottom, left + radius, bottom)
      ..lineTo(left + cornerLength, bottom);

    canvas.drawPath(path, paint);
  }

  void _drawBottomRight(Canvas canvas, Paint paint, double right, double bottom) {
    final path = Path()
      ..moveTo(right - cornerLength, bottom)
      ..lineTo(right - radius, bottom)
      ..quadraticBezierTo(right, bottom, right, bottom - radius)
      ..lineTo(right, bottom - cornerLength);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ScannerCornerPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.cornerLength != cornerLength ||
        oldDelegate.inset != inset ||
        oldDelegate.radius != radius;
  }
}