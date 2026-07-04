import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/activities/color_lab/color_lab_models.dart';
import '../../../shared/painting/outline_mask.dart';

/// Level 4 — Free Coloring.
///
/// Shows the TARGET outline image and lets the child drag a finger to color it
/// in with a chosen color. Going outside the outline is allowed; it's measured,
/// not blocked. The painting state lives here; the parent reads the result on
/// submit via [FreeColoringWidgetState.evaluateColoring].
class FreeColoringWidget extends StatefulWidget {
  final ColorLabImage challenge;

  /// Notifies the parent when the child has/hasn't colored anything (to
  /// enable/disable the Submit button).
  final ValueChanged<bool>? onColoringChanged;

  const FreeColoringWidget({
    super.key,
    required this.challenge,
    this.onColoringChanged,
  });

  @override
  State<FreeColoringWidget> createState() => FreeColoringWidgetState();
}

class FreeColoringWidgetState extends State<FreeColoringWidget> {
  ui.Image? _image;
  double _aspect = 1;
  OutlineMask? _mask;
  bool _loadError = false;

  ImageStream? _stream;
  ImageStreamListener? _listener;

  final List<ColoringStroke> _strokes = [];
  ColoringStroke? _current;

  Size _canvasSize = Size.zero;

  late List<Color> _swatches;
  late Color _selected;

  bool get hasColoring => _strokes.isNotEmpty || _current != null;

  @override
  void initState() {
    super.initState();
    _swatches = _buildSwatches();
    _selected = _swatches.first;
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant FreeColoringWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.challenge.id != widget.challenge.id) {
      _strokes.clear();
      _current = null;
      _image = null;
      _mask = null;
      _loadError = false;
      _swatches = _buildSwatches();
      _selected = _swatches.first;
      _loadImage();
      _notify();
    }
  }

  List<Color> _buildSwatches() {
    final base = <Color>[
      const Color(0xFFE53935), // red
      const Color(0xFFFB8C00), // orange
      const Color(0xFFFDD835), // yellow
      const Color(0xFF43A047), // green
      const Color(0xFF1E88E5), // blue
      const Color(0xFF8E24AA), // purple
      const Color(0xFF6D4C41), // brown
      const Color(0xFFEC407A), // pink
      const Color(0xFF000000), // black
    ];
    // Make sure the exact target color is always pickable.
    final target = widget.challenge.primaryTarget?.color;
    if (target != null) {
      final exists = base.any((c) =>
          c.red == target.red &&
          c.green == target.green &&
          c.blue == target.blue);
      if (!exists) base.add(target);
    }
    return base;
  }

  void _loadImage() {
    final url = widget.challenge.url.trim();
    if (url.isEmpty) {
      setState(() => _loadError = true);
      return;
    }

    final provider = NetworkImage(url);
    final stream = provider.resolve(ImageConfiguration.empty);
    _detachStream();
    _stream = stream;
    _listener = ImageStreamListener(
      (info, _) async {
        final img = info.image;
        final mask = await OutlineMask.fromImage(img);
        if (!mounted) return;
        setState(() {
          _image = img;
          _aspect = img.height == 0 ? 1 : img.width / img.height;
          _mask = mask;
        });
      },
      onError: (error, stackTrace) {
        if (mounted) setState(() => _loadError = true);
      },
    );
    stream.addListener(_listener!);
  }

  void _detachStream() {
    if (_stream != null && _listener != null) {
      _stream!.removeListener(_listener!);
    }
    _stream = null;
    _listener = null;
  }

  @override
  void dispose() {
    _detachStream();
    super.dispose();
  }

  void _notify() => widget.onColoringChanged?.call(hasColoring);

  void _onPanStart(DragStartDetails d) {
    setState(() {
      _current = ColoringStroke(color: _selected, points: [d.localPosition]);
    });
    _notify();
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (_current == null) return;
    setState(() => _current!.points.add(d.localPosition));
  }

  void _onPanEnd(DragEndDetails d) {
    if (_current == null) return;
    setState(() {
      _strokes.add(_current!);
      _current = null;
    });
  }

  void clearAll() {
    setState(() {
      _strokes.clear();
      _current = null;
    });
    _notify();
  }

  void undo() {
    if (_strokes.isEmpty) return;
    setState(() => _strokes.removeLast());
    _notify();
  }

  /// Compares the child's coloring against the derived outline.
  ColoringEvaluation evaluateColoring() {
    final all = [..._strokes, if (_current != null) _current!];
    final mask = _mask ?? OutlineMask.allInside();
    return mask.evaluate(all, _canvasSize);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildCanvas(),
        const SizedBox(height: 12),
        _buildClearUndoRow(),
        const SizedBox(height: 14),
        _buildSwatchRow(),
      ],
    );
  }

  Widget _buildCanvas() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: AspectRatio(
          aspectRatio: _aspect,
          child: LayoutBuilder(
            builder: (context, constraints) {
              _canvasSize =
                  Size(constraints.maxWidth, constraints.maxHeight);
              if (_loadError) {
                return _buildLoadError();
              }
              if (_image == null) {
                return const Center(child: CircularProgressIndicator());
              }
              return GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: _ColoringPainter(
                      image: _image!,
                      strokes: _strokes,
                      current: _current,
                    ),
                    size: Size.infinite,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.image_not_supported_rounded,
                size: 40, color: AppColors.textSecondary),
            const SizedBox(height: 8),
            Text(
              'تعذّر تحميل الصورة',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClearUndoRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ActionChip(
          icon: Icons.delete_outline_rounded,
          label: 'مسح',
          enabled: hasColoring,
          onTap: clearAll,
        ),
        const SizedBox(width: 12),
        _ActionChip(
          icon: Icons.undo_rounded,
          label: 'تراجع',
          enabled: _strokes.isNotEmpty,
          onTap: undo,
        ),
      ],
    );
  }

  Widget _buildSwatchRow() {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _swatches.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, i) {
          final color = _swatches[i];
          final selected = color.red == _selected.red &&
              color.green == _selected.green &&
              color.blue == _selected.blue;
          return GestureDetector(
            onTap: () => setState(() => _selected = color),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary : AppColors.border,
                  width: selected ? 4 : 1.5,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: enabled ? onTap : null,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20, color: AppColors.textPrimary),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'ArialRounded',
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ColoringPainter extends CustomPainter {
  final ui.Image image;
  final List<ColoringStroke> strokes;
  final ColoringStroke? current;

  _ColoringPainter({
    required this.image,
    required this.strokes,
    required this.current,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1) Outline image as background.
    final src = Rect.fromLTWH(
      0,
      0,
      image.width.toDouble(),
      image.height.toDouble(),
    );
    final dst = Offset.zero & size;
    canvas.drawImageRect(
      image,
      src,
      dst,
      Paint()..filterQuality = FilterQuality.medium,
    );

    // 2) Child's coloring on top.
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke);
    }
    if (current != null) _drawStroke(canvas, current!);
  }

  void _drawStroke(Canvas canvas, ColoringStroke stroke) {
    if (stroke.points.isEmpty) return;
    final paint = Paint()
      ..color = stroke.color.withValues(alpha: 0.88)
      ..strokeWidth = 22
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (stroke.points.length == 1) {
      canvas.drawCircle(stroke.points.first, 11, paint..style = PaintingStyle.fill);
      return;
    }

    final path = Path()..moveTo(stroke.points.first.dx, stroke.points.first.dy);
    for (int i = 1; i < stroke.points.length; i++) {
      path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ColoringPainter oldDelegate) => true;
}
